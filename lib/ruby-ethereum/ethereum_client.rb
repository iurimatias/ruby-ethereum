class EthereumClient < EventMachine::Connection

  def post_init
  end

  def connection_completed
    @port, @ip = Socket.unpack_sockaddr_in(self.get_peername)
    puts "client> connected to #{@ip}:#{@port}"
    @success_connecting = true
    @peer = Peer.new(self)
    PeerManager.add_peer(@peer)
    @peer.on_connect
  end

  def receive_data(data)
    @peer.receive_data(data)
  end

  def unbind
    if @success_connecting
      puts "#{@ip}:#{@port}> disconnected"
    else
      puts "client> couldn't connect to #{@ip}:#{@port}"
    end
    PeerManager.remove_peer(@peer)
  end

end
