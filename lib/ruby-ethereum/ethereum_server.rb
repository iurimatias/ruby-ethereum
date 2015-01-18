module EthereumServer
  def post_init
    @port, @ip = Socket.unpack_sockaddr_in(self.get_peername)
    puts "#{@ip}:#{@port}> has connected"
    #return close_connection unless ip == "127.0.0.1"
    puts "#{@ip} has connected"
    @peer = Peer.new(self)
    PeerManager.add_peer(@peer)
  end

  def connection_completed
    return if @peer.nil?
    @peer.on_connect
  end

  def receive_data(data)
    return if @peer.nil?
    @peer.receive_data(data)
  end

  def unbind
    puts "#{@ip}:#{@port}> disconnected from server "
    PeerManager.remove_peer(@peer)
  end
end
