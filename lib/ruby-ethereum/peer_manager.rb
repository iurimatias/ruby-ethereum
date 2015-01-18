class PeerManager

  def self.add_peer(peer)
    @peers ||= []
    @peers << peer
  end

  def self.list_peers
    @peers ||= []
    @peers
  end

  def self.has_peer?(ip, port)
    !list_peers.find { |x| x.ip == ip && x.expected_port == port }.nil?
  end

  def self.remove_peer(peer)
    @peers ||= []
    @peers.delete(peer)
  end

  def self.disconnect_all
    @peers ||= []
    @peers.each(&:disconnect)
  end

end
