require 'rails_helper'

RSpec.describe TestRun, type: :model do
  it 'is valid' do
    expect(FactoryBot.build :test_run).to be_valid
  end

  it 'must have a project' do
    test_run = FactoryBot.create :test_run
    test_run.project_id = nil
    expect(test_run).to_not be_valid
  end

  it 'must have a branch name' do
    test_run = FactoryBot.create :test_run
    test_run.branch = nil
    expect(test_run).to_not be_valid
  end

  it 'must have a commit' do
    test_run = FactoryBot.create :test_run
    test_run.commit = nil
    expect(test_run).to_not be_valid
  end
end
