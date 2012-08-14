require 'spec_helper'

describe "Registrations" do

  describe "Login/Register Page" do
    it "should have content" do
      
      visit new_session_path
      page.should have_content('Register and Log In')
    end
  end

end
