# Listen for incoming webhooks from GitHub.
class Webhooks::GithubController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_with_balrog!

  def create
    action = request.request_parameters[:action]

    unless request.headers["X-GitHub-Event"] == "installation"
      render status: 204, plain: '' and return
    end

    installation_id = params[:installation][:id]

    if action == "created"
      # Check all the repos we have access to, and find any that are in our DB.
      repos = params[:repositories]

      repos.each do |repo|
        # Find the project that's in our DB, if there is one. This is a bit ugly,
        # but it works for now, and we might want to change how all this works
        # when we let people sign in with Github anyway.
        project = Project.all.find{ |project| project.repo == repo[:full_name] }

        next if project.nil?

        # Save the installation id
        unless project.update(github_installation_id: installation_id)
          puts "Something went wrong updating project #{project.id}"
        end
      end
    end

    render status: 204, plain: ''
  end

end
