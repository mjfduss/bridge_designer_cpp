class AddSessionStateToAdministrator < ActiveRecord::Migration
  def change
    add_column :administrators, :session_state, :text
  end
end
