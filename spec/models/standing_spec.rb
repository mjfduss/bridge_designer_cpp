require 'spec_helper'

describe Standing do

  before(:all) do
    REDIS.flushall
    n_teams = 1000
    @teams = []
    (1..n_teams).each do |id|
      team = Team.new
      team.category = 'e'
      team.id = id
      @teams << team
    end
    @teams.shuffle!
    n_designs = 3000
    @designs = []
    (1..n_designs).each do |id|
      design = Design.new
      design.id = id
      design.team_id = @teams[(id - 1) % n_teams].id
      design.sequence = id
      design.score = ((id - 1) % n_teams + 1) * 1000
      @designs << design
    end
    @designs.shuffle!
    @designs.each { |design| Standing.insert(@teams[(design.id - 1) % n_teams], design) }
  end

  after(:all) do
    REDIS.flushall
  end

  it "should have correct number of inserted teams" do
    Standing.team_count('e').should eq(@teams.length)
  end
  
  it "should have correct number of inserted scores" do
    Standing.score_count('e').should eq(@teams.length)
  end
  
  it "should retrieve all ranks" do
    accum = [:empty]
    saw_nil_standing = false;
    @teams.each do |team|
      standing = Standing.standing(team).first
      if standing
        accum[standing] = team
      else
        saw_nil_standing = true
      end
    end
    good_accum = accum.length == @teams.length + 1 && !accum.include?(nil)
    good_accum.should be_true
  end
  
  it "should interpolate ranks correctly" do
    saw_bad_standing = false
    designs_per_score = (@designs.length + @teams.length - 1) / @teams.length
    @designs.each do |design|
      team = @teams[(design.id - 1) % @teams.length]
      interpolation = Standing.interpolated_standing(team, design.score).first
      standing = Standing.standing(team).first
      saw_bad_standing = true if standing.nil? || (interpolation - standing) > designs_per_score
    end
    saw_bad_standing.should be_false
  end

  it "should delete cleanly" do
    @teams.each { |team| Standing.delete(team) }
    clean_delete = Standing.team_count('e') == 0 && Standing.score_count('e') == 0
    clean_delete.should be_true
  end

end
