require 'spec_helper'

describe "admin/schedules/new" do
  before(:each) do
    assign(:admin_schedule, stub_model(Admin::Schedule,
      :name => "MyString",
      :active => false,
      :message => "MyText",
      :quals_tally_complete => false,
      :semis_tally_complete => false
    ).as_new_record)
  end

  it "renders new admin_schedule form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_schedules_path, "post" do
      assert_select "input#admin_schedule_name[name=?]", "admin_schedule[name]"
      assert_select "input#admin_schedule_active[name=?]", "admin_schedule[active]"
      assert_select "textarea#admin_schedule_message[name=?]", "admin_schedule[message]"
      assert_select "input#admin_schedule_quals_tally_complete[name=?]", "admin_schedule[quals_tally_complete]"
      assert_select "input#admin_schedule_semis_tally_complete[name=?]", "admin_schedule[semis_tally_complete]"
    end
  end
end
