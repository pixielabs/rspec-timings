class GithubCommentWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  def perform(project_id, branch)
    project = Project.find(project_id)

    # Do nothing if the Github app hasn't been installed
    return unless project.github_installation_id

    # Check to see if there is an open PR for this branch
    # TODO: what if the test run we received was from the base branch? Do we
    # want to update our comment on open PRs with that base?
    pulls = github_client_for(project).pull_requests(project.repo, state: 'open', head: "#{project.organisation}:#{branch}")

    if pulls.none?
      puts "No open pull request found for branch #{project.organisation}:#{branch} in repo #{project.repo}"
      return
    end

    pull = pulls.first
    pull_request_number = pull[:number]
    base_commit = pull[:base][:sha]
    # We could also use the commit we were given with the test results here, but
    # I guess it could be possible that the one we received wasn't the latest
    # commit on the branch? We may wish to check that we definitely have the
    # results for this compare_commit in our DB, but this is fine for now.
    compare_commit = pull[:head][:sha]

    base_run = project.test_runs.find_by(commit: base_commit)
    compare_run = project.test_runs.find_by(commit: compare_commit)

    # Create the table to show in our Github comment
    diff = Diff.new(base_run, compare_run)
    diff_table = ""
    diff.top_five.each do |test|
      diff_table += "|#{test['name']}|#{test['first_run_time']}s|#{test['last_run_time']}s|#{test['time_diff']}s|\n"
    end

    comment = <<~EOS
    RSpec-timings Report
    ==========

    Here are the top five biggest diffs:

    | Test | Base test run time | Compare test run time | Change in run time |
    |------|--------------------|-----------------------|--------------------|
    #{diff_table}
    <br/>

    [View the full diff between these branches](#{compare_project_url(project, base: base_commit, compare: compare_commit)})
    EOS

    # Check for a previously added comment and update it if there is one.
    comments = github_client_for(project).issue_comments(project.repo, pull_request_number)
    previous_comment = comments.find { |comment| comment[:user][:login] == 'rspec-timings[bot]' }

    if previous_comment
      puts "Updating previous comment"
      github_client_for(project).update_comment(project.repo, previous_comment[:id], comment)

      # That's it, we're done!
      return
    end

    # Otherwise, add a comment with a link to the diff.
    puts "Adding comment"
    github_client_for(project).add_comment(project.repo, pull_request_number, comment)
  end

  private

  def github_client_for(project)
    current = Time.current.to_i

    key = {
      iat: current,
      exp: current + (10 * 60),
      iss: ENV['GITHUB_APP_ID']
    }
    jwt = JWT.encode(key, github_app_private_key, 'RS256')

    bearer_client = Octokit::Client.new(bearer_token: jwt)
    installation_id = project.github_installation_id
    access_token = bearer_client.create_app_installation_access_token(installation_id)[:token]

    Octokit::Client.new(access_token: access_token)
  end

  def github_app_private_key
    @github_app_private_key ||= OpenSSL::PKey::RSA.new(ENV['GITHUB_PRIVATE_KEY'])
  end
end
