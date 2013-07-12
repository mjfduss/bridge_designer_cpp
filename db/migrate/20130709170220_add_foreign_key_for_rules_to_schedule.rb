class AddForeignKeyForRulesToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :semis_instructions_id, :integer
  end
end
