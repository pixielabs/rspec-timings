class AddBranchAndCommitToTestRuns < ActiveRecord::Migration[6.0]
  def change
    add_column :test_runs, :branch, :string
    add_column :test_runs, :commit, :string
  end
end
