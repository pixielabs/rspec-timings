class TestRun < ApplicationRecord
  belongs_to :project
  has_many :test_cases, dependent: :destroy

  validates_presence_of :branch
  validates_presence_of :commit
end
