class Admin::SchedulesController < Admin::ApplicationController

  def edit
    @schedules = Schedule.order('active DESC, name ASC')
    @active_schedule = Schedule.find_by_active(true)
    @edited_schedule = @active_schedule || Schedule.new
  end

  def update
    selected = params[:select]
    if params.nonblank? :get
      if selected.blank?
        @edited_schedule = Schedule.new
        flash.now[:alert] = 'New schedule ready to edit.'
      else
        @edited_schedule = Schedule.find(selected[0].to_i)
        flash.now[:alert] = 'Selected schedule ready to edit.'
      end
    elsif params.nonblank? :update
      id = params[:schedule][:id]
      if id.blank?
        @edited_schedule = Schedule.create(params[:schedule])
        if @edited_schedule.valid?
          reset_active(@edited_schedule)
          flash.now[:alert] = "New schedule '#{@edited_schedule.name}' was created."
        else
          flash.now[:alert] = 'New schedule could not be created.'
        end
      else
        @edited_schedule = Schedule.find(id.to_i)
        if @edited_schedule && @edited_schedule.update_attributes(params[:schedule])
          reset_active(@edited_schedule)
          flash.now[:alert] = "Schedule '#{@edited_schedule.name}' was updated."
        else
          flash.now[:alert] = 'Could not update schedule.'
        end
      end
    elsif params.nonblank? :delete
      if selected.blank?
        flash.now[:alert] = 'No schedules were selected for deletion.'
      elsif selected_includes_active?(selected)
        flash.now[:alert] = 'The active schedule cannot be deleted. Activate another first.'
      else
        Schedule.destroy(selected)
        flash.now[:alert] = 'Selected schedules were deleted.'
      end
      id = params[:schedule][:id]
      @edited_schedule = id.blank? ? Schedule.new : (Schedule.find(id.to_i) || Schedule.new)
    end
    @schedules = Schedule.order('active DESC, name ASC')
    @active_schedule = @schedules.find { |schedule| schedule.active? }
    render :action => :edit
  end

  private

  def selected_includes_active?(selected)
    active = Schedule.find_by_active(true)
    active && selected.any? { |id| id.to_i == active.id }
  end

  def reset_active(schedule)
    if schedule.active?
      Schedule.update_all({ :active => false }, ['id <> ?', schedule.id])
      Schedule.expire_cache
    end
  end

end
