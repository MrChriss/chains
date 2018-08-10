module Chains
  class EthContract < EthHandler
    SUPPORTED_CONTRACT_NAMES = Dapp.config.contract_names
    CONTRACT_DATA_DIR = Dapp.config.contract_data_dir
    ETH_ADDRESS_FORMAT = /^0x[0-9a-fA-F]{40}$/

    attr_accessor :contracts

    def initialize(eth_network: 'dev')
      @contracts = {}

      SUPPORTED_CONTRACT_NAMES.each do |name|
        @contracts["#{name}s".to_sym] = []
      end

      super(eth_network: eth_network)

      build_all_contract_data
    end

    # name:(Symbol or String), args:Array, gas_limit:Integer gas_price:Integer
    def deploy(name, args=[], gas_limit=nil, gas_price=nil)
      enforce_valid_contract_name(name)

      contract = Ethereum::Contract.create(
        name: name.to_s,
        client: client,
        abi: public_send("#{name}_abi"),
        code: public_send("#{name}_bin")
      )

      contract.key = key

      if gas_limit && gas_price
        contract.gas_limit = gas_limit
        contract.gas_price = gas_price
      end

      begin
        contract.deploy_and_wait(*args)
        contracts[:"#{name}s"] << contract
        contract
      rescue IOError => e
        puts '-----------------------------------------------'
        puts e
        puts '-----------------------------------------------'
      end
    end

    # import existing contract
    # name will be used to locate abi and binary files
    # address is the address of existing deployed contract
    # name:(Symbol or String), address:String
    def import(name, address)
      enforce_valid_contract_name(name)
      enforce_valid_address(address)

      contract = Ethereum::Contract.create(
        name: name.to_s,
        address: address,
        client: client,
        abi: public_send("#{name}_abi"),
        code: public_send("#{name}_bin")
      )

      contract.key = key
      contracts[:"#{name}s"] << contract
      contract
    end

    SUPPORTED_CONTRACT_NAMES.each do |name|
      define_method("#{name}s") do
        contracts["#{name}s".to_sym]
      end
    end

    # convention:
    # dir lib/contracts/contract_data must exist
    # there should be 2 files for each contract: (abi, binary)
    # naming convention: xyz_abi, xyz_bin,
    # names must be declared in config.rb file (config.contract_names)
    # this obj will load both abi and bin
    def build_all_contract_data
      Dir.chdir(CONTRACT_DATA_DIR) do
        contract_data = SUPPORTED_CONTRACT_NAMES.map do |name|
          abi, bin = Dir.glob(%W(*#{name}_abi* *#{name}_bin*))

          { name: name, abi_file: abi, bin_file: bin }
        end

        contract_data.each do |data|
          contract_name = data[:name]
          abi = File.read(data[:abi_file]).chomp
          bin = File.read(data[:bin_file]).chomp

          instance_variable_set(:"@#{contract_name}_abi", abi)
          instance_variable_set(:"@#{contract_name}_bin", bin)

          self.class.public_send(
            :attr_accessor,
            :"#{contract_name}_abi",
            :"#{contract_name}_bin"
          )
        end
      end
    end

    def enforce_valid_contract_name(name)
      return if SUPPORTED_CONTRACT_NAMES.include?(name.to_sym)
      raise ArgumentError, "Unknown contract '#{name}'." \
        " Use one of: #{SUPPORTED_CONTRACT_NAMES.join(', ')}."
    end

    def enforce_valid_address(address)
      return if ETH_ADDRESS_FORMAT.match?(address)
      raise ArgumentError, 'Invalid ethereum address'
    end
  end
end
