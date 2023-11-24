class AddGithubUrlToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :github_url, :string
  end
end
