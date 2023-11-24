require 'rails_helper'

RSpec.describe 'Test runs API' do
  describe 'POST /test_runs' do
    let!(:project) { FactoryBot.create :project }
    let(:test_run) { fixture_file_upload 'spec/fixtures/test_results.xml', 'application/xml'}
    let(:params) {{
      file: Rack::Test::UploadedFile.new(test_run),
      branch: 'branch',
      commit: 'commit'
    }}

    it 'works' do
      post "/projects/#{project.uid}/test_runs", params: params
      expect(response.status).to eq(200)
      expect(response.body).to eq('Saved')
      expect(project.reload.test_runs.count).to eq 1
      expect(project.test_runs.first.branch).to eq 'branch'
      expect(project.test_runs.first.commit).to eq 'commit'
      expect(project.test_runs.first.test_cases.count).to eq 4
    end

    Sidekiq::Testing.inline! do
      it 'kicks off the GithubCommentWorker' do
        expect {
          post "/projects/#{project.uid}/test_runs", params: params
        }.to change(GithubCommentWorker.jobs, :size).by(1)
      end
    end

    it 'does not work without a correct project hash id' do
      post "/projects/fake_uid/test_runs", params: params
      expect(response.status).to eq 404
      expect(response.body).to eq('Cannot find that project')
    end

    it 'returns an error message if the file is missing' do
      params.delete(:file)
      post "/projects/#{project.uid}/test_runs", params: params
      expect(response.status).to eq(400)
      expect(response.body).to include('provide valid rspec results')
    end

    it 'returns an error message if the branch is missing' do
      params.delete(:branch)
      post "/projects/#{project.uid}/test_runs", params: params
      expect(response.status).to eq(400)
      expect(response.body).to include('provide a branch name')
    end

    it 'returns an error message if the commit is missing' do
      params.delete(:commit)
      post "/projects/#{project.uid}/test_runs", params: params
      expect(response.status).to eq(400)
      expect(response.body).to include('provide a commit')
    end
  end
end
