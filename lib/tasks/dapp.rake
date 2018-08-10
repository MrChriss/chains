namespace :dapp do
  task :console do
    Chains::Dapp.config.validate_all
    # exec %Q(bundle exec pry -I lib -r chains/console/init.rb -e "ed, er = init;")
    exec %Q(bundle exec pry -I lib -r chains/console/init.rb)
  end

  task :setup do
    File.open('./config.rb', 'a') do |f|
      f.write(Chains::Dapp::Configuration.generate_config)
    end

    File.open('./.env', 'a') do |f|
      f.write(Chains::Dapp::Configuration.generate_env)
    end

    FileUtils.mkpath('./contracts')
  end
end
