require 'spec_helper'

describe "admin/schedules/show" do
  before(:each) do
    @admin_schedule = assign(:admin_schedule, stub_model(Admin::Schedule,
      :name => "Name",
      :active => false,
      :message => "MyText",
      :quals_tally_complete => false,
      :semis_tally_complete => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/false/)
    rendered.should match(/MyText/)
    rendered.should match(/false/)
    rendered.should match(/false/)
  end
end
