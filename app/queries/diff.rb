# A class that returns the diff between two test runs.
class Diff

  def initialize(first_run, last_run)
    @first_run = first_run
    @last_run = last_run
  end

  # We would like for our users to be abel to sort their results
  # So have added paramters that will help order the query
  def all(sort, direction)
    ActiveRecord::Base.connection.exec_query <<~SQL.squish
      WITH first_run AS (
        SELECT * FROM test_cases WHERE test_run_id = #{@first_run.id}
        ),
      last_run as (
        SELECT * FROM test_cases WHERE test_run_id = #{@last_run.id}
        )

      SELECT
        first_run.name,
        first_run.file,
        first_run.hash_code,
        first_run.time AS first_run_time,
        last_run.time AS last_run_time,
        last_run.time - first_run.time AS time_diff
      FROM first_run
      JOIN last_run ON first_run.hash_code = last_run.hash_code
      ORDER BY #{sort} #{direction};
      SQL
  end

  # Return the top five largest diffs (slower or faster) for these test runs.
  def top_five
    tests = self.all.to_a

    sorted = tests.sort { |a, b| b["time_diff"].to_f.abs <=> a["time_diff"].to_f.abs }
    sorted.first(5)
  end
end
