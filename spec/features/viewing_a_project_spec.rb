require 'rails_helper'

RSpec.describe 'Viewing a project' do
  let!(:project) { FactoryBot.create :project }
  let(:github_url) { 'https://github.com/my-fav-project' }

  it 'requires the user to sign in with Balrog' do
    visit projects_path
    expect(page).to_not have_content 'Your projects'
  end

  context 'as a logged in user' do
    before do
      visit projects_path
      fill_in :password, with: 'password'
      click_button 'Login'
      click_link 'View test details'
    end

    it 'can edit a project name' do
      click_link 'View project settings'
      click_link 'Edit'
      fill_in :project_name, with: 'New project name'
      click_button 'Update'
      expect(page).to have_content 'Project updated'
      expect(page).to have_content 'New project name'
      expect(page).to_not have_content project.name
    end

    it 'can add a GitHub url' do
      click_link 'View project settings'
      click_link 'Edit'
      fill_in :project_github_url, with: github_url
      click_button 'Update'
      expect(page).to have_content 'Project updated'
      expect(page).to have_content project.name
      click_link 'View project settings'
      expect(page).to have_link github_url
    end

    it 'can delete a project' do
      click_link 'View project settings'
      click_link 'Delete'
      expect(page).to have_content 'Project deleted'
      expect(page).to_not have_content project.name
    end

    context 'with some test runs' do
      let!(:test_run_1) { FactoryBot.create :test_run, project: project }
      let!(:test_run_2) { FactoryBot.create :test_run, project: project }
      let(:test_case) { test_run_1.test_cases.first }

      before do
        visit projects_path
        click_link 'View test details'
      end

      it 'shows a list of test cases' do
        expect(page).to have_content 'Viewing change between'
        expect(page).to have_content test_case.name
      end

      it 'can click through to the individual test case page' do
        click_link test_case.name
        expect(page).to have_content "Test name #{test_case.name}"
        expect(page).to have_content "Location #{test_case.file}"
      end

      it 'can view a comparison between two commits' do
        visit "/projects/#{project.id}/compare?base=#{test_run_1.commit}&compare=#{test_run_2.commit}"
        expect(page).to have_content test_case.name
        expect(page).to have_content "Viewing change between #{test_run_1.commit} and #{test_run_2.commit}"
      end

      context 'when navigating from test case to project', js: true do
        before do
          click_link test_case.name

          expect(page).to have_text test_case.name

          # Hit the browsers back button
          page.go_back
        end

        it 'does not duplicate the date pickers' do
          # Start date picker
          within('.test-start-date-picker') do
            expect(page).to have_text 'Start date'
            # When the date pickers were duplicated, these are the classes they had
            expect(page).to have_css(".test-datepicker", count: 1)
          end

          # End date picker
          within('.test-end-date-picker') do
            expect(page).to have_text 'End date'
            expect(page).to have_css(".test-datepicker", count: 1)
          end
        end
      end

      context "when making a request with filtered run dates" do
        before do
          visit "/projects/#{project.id}/?start_date=2023-06-29&end_date=2023-06-23"
        end

        it 'displays flash alert when end date is before start date' do
          expect(page).to have_text 'The start date needs to be before the end date.'
        end
      end
    end
  end
end
