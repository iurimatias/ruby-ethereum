require 'digest/sha3'
require 'trie'
require 'socket'
require 'pry'
require 'eventmachine'

require_relative 'rlp'
require_relative 'version'

#@remote_host = "poc-7.ethdev.com"
@remote_host = "192.168.2.80"
@remote_port = "30303"

@listen_host = "0.0.0.0"
@listen_port = "30303"

trap("INT") {
  PeerManager.disconnect_all
  #sleep 2
  EventMachine.stop
  #sleep 1
}

puts "connecting to #{@remote_host}:#{@remote_port}"
puts "listening at #{@listen_host}:#{@listen_port}"
EM.run do
  EventMachine::connect     @remote_host, @remote_port, EthereumClient
  EventMachine.start_server @listen_host, @listen_port, EchoServer
  EventMachine.add_periodic_timer(5) do
    puts "------------ Peer List ------------"
    PeerManager.list_peers.each { |peer| puts peer.ip }
    puts "-----------------------------------"
  end
end

