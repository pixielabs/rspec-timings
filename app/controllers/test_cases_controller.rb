class TestCasesController < ApplicationController

  def show
    @project = Project.find(params[:project_id])
    @test_cases = @project.test_cases.where(hash_code: params[:id]).order('timestamp asc')
    @chart_data = @test_cases.map {|test| [test.test_run.timestamp, test.time.to_f] }
  end

end
