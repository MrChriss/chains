namespace :contract do
  task :compile, [:file, :contract_name] do |task, args|
    Chains::ContractCompiler.new(args.file, args.contract_name).compile
  end
end
