namespace :key do
  task :generate, [:password] do |task, args|
    Chains::Dapp.config.enforce_key_config_existence
    Chains::KeyGenerator.new(args[:password]).generate_key
  end
end
