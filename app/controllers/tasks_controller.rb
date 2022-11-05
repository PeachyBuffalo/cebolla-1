class TasksController < AuthedController
  before_action :set_task,
                only: %i[complete destroy edit resolve show start unstart update]
  before_action :set_project, only: %i[create destroy edit new show]

  def complete
    change_state :closed
  end

  def create
    @project.tasks.create!(task_params)
    redirect_to @project
  end

  def edit
    @projects = @project.customer.projects
  end

  def destroy
    @task.destroy!
    flash[:success] = "Removed task #{@task.subject}"
    redirect_to project_path(@project)
  end

  def index
    @tasks = Task.where('state IN (1, 2, 3) OR updated_at > ?', 1.week.ago)
  end

  def resolve
    change_state :resolved
  end

  def start
    change_state :in_progress
  end

  def unstart
    change_state :brand_new
  end

  def update
    @task.update!(task_params)
    redirect_to task_path(@task)
  end

  private

  def change_state(new_state)
    @task.update!(state: new_state)
    flash[:success] = "Moved task #{@task.id} to #{@task.state.titleize}"
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.full_messages
  ensure
    redirect_to tasks_path
  end


  def set_task
    @task = Task.find(params[:id])
  end

  def set_project
    if @task
      @project = @task.project
    else
      @project = Project.find(params[:project_id])
    end
  end

  def task_params
    params.require(:task)
          .permit(:subject,
                  :project_id,
                  :description,
                  :est_hours,
                  :state,
                  :kind)
  end
end
