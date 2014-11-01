# Make and administrator account.
#Administrator.delete_all
%w{gene steve cathy joanna}.each {|name| Administrator.find_or_create_by_name(:name => name, :password => 'foobarbaz', :password_confirmation => 'foobarbaz') }

# Load old local contest data.
if true
  File.open('db/seeds_data/dbo.local_contest.txt', 'r') do |f|
    # Get column names.
    line = f.gets
    return unless line
    line.chomp!
    # Make list of symbols for setters taken from column names
    setters = line.split.map{|s| s == '-' ? nil : "#{s}=".to_sym }
    n = 0
    while line = f.gets
      line.chomp!
      data = line.split("\t").map {|s| s.strip }
      lc = LocalContest.new {|lc| setters.zip(data).each{|p| lc.send(*p) if p[0] } }
      n += 1 if lc.save
    end
    puts "Created #{n} local contests."
  end
end

# For development, use factory girl to build some records.
if false && Rails.env.development?
  REDIS.flushall
  Team.delete_all
  Member.delete_all
  Design.delete_all
  Best.delete_all
  LocalContest.delete_all
  Affiliation.delete_all
  # Reset the design sequence number generator.
  seq = SequenceNumber.find_by_tag('design')
  seq.update_attribute(:value, 0) if seq
  50.times do |n|
    FactoryGirl.create(:local_contest)
  end
  lc = LocalContest.all
  195.times do |n|
    # Team with one member and one designs
    team = FactoryGirl.create(:team)
    FactoryGirl.create(:design, :team => team)
    # Team with two members and one designs
    team = FactoryGirl.create(:team, :member_count => 2)
    FactoryGirl.create(:design, :team => team)
    team.local_contests << lc[rand(lc.size)]
  end
end
