class CreateTestRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :test_runs do |t|
      t.string :name
      t.integer :tests
      t.integer :skipped
      t.integer :failures
      t.integer :errored
      t.decimal :time
      t.datetime :timestamp
      t.string :hostname

      t.timestamps
    end
  end
end
