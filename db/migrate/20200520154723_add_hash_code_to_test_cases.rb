class AddHashCodeToTestCases < ActiveRecord::Migration[6.0]
  def up
    add_column :test_cases, :hash_code, :string
    TestCase.find_each do |test|
      test.set_hash_code
      test.save
    end
    change_column_null :test_cases, :hash_code, false
    add_index :test_cases, :hash_code
  end

  def down
    remove_column :test_cases, :hash_code
  end
end
