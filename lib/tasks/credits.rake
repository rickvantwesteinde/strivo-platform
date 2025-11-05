namespace :credits do
  task :grant, [:email, :gym_id, :amount, :reason] => :environment do |_, args|
    user = Spree::User.find_by!(email: args[:email])
    gym  = Gym.find(args[:gym_id])
    reason = (args[:reason] || :manual_grant).to_sym
    Credits::Grant.call(user: user, gym: gym, amount: args[:amount], reason: reason)
    puts "Granted #{args[:amount]} to #{user.email} @ #{gym.id}"
  end

  task :spend, [:email, :gym_id, :amount, :reason] => :environment do |_, args|
    user = Spree::User.find_by!(email: args[:email])
    gym  = Gym.find(args[:gym_id])
    reason = (args[:reason] || :booking).to_sym
    Credits::Spend.call(user: user, gym: gym, amount: args[:amount], reason: reason)
    puts "Spent #{args[:amount]} from #{user.email} @ #{gym.id}"
  end

  task :balance, [:email, :gym_id] => :environment do |_, args|
    user = Spree::User.find_by!(email: args[:email])
    gym  = Gym.find(args[:gym_id])
    puts CreditLedger.balance_for(user: user, gym: gym)
  end
end
