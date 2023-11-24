class CreateTestCases < ActiveRecord::Migration[6.0]
  def change
    create_table :test_cases do |t|
      t.string :classname
      t.string :name
      t.string :file
      t.decimal :time
      t.boolean :skipped
      t.text :failure
      t.references :test_run, foreign_key: true

      t.timestamps
    end
  end
end
