require 'spec_helper'

describe Team do

  before {
    Team.where("name_key='beatnavy'").each{ |t| t.delete }
    @team = Team.new(:name => 'Beat Navy')
    @team.captain = Member.create(:first_name => 'Navy',
                                  :last_name => 'Goat',
                                  :category => 'u');
  }

  after {
    @team.captain.delete unless @team.captain.nil?
  }

  subject { @team }
  
  it { should respond_to(:name) }
  it { should respond_to(:name_key) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:email) }
  it { should respond_to(:submits) }
  it { should respond_to(:improves) }
  it { should respond_to(:captain) }
  it { should respond_to(:members) }
  
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "when name is blank" do
    before { @team.name = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @team.name = 'x' * 33 }
    it { should_not be_valid }
  end

  describe "when name is already taken" do
    before do
      team_with_same_name = @team.dup
      team_with_same_name.name.upcase!
      team_with_same_name.save
    end
    it { should_not be_valid }
  end

  # ---- Completed team tests ----

  before { 
    @team.email = "goat@usna.edu"
    @team.password = "Go Army 1978!"
    @team.password_confirmation = "Go Army 1978!"
    @team.completed = true 
  }

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @team.email = invalid_address
        @team.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @team.email = valid_address
        @team.should be_valid
      end
    end
  end

  describe "when email is convered from mixed to lower case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }
    it "should be saved as all lower-case" do
      @team.email = mixed_case_email
      @team.save
      @team.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "when email is blank" do
    before { @team.email = " " }
    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @team.password = @team.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "Password not matching confirmation" do
    before { @team.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @team.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when password is too short" do
    before { @team.password = @team.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do

    before { @team.save }

    let(:found_team) { Team.find_by_name_key(@team.name_key) }

    describe "with valid password" do
      it { should == found_team.authenticate(@team.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_team.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end

  end
end
