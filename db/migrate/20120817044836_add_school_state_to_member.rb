class AddSchoolStateToMember < ActiveRecord::Migration
  def change
    add_column :members, :school_state, :string
  end
end
