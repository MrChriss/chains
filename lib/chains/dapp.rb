module Chains
  class Dapp
    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end
    end
  end
end
