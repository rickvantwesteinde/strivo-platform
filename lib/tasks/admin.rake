namespace :admin do
  desc "Create admin if ADMIN_EMAIL/PASSWORD present"
  task create: :environment do
    email = ENV['ADMIN_EMAIL']
    pass = ENV['ADMIN_PASSWORD']
    abort "Missing ADMIN_EMAIL/ADMIN_PASSWORD" unless email && pass

    user = Spree::User.find_or_create_by!(email: email) do |u|
      u.password = pass
      u.password_confirmation = pass
    end

    user.spree_roles << Spree::Role.find_or_create_by!(name: 'admin')

    puts "OK admin: #{email}"
  end
end
