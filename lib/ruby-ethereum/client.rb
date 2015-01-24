module Ethereum
  class Client
    def initialize(opts={})
      @remote_host = opts.fetch(:remote_host) { "poc-7.ethdev.com" }
      @remote_port = opts.fetch(:remote_port) { "30303"            }
      @listen_host = opts.fetch(:listen_port) { "0.0.0.0"          }
      @listen_port = opts.fetch(:listen_port) { "30303"            }
      @connection_only = opts.fetch(:connection_only) { false }
    end

    def start
      on_quit 
      EM.run do
        puts "connecting to #{@remote_host}:#{@remote_port}"
        EventMachine::connect     @remote_host, @remote_port, EthereumClient
        unless @connection_only
          puts "listening at #{@listen_host}:#{@listen_port}"
          EventMachine.start_server @listen_host, @listen_port, EthereumServer
        end
        #EventMachine.add_periodic_timer(5) do
        #  puts "------------ Peer List ------------"
        #  PeerManager.list_peers.each { |peer| puts peer.ip }
        #  puts "-----------------------------------"
        #end
      end
    end

    def on_quit
      trap("INT") {
        PeerManager.disconnect_all
        #sleep 2
        EventMachine.stop
        #sleep 1
      }
    end

  end
end
