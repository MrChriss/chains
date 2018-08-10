module Chains
  class Dapp
    class Configuration
      REQUIRED_ATTRIBUTES = %i(
        eth_networks
        contract_data_dir
        contract_names
        encrypted_key_file
        key_password_file
        contract_file_location
      )

      OPTIONAL_ATTRIBUTES = %i(
        dev_node
        ropsten_node
        kovan_node
        rinkeby_node
        mainnet_node
      )

      attr_accessor *REQUIRED_ATTRIBUTES, *OPTIONAL_ATTRIBUTES

      def validate_all
        enforce_required_config
        enforce_contract_names
        enforce_contract_data_existence
        enforce_key_data_existence
      end

      def contract_data_dir=(new_value)
        @contract_data_dir = new_value.chomp('/')
      end

      def contract_file_location=(new_value)
        @contract_file_location = new_value.chomp('/')
      end

      def encrypted_key_file=(new_value)
        @encrypted_key_file = new_value.chomp('/')
      end

      def key_password_file=(new_value)
        @key_password_file = new_value.chomp('/')
      end

      def contract_names
        @contract_names || []
      end

      def enforce_key_config_existence
        key_config_attrs = %w(encrypted_key_file key_password_file)

        missing_key_config = key_config_attrs.select do |key_config|
          public_send(key_config)
        end

        return unless missing_key_config.empty?

        raise ConfigurationError, 'Missing configuration for: ' \
          "#{missing_key_config.join(', ')}. " \
          'Make sure those values are present and set in your config.rb file.'
      end

      def self.generate_config
        <<~EOS
          Chains::Dapp.configure do |config|
            config.eth_networks = %w(dev ropsten mainnet)
            config.encrypted_key_file = './key_data/key.json'
            config.key_password_file = './key_data/key_password'
            config.contract_names = %i(greeter)
            config.contract_data_dir = './contracts/contract_data'
            config.contract_file_location = './contracts'
            config.dev_node = ENV.fetch('DEV_NODE')
            config.ropsten_node = ENV.fetch('ROPSTEN_INFURA')
            config.mainnet_node = ENV.fetch('MAINNET_INFURA')
          end
        EOS
      end

      def self.generate_env
        <<~EOS
          DEV_NODE=http://localhost:8545
          ROPSTEN_INFURA=https://ropsten.infura.io/your_secret_key
          MAINNET_INFURA=https://mainnet.infura.io/your_secret_key
        EOS
      end

      private
      def enforce_key_data_existence
        return if File.exists?(encrypted_key_file) && File.exists?(key_password_file)

        raise ConfigurationError, "Encrypted key file missing: " \
          "#{encrypted_key_file} " \
          "Run: 'rake app:generate_wallet[your_pass, your_destination]' " \
          "to generate a new key."
      end

      def generate_required_file_names(names)
        names.flat_map { |name| %W(#{name}_abi #{name}_bin) }
      end

      def enforce_required_config
        optional_attrs = OPTIONAL_ATTRIBUTES.select { |attr| public_send(attr) }
        missing_required_attrs = REQUIRED_ATTRIBUTES.reject { |attr| public_send(attr) }

        return if missing_required_attrs.empty? && optional_attrs.any?

        raise ConfigurationError, generate_error_message(
          optional_attrs,
          missing_required_attrs
        )
      end

      def enforce_contract_data_existence
        Dir.chdir(contract_data_dir) do
          missing_contract_data = contract_names.reject do |name|
            Dir.glob(%W(*#{name}_abi* *#{name}_bin*)).size == 2
          end

          return if missing_contract_data.empty?

          raise ConfigurationError, "Data files for " \
            "#{missing_contract_data.join(', ')} are missing " \
            "in #{contract_data_dir}, " \
            "(from your config file: config.contract_names). " \
            "Please make sure following files exist in #{contract_data_dir}: " \
            "#{generate_required_file_names(missing_contract_data).join(', ')}. " \
            'You can generate these files with ' \
            '`rake contract:compile[file, ContractName]`'
        end
      end

      def enforce_contract_names
        return unless contract_names.empty?

        raise ConfigurationError, 'You did not provide any contract names ' \
          'in your config.rb file. Fill in `config.contract_names` with the ' \
          'names of the contracts you would like to interact with.'
      end

      def generate_error_message(optional_attrs, missing_required_attrs)
        required_attrs_message = 'Required configuration attributes missing: ' \
        "#{missing_required_attrs.join(', ')}. " \
        "Create config.rb file in " \
        'root of the project, and fill in all of the following values: ' \
        "#{REQUIRED_ATTRIBUTES.join(', ')}. " \

        optional_attrs_message = 'Optional configuration attributes missing. ' \
          "Create config.rb file in " \
          'root of the project, and fill in any of the following values: ' \
          "#{OPTIONAL_ATTRIBUTES.join(', ')}."

        if missing_required_attrs.any? && optional_attrs.empty?
          required_attrs_message + optional_attrs_message
        elsif optional_attrs.empty?
          optional_attrs_message
        elsif missing_required_attrs.any?
          required_attrs_message
        end
      end
    end
  end
end
