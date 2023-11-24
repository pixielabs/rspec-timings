class Project < ApplicationRecord
  before_validation :set_uid, on: :create

  validates :name, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: true

  has_many :test_runs, dependent: :destroy
  has_many :test_cases, through: :test_runs

  def last_test_run
    test_runs.order("timestamp ASC").last
  end

  # Maybe we just save the repo as a field, along with the github installation
  # id. This is fine for now :o)
  def repo
    github_url.split("github.com/").second
  end

  def organisation
    repo.split("/").first
  end

  private

  def set_uid
    uid = nil
    loop do
      uid = SecureRandom.urlsafe_base64(9).gsub(/-|_/,('a'..'z').to_a[rand(26)])
      break unless self.class.name.constantize.where(:uid => uid).exists?
    end
    self.uid = uid
  end
end
