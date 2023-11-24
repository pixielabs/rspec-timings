class AddGithubInstallationIdToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :github_installation_id, :integer
  end
end
