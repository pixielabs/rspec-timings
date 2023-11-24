class TestCase < ApplicationRecord
  before_validation :set_hash_code, on: :create

  belongs_to :test_run

  validates_presence_of :hash_code

  def set_hash_code
    str = self.file + self.name
    self.hash_code = Digest::SHA256.hexdigest str
  end
end
