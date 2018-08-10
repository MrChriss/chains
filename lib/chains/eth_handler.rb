module Chains
  class EthHandler
    SUPPORTED_NETWORKS = Dapp.config.eth_networks

    attr_reader :key, :client, :eth_network

    def initialize(eth_network:)
      enforce_valid_eth_network(eth_network)

      @eth_network = eth_network
      @key = decrypt_key
      @client = build_client
    end

    private
    def decrypt_key
      Eth::Key.decrypt(
        File.read(Dapp.config.encrypted_key_file),
        File.read(Dapp.config.key_password_file).chomp
      )
    end

    def build_client
      node_url = Dapp.config.public_send("#{eth_network}_node")

      client = Ethereum::HttpClient.new(node_url)
      client.default_account = key.address
      client
    end

    def enforce_valid_eth_network(network)
      return if SUPPORTED_NETWORKS.include?(network)
      raise ArgumentError, "Ethereum network: '#{network}' is not supported." \
        " Use one of: #{SUPPORTED_NETWORKS.join(', ')}."
    end
  end
end
