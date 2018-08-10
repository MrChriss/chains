# Wellcome to Ruby On Chains
Note: Chains is beta software. At some point it will be released as gem.

Ruby On Chains bundles up the functionality of `ethereum.rb` and `ruby-eth`.
Chains is meant to simplify your life when interacting with ethereum blockchain through ruby.
The aim is to reduce the overhead of building the contract objects,
compiling and parsing abis and binaries, signing transactions, connecting to nodes, etc.
Setup your config file then run the console where you can deploy, test or interact
with ethereum smart contracts in no time.

Chains was developed while working with [Verity](https://alpha.eventum.network/),
formerly known as [Eventum](https://alpha.eventum.network/).
Our main focus was automation of contract development, deployment and testing.

Make sure you check these two out to have a better understanding of how it all works.
- ethereum.rb: https://github.com/EthWorks/ethereum.rb
- ruby-eth: https://github.com/se3000/ruby-eth

## Installation guide
- install rvm if not installed yet -> `https://rvm.io/rvm/install`
- install ruby 2.5.1 -> `rvm install 2.5.1`
- install bundler -> `gem install bundler`
- navigate to project and install dependencies -> `bundle install`
- generate config file -> `rake dapp:setup`
- generate a new ethereum wallet -> `rake 'key:generate[your_secure_password]'`

## Setup
- Create `config.rb` file in root of the project or run `rake dapp:setup`
- `rake dapp:setup` will generate sample `config.rb` file for you
- fill in the file with required values
- start pry with environment loaded -> `rake dapp:console` or run `./bin/chains`

## Config
Here is a sample `config.rb` file
```ruby
  Chains::Dapp.configure do |config|
    config.eth_networks = %w(dev ropsten mainnet)
    config.encrypted_key_file = './key_data/key.json'
    config.key_password_file = './key_data/key_password'
    config.contract_names = %i(greeter mortal)
    config.contract_data_dir = './contracts/contract_data'
    config.contract_file_location = './contracts'
    config.dev_node = 'http://localhost:8545'
    config.ropsten_node = 'https://ropsten.infura.io/your_secret_key'
    config.mainnet_node = 'https://mainnet.infura.io/your_secret_key'
  end
```

#### Required attributes
All of these attributes must have a value in config file.

##### eth_networks
Networks on which you will be able to deploy contracts.

##### contract_names
You must declare what contract you will be deploying and interacting with.
It is expected that `your_contract_abi` and `your_contract_bin` files exist in `contract_data_dir`

##### contract_file_location
This is the folder where you have your smart contracts stored.
This attribute is used when you compile smart contracts via `rake 'contract:compile[my_contract.sol, MyContract]'` command.
Chains will look for `my_contract.sol` in `contract_file_location`.
Remember to pass in `MyContract` contract name, where `MyContract` is the actual contract name
in your solidity code.
Chains uses `MyContract` contract name to parse the compilation output.

##### contract_data_dir
Directory containing contract data. There must be two files present for each contract:
- abi (json)
- binary
You can obtain those by compiling your smart contract via remix, parity-ui or other means.
If you have solidity installed on your machine, you can run the following command to compile and generate those files with `rake 'contract:compile[my_contract.sol, MyContract]'`
Chains will search for `my_contract.sol` in `contract_file_location`
you have specified in `config.rb`.
Remember to pass in `MyContract` contract name, where `MyContract` is the actual contract name
in your solidity code.
Chains uses `MyContract` contract name to parse the compilation output.
Chains will create two files: `my_contract_abi.rb` and `my_contract_json.rb` and place them in
`contract_data_dir` you specified in `config.rb`

These files are used to deploy or import the contracts and interact with them.

##### Key generation and importing
Before you read this: note that you are responsible for your own safety.
Storing passwords in files might be risky, pushing such files to a public repo - even more so.

- you do not have a key yet
You can generate a new key by running `rake 'key:generate[your_secure_password]'`
Chains will generate two files: `encrypted_key_file` and `key_password_file` you specified in
`config.rb`.
Supply the path to these files in your `config.rb` file and Chains will generate
them.
Example:
If the following line is present in your `config.rb` file:
`config.encrypted_key_file = './key_data/my_awesome_key.json'`
`config.key_password_file = './key_data/my_awesome_key.txt'`
When your run `rake key:generate[your_secure_password]`, Chains will
create a new `key_data` folder, containing `my_awesome_key.json` and
`my_awesome_key.txt` files.
Chains will also add both files to `.gitignore`

- you already have a key
Set `encrypted_key_file` and `key_password_file` in your `config.rb` to point to
your (private) key - json file, and supply a password file in text format.
Chains will automatically pick those up when you start the console.

##### encrypted_key_file
This is an encrypted key file, it is used to sign transactions.
This file can be imported to metamask.
You can generate a new `encrypted_key_file` file by running
`rake 'key:generate[your_secure_password]'`.
Chains will read this file and set up the key so you can transact and interact with
ethereum blockchain.
Look at 'Key generation and importing' section for more information.

##### key_password_file
Password is needed to decrypt the encrypted key and sign transactions.
Chains will read this file and set up the key so you can transact and interact with
ethereum blockchain.
Look at 'Key generation and importing' section for more information.

#### Optional attributes
At least one of the following values must be present in config file
Their values must be urls to eth node eg: `https://mainnet.infura.io/my_secret_token`
This will be the node to which `instance.client` will connect to.
- dev_node
- ropsten_node
- kovan_node
- rinkeby_node
- mainnet_node

If you are running parity via `parity --chain dev` or similar command, you can set
`config.dev_node = http://localhost:8545` and start playing.

## Usage
Chains bundles up the functionality found in `ethereum.rb` and `ruby-eth`, with
a very thin api to make your life easier.

See `ethereum.rb` and `ruby-eth` gems for more on how to interact with contracts,
ethereum blockchain, generate keys, send raw transactions etc.
- ethereum.rb: https://github.com/EthWorks/ethereum.rb
- ruby-eth: https://github.com/se3000/ruby-eth

If you ever find your self typing the same things in the console over and over again,
perhaps when you are testing something out:
Fill in the `./lib/chains/console/init.rb` with methods that encapsulate that functionality
and those methods will be available to you in the console.
Note that local variables will not be available.

Start pry console with environment loaded.
Run `rake dapp:console` or `./bin/chains` and follow along.

```ruby
  # you can use any of the networks specified in config.rb, if you supply no argument, it will default to 'dev'
  instance = Chains::EthContract.new(eth_network: 'ropsten')

  # Snipet from Chains::EthContract
  # name:(Symbol or String), args:Array, gas_limit:Integer gas_price:Integer
  def deploy(name, args=[], gas_limit=nil, gas_price=nil)
  ...

  # returns contract instance see ethereum.rb gem for more on how to interact with it
  my_token = instance.deploy('my_token')
  => #<MyToken:000000000000000000>

  my_token.address
  => #0x0000000000000eth_address0000000000000000
  my_token.call.initial_supply
  => #500000000

  # this will work too
  other_token = instance.deploy(:other_token)
  => #<OtherToken:000000000000000000>

  # when you need to supply constructor arguments for your smart contract
  # supply them in array format as the second argument
  simple_contract = instance.deploy(:my_contract, ["Args", 1, true])
  => #<SimpleContract:000000000000000000>

  # when you neeed to increase gas price or gas limit
  # you can pass that as third or fourth arguments
  # note that both need to be present
  huge_contract = instance.deploy('huge_contract', ["Args"], 4000000, 22000000000)
  => #<HugeContract:000000000000000000>

  # you can check or set gas_price and gas_limit values on client or per contract basis
  # client
  instance.client.gas_price
  => #4000000
  instance.client.gas_limit
  => #22000000000

  # contract
  huge_contract.gas_price
  => # 99000000000
  huge_contract.gas_limit
  => # 4000000

  # works the same way with client
  huge_contract.gas_price = 22000000000
  huge_contract.gas_price
  => # 22000000000
```

You can access your deployed contracts directly on `eth_contract` instance.
Accessors will be generated by adding 's' to the end of your contract names,
provided in `config.contract_names` line in `config.rb`.
`my_token` -> `my_tokens`,
`simple_contract` -> `simple_contracts`,
`huge_contract` -> `huge_contracts`.

Note that these methods will be generated dynamically based on the `config.contract_names` you provided in `config.rb`

```ruby
  # etc
  instance.my_tokens
  => [#<MyToken:000000000000000000>]
```

You can also import an existing contract

```ruby
  # Snipet from Chains::EthContract
  # import existing contract
  # name will be used to locate abi and binary files
  # address is the address of existing deployed contract
  # name:(Symbol or String), address:String
  def import(name, address)
  ...

  my_token = instance.import('my_token', '0x0000000000000eth_address0000000000000000')
  => #<MyToken:000000000000000000>

  my_token.address
  => #0x0000000000000eth_address0000000000000000
  my_token.call.initial_supply
  => #500000000
```

You can access them in the same way as deployed contracts.

```ruby
  instance.my_tokens
  => [#<Token:000000000000000000>]
```

Key and client are also available on the `eth_contract` instance.
You can access all of the `JSON RPC` methods directly on client.
See the following for more info.
- ethereum.rb: https://github.com/EthWorks/ethereum.rb
- JSON RPC: https://github.com/ethereum/wiki/wiki/JSON-RPC

```ruby
  instance.client
  => #<Ethereum::HttpClient:0x00007fdea340bbe8
  @batch=nil,
  @default_account="0x0000000000000eth_address0000000000000000",
  @formatter=#<Ethereum::Formatter:0x00007fdea340bbc0>,
  @gas_limit=4000000,
  @gas_price=22000000000,
  ...

  current_gas_price = instance.client.eth_gas_price
  => #{"jsonrpc"=>"2.0", "result"=>"0x51f4d5c00", "id"=>1

  # you can decode the result by converting from hex to decimal
  current_gas_price['result'].to_i(16)
  => #22000000000

  instance.key
  => #<Eth::Key:0x00007fdea34104e0
  @private_key= ...

  instance.key.address
  => #0x0000000000000eth_address0000000000000000
```

## Learn by doing
We will deploy the following contract on `ropsten` network and interact with it.

```solidity
  pragma solidity ^0.4.24;

  contract Mortal {
      /* Define variable owner of the type address */
      address public owner;

      /* This function is executed at initialization and sets the owner of the contract */
      function Mortal() { owner = msg.sender; }

      /* Function to recover the funds on the contract */
      function kill() { if (msg.sender == owner) selfdestruct(owner); }
  }

  contract Greeter is Mortal {
      /* Define variable greeting of the type string */
      string greeting;

      /* This runs when the contract is executed */
      function Greeter(string _greeting) public {
          greeting = _greeting;
      }

      /* Main function */
      function greet() constant returns (string) {
          return greeting;
      }
  }
```
We first need to generate `config.rb` file.
We will run `rake dapp:setup`.
Chains will generate `config.rb` and `.env` files in the root of the project and
populate them with the configuration you might want to use.

We will fill in our config like this:
```ruby
  Chains::Dapp.configure do |config|
    config.eth_networks = %w(ropsten)
    config.encrypted_key_file = './key_data/key.json'
    config.key_password_file = './key_data/key_password'
    config.contract_names = %i()
    config.contract_file_location = './contracts'
    config.contract_data_dir = './contracts/contract_data'
    config.ropsten_node = 'https://ropsten.infura.io/your_access_key'
  end
```

Next we'll copy the content from the above contract to `greeter.sol` file in
`./contracts` folder, corresponding to our setting `config.contract_file_location`.

We will first have to compile it by running `rake contract:compile[greeter.sol, Greeter]`.
Chains searches for `greeter.sol` in `./contracts` folder and finds it.

The result are two files in `./contracts/contract_data`: `greeter_abi.rb` and `greeter_bin.rb`.
We also need to supply the name of the contract to our `config.rb` file, so
Chains can find the abi and binary files when we are running the code.
We add the following line to `config.rb`:
`config.contract_names = %i(greeter)`

Next we will generate a new key by running `rake key:generate[secure_password]`
This will generate `key.json` and `key_password` files in `./key_data` folder.

Since we will be connecting to `ropsten` network we will need to have some ether on our
wallet to be able to deploy contracts.

To find out what your address is, check your `key.json` file and look for `address`.
We can also find our address in the console:
Run `rake dapp:console` or `./bin/chains`.
```ruby
  instance = Chains::EthContract.new(eth_network: 'ropsten')
  instance.key.address
  => #0x0000000000000eth_address0000000000000000
```

Once you know your address, you can request ether for `ropsten` network from a faucet.
If you are using metamask (which you should), you can request ether from here:
https://faucet.metamask.io/

We now have all the data we need to deploy and interact with our greeter contract.

We will start the console and deploy our `Greeter` contract:
`rake dapp:console` or `./bin/chains`.

```ruby
  instance = Chains::EthContract.new(eth_network: 'ropsten')
  greeter = instance.deploy(:greeter, ["Hello world"])

  greeter.address
  => #0x0000000000000eth_address0000000000000000

  greeter.call.greet
  => #"Hello world"
```
The `Greeter` contract is now deployed, and you can interact with it.

If you close the console and wish to gain access to this instance of `Greeter`
contract, you can import it. Make sure to remember it's address.
Run `rake dapp:console` or `./bin/chains`.
```ruby
  instance = Chains::EthContract.new(eth_network: 'ropsten')
  greeter = instance.import(:greeter, '0x0000000000000eth_address0000000000000000')
  => #<Greeter:000000000000000000>

  greeter.call.greet
  => #"Hello world"
```
Note that whatever contract you are importing, abi and binary must be present
in your `config.contract_data_dir`, in our case `./contracts/contract_data`.
Contract `name` argument is mandatory for the contract you wish to import,
so Chains knows which abi and binary files to look for.

The file `greeter.sol` contains two contracts: `Greeter` and `Mortal`.
Let's deploy only the `Mortal` contract from the file `greeter.sol`.
We will have to compile the `Mortal` contract by running `rake 'contract:compile[greeter.sol, Mortal]'`
Chains will look for `Mortal` contract in `greeter.sol` file and compile it.
This command will create two files in our `./contracts/contract_data` folder:
`mortal_abi.rb` and `mortal_bin.rb`.

We have to provide the contract name with to our `config.rb` file.
The `contract_names` line now looks like this:
`config.contract_names = %i(greeter mortal)`

We made a change to the config file, so we need to restart the console for the
changes to take effect.

We start the console again with `rake dapp:console` or `./bin/chains`.
Now we're ready to deploy our `Mortal` contract.

```ruby
  instance = Chains::EthContract.new(eth_network: 'ropsten')
  mortal = instance.deploy(:mortal)

  mortal.call.owner
  => #0x0000000000000eth_address0000000000000000
```


Let's make a transaction on our `Mortal` contract.
To find our more about `call` and `transact`, check out `ethereum.rb`
```ruby
  mortal.call.owner
  => #0x0000000000000eth_address0000000000000000

  mortal.transact.kill
  mortal.call.owner
  => #ArgumentError: ArgumentError ... decode_address
  # Since we killed our Mortal contract, the return value is not a valid
  # ethereum address, hence the ArgumentError in the underlying
  # ethereum.rb gem -> ethereum/decoder.rb
```

### License
MIT License

Copyright (c) 2018, Krištof B. Črnivec

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
