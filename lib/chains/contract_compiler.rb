module Chains
  class ContractCompiler
    CONTRACT_DATA_DIR = Dapp.config.contract_data_dir
    CONTRACT_FILE_LOCATION = Dapp.config.contract_file_location

    attr_reader :file, :contract_name, :data, :abi, :bin

    def initialize(file, contract_name)
      @file = file
      @contract_name = contract_name
    end

    def compile
      enforce_solc_installation
      parse_contract_data
      write_contract_data_to_file
    end

    private
    def parse_contract_data
      solc_compilation_output = `solc #{CONTRACT_FILE_LOCATION}/#{file} \
        --abi --bin --optimize --optimize-runs 500`

        @data = solc_compilation_output
          .split(/(?=\s={7}\s.+\s={7}\s)/)
          .detect { |d| d.match?(/\s={7}\s\S+:#{contract_name}\s={7}\s/) }

      enforce_valid_contract_name(solc_compilation_output)

      @abi = data.match(/Contract\sJSON\sABI\s\s(.*)/).captures.first
      @bin = data.match(/Binary:\s\s(\w*)/).captures.first
    end

    def write_contract_data_to_file
      FileUtils.mkpath(CONTRACT_DATA_DIR)
      underscored_file_name = simple_underscore(contract_name)

      File.open("#{CONTRACT_DATA_DIR}/#{underscored_file_name}_abi.rb", "w+") do |f|
        f.write abi
      end

      File.open("#{CONTRACT_DATA_DIR}/#{underscored_file_name}_bin.rb", "w+") do |f|
        f.write bin
      end
    end

    def simple_underscore(camel_case_string)
      regex = %r{(?=[A-Z])}
      return camel_case_string unless camel_case_string.match?(regex)
      camel_case_string.split(regex).map(&:downcase).join('_')
    end

    def enforce_valid_contract_name(solc_compilation_output)
      return unless data.nil?

      existing_names = solc_compilation_output
        .scan(/\s={7}\s\S+:(\w+)\s={7}\s/)
        .flatten

      raise ArgumentError, "There is no contract named: '#{contract_name}' " \
        "in file: '#{file}'. " \
        "Use one of these: #{existing_names.join(', ')}." \
    end

    def enforce_solc_installation
      `solc --version`
      return if $?.success?

      raise SystemCallError, "Solidity compiler is not installed"
    end
  end
end
