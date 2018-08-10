module Chains
  class KeyGenerator
    ENCRYPTED_KEY_FILE = Dapp.config.encrypted_key_file
    KEY_PASSWORD_FILE = Dapp.config.key_password_file

    attr_reader :password

    def initialize(password)
      @password = password
    end

    def generate_key
      key = Eth::Key.new
      encrypted_key_json = Eth::Key.encrypt key, password

      [ENCRYPTED_KEY_FILE, KEY_PASSWORD_FILE].each do |file|
        directory_name = File.dirname(file)
        FileUtils.mkpath(directory_name)
      end

      File.open(ENCRYPTED_KEY_FILE, 'w+') do |f|
        f.write(encrypted_key_json)
      end

      File.open(KEY_PASSWORD_FILE, 'w+') do |f|
        f.write(password)
      end

      File.open('.gitignore', 'a') do |f|
        f.write(ENCRYPTED_KEY_FILE)
        f.write("\n")
        f.write(KEY_PASSWORD_FILE)
      end
    end
  end
end
