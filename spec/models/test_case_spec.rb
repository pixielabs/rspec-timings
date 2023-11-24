require 'rails_helper'

RSpec.describe TestCase, type: :model do
  it 'is valid' do
    expect(FactoryBot.build :test_case).to be_valid
  end

  it 'requires a hash code' do
    test_case = FactoryBot.create :test_case
    test_case.hash_code = nil
    expect(test_case).to_not be_valid
  end
end
