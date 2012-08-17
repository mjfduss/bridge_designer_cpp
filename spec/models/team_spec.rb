require 'spec_helper'

describe Team do
  before { @team = Team.new(:name => 'Beat Navy',
                            :email => 'beatnavy@usma.edu',
                            :submits => 0) }
  subject { @team }
  
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:submits) }
  it { should respond_to(:group) }
  it { should respond_to(:captain) }
end
