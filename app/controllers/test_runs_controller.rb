class TestRunsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_with_balrog!

  # POST /projects/:project_uid/test_runs
  def create
    project = Project.find_by(uid: params[:project_id])
    render plain: 'Cannot find that project', status: 404 and return unless project

    branch = params[:branch]
    render plain: 'Please provide a branch name', status: 400 and return unless branch

    commit = params[:commit]
    render plain: 'Please provide a commit sha', status: 400 and return unless commit

    results = Nokogiri::XML(params[:file])
    testsuite = results.css("testsuite")[0]
    render plain: 'Please provide valid rspec results as XML', status: 400 and return unless testsuite

    test_run = TestRun.find_or_initialize_by(
      project: project,
      branch: branch,
      commit: commit,
      name: testsuite['name'],
      tests: testsuite['tests'],
      skipped: testsuite['skipped'],
      failures: testsuite['failures'],
      errored: testsuite['errors'],
      time: testsuite['time'],
      timestamp: testsuite['timestamp'],
      hostname: testsuite['hostname']
    )

    # Check we haven't already got this test run.
    if test_run.new_record?

      # Create the test cases
      results.css("testsuite testcase").each do |test|
        test_run.test_cases.find_or_initialize_by(
          classname: test['classname'],
          name: test['name'],
          file: test['file'],
          time: test['time'],
          skipped: test.css('skipped').present?,
          failure: test.css('failure').present? ? test.css('failure').text : nil
        )
      end

      # Save everything
      if test_run.save!
        # Kick off the GitHub comment worker
        GithubCommentWorker.perform_async(project.id, branch)

        render plain: 'Saved'
      else
        render plain: 'Something went wrong', status: 400
      end
    else
      render plain: 'Test run already in DB'
    end

  end
end
