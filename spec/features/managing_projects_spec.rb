require 'rails_helper'

RSpec.describe 'Managing projects' do
  let!(:project) { FactoryBot.create :project }

  it 'requires the user to sign in with Balrog' do
    visit projects_path
    expect(page).to_not have_content 'Your projects'
  end

  context 'as a logged in user' do
    before do
      visit projects_path
      fill_in :password, with: 'password'
      click_button 'Login'
    end

    it 'can see a list of projects' do
      expect(page).to have_content 'Your projects'
      expect(page).to have_content project.name
    end

    it 'can create a new project' do
      click_link 'Add a project'
      fill_in :project_name, with: 'My first project'
      click_button 'Create'
      expect(page).to have_content 'Project created'
      expect(page).to have_content 'My first project'
    end

    it 'can visit an individual project page' do
      click_link 'View test details'
      expect(page).to have_content project.name
      expect(page).to have_link 'View project settings'
    end
  end
end

