class Admin::LocalContestsController < Admin::ApplicationController

  def edit
    @local_contests = LocalContest.all
    @edited_local_contest = LocalContest.new
  end

  def update
    s = params[:select]
    if !params[:get].blank?
      if s.blank?
        @edited_local_contest = LocalContest.new
        flash.now[:alert] = 'New local contest ready to edit.'
      else
        @edited_local_contest = LocalContest.find(s[0].to_i)
        flash.now[:alert] = 'Selected local contest ready to edit.'
      end
    elsif !params[:update].blank?
      id = params[:local_contest][:id]
      if id.blank?
        lc = LocalContest.create(params[:local_contest])
        if lc.valid?
          flash.now[:alert] = "New local contest '#{params[:local_contest][:code]}' was created."
          @edited_local_contest = LocalContest.new
        else
          flash.now[:alert] = "New local contest could not be created."
          @edited_local_contest = lc
        end
      else
        @edited_local_contest = LocalContest.find(id.to_i)
        @edited_local_contest.update_attributes(params[:local_contest])
        flash.now[:alert] = "Local contest '#{params[:local_contest][:code]}' was updated."
      end
    elsif !params[:delete].blank?
      if s.blank?
        flash.now[:alert] = 'No local contests were selected for deletion.'
      else
        LocalContest.delete(s)
        flash.now[:alert] = 'Selected local contests were deleted.'
      end
      @edited_local_contest = LocalContest.new
    end
    @local_contests = LocalContest.all
    render :action => :edit
  end
end
