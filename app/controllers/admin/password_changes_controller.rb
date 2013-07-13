class Admin::PasswordChangesController < Admin::ApplicationController
  def edit
    @admin = Administrator.find(session[:admin_id])
  end

  def update
    @admin = Administrator.find(session[:admin_id])
    if Administrator.authenticate(@admin.name, params[:current_password])
      if @admin.update_attributes(params[:administrator])
        flash.now[:alert] = "Password for '#{@admin.name}' updated."
      else
        flash.now[:alert] = "Tried to update password for '#{@admin.name}', but failed."
      end
    else
      flash.now[:alert] = 'The current password you gave was incorrect.'
    end
    render 'edit'
  end
end
