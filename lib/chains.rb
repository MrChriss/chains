require 'pry'
require 'dotenv/load'

# ethereum
require 'ethereum.rb'
require 'eth'

module Chains
  # config
  require './lib/chains/dapp.rb'
  require './lib/chains/configuration/configuration_error.rb'
  require './lib/chains/configuration'
  require './config.rb' if File.exists?('./config.rb')

  # lib
  require './lib/chains/key_generator'
  require './lib/chains/eth_handler'
  require './lib/chains/eth_contract'
  require './lib/chains/contract_compiler'
end
