class ProjectsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :find_project, except: [:index, :new, :create]

  def index
    @projects = Project.all.order(:created_at).includes(:test_runs)
  end

  def show
    unless @project.test_runs.any?
      render :show and return
    end

    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
    end

    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
    end

    @branches = @project.test_runs.distinct.pluck(:branch).sort
    @current_branch = @branches.include?('master') ? 'master' : @branches.first

    if params[:branch].present?
      @current_branch = params[:branch]
    end

    test_runs = @project.test_runs.where(branch: @current_branch)

    if start_date && end_date
      if end_date < start_date
        # Validate start date is before end date and notify user
        flash.now[:alert] = "The start date needs to be before the end date."
      else
        # Find the nearest test runs to the start and end
        @first_run = test_runs.where("timestamp <= ?", start_date).order("timestamp DESC").first
        @last_run = test_runs.where("timestamp >= ?", end_date).order("timestamp ASC").first
      end
    end

    # Otherwise, get the first and last test runs for this project
    ordered_test_runs = test_runs.order("timestamp asc")
    @first_run = @first_run || ordered_test_runs.first
    @last_run = @last_run || ordered_test_runs.last

    @diff = Diff.new(@first_run, @last_run).all(sort_column, sort_direction)
  end

  # Compare two test runs against each other, given their commit shas.
  def compare
    @base = TestRun.find_by(commit: params[:base])
    @compare = TestRun.find_by(commit: params[:compare])

    if @base.nil? || @compare.nil?
      redirect_to project_path(@project), alert: 'Could not find those test runs, sorry!'
      return
    end

    @diff = Diff.new(@base, @compare)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to project_path(@project), notice: 'Project created'
    else
      render :new
    end
  end

  def settings; end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to project_path(@project), notice: 'Project updated'
    else
      render :edit
    end
  end

  def destroy
    if @project.destroy
      redirect_to projects_path, notice: 'Project deleted'
    else
      redirect_to projects_path, alert: 'Something went wrong'
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :github_url)
  end

  def find_project
    @project = Project.find params[:id]
  end

  # These are the different column names of the result of a diff
  # The defult value for the sort column is the time_diff
  def sort_column
    %w[name time_diff last_run_time first_run_time].include?(params[:sort]) ? params[:sort] : "time_diff"
  end

  # The defult value for the sort direction is desc
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
