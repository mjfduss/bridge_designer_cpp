desc 'Change password of administrator to given value.'
task :change_admin_password, [:admin_name, :new_password] => [:environment] do |t, args|
  admin = Administrator.find_by_name(args.admin_name)
  if admin
    admin.password = admin.password_confirmation = args.new_password
    admin.save!
    puts "Changed password for #{admin.inspect}."
  else
    puts "No admin #{args.name} found."
  end
end
