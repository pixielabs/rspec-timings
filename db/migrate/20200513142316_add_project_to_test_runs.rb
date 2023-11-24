class AddProjectToTestRuns < ActiveRecord::Migration[6.0]
  def up
    add_reference :test_runs, :project, index: true

    # If there are already projectless test runs in the DB, give them
    # a project.
    if TestRun.count > 0
      project = Project.create(name: 'Project 1')

      TestRun.find_each do |test_run|
        test_run.update!(project: project)
      end
    end

    add_foreign_key :test_runs, :projects, null: false
  end

  def down
    remove_reference :test_runs, :project
  end
end
