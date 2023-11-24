require 'rails_helper'

RSpec.describe Project, type: :model do
  it 'is valid' do
    expect(FactoryBot.build :project).to be_valid
  end

  it 'must have a name' do
    project = FactoryBot.build :project
    project.name = nil
    expect(project).to_not be_valid
  end

  it 'must have a uid' do
    project = FactoryBot.create :project
    project.uid = nil
    expect(project).to_not be_valid
  end
end
