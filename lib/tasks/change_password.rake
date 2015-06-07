desc 'Change password of given user to given value.'
task :change_password, [:team_name, :new_password] => [:environment] do |t, args|
  team = Team.find_by_name_key(Team.to_name_key(args.team_name.strip))
  if team
    team.password = team.password_confirmation = args.new_password
    team.save!
    puts "Changed password for #{team.inspect}."
  else
    puts "No team #{args.team_name} found."
  end
end
