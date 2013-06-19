require 'spec_helper'

describe Design do

  before {
    @good = build(:design)
  }

  subject { @good }

  it { should respond_to(:bridge) }
  it { should respond_to(:scenario) }
  it { should respond_to(:sequence) }
  it { should respond_to(:hash_string) }
  it { should respond_to(:score) }

  it { should be_valid }

  describe "when bridge is missing" do
    before { @good.bridge = nil }
    it { should_not be_valid }
  end

  describe "when scenario is missing" do
    before { @good.scenario = nil }
    it { should_not be_valid }
  end

  describe "when scenario is wrong length" do
    before { @good.scenario = 'x' * 41 }
    it { should_not be_valid }
  end

  describe "when save is not an improvement" do
    before {
      @team = create(:team)
      @cheap = create(:expensive_design, :team => @team)
      @expensive = build(:cheap_design, :team => @team)
    }
    after {
      @team.destroy
      @cheap.destroy
    }

    it { @cheap.should_not be_valid }
  end

  describe "when bests are recorded correctly" do
    before {
      @team = create(:team)
      @expensive = create(:expensive_design, :team => @team)
      @cheap = create(:cheap_design, :team => @team)
    }
    after {
      @team.destroy
      @expensive.destroy
      @cheap.destroy
    }

    it { Best.find_by_team_id(@team.id).design_id == @cheap.id }
  end

end
