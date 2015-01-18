class Packeter
  attr_accessor :network_protocol_version, :client_version, :capabilities, :node_id

  def initialize
    @network_protocol_version = 2
    @client_version = "Ethereum testing"
    @capabilities = [['eth', 49]]
    @node_id = Digest::SHA3.digest("whatever", 256)
    @listen_port = "30303"
  end

  def hello_packet
    code = 0x00

    data = [ code, network_protocol_version, client_version,
             capabilities, @listen_port.to_i, node_id ]

    package(data)
  end

  def get_peers_packet
    code = 0x04
    data = [ code ]

    package(data)
  end

  def ping_packet
    code = 0x02
    data = [ code ]

    package(data)
  end

  def pong_packet
    code = 0x03
    data = [ code ]

    package(data)
  end

  def get_peers_packet
    code = 0x04
    data = [ code ]

    package(data)
  end

  def disconnect_packet
    code = 0x01
    data = [ code, 0x08 ]

    package(data)
  end

  def peers_packet
    code = 0x05
    data = [code]

    PeerManager.list_peers.each do |peer|
      ip = peer.ip.split(".").map(&:to_i).map(&:chr).join
      data << [ip, peer.expected_port, peer.node_id]
    end

    package(data)
  end

  def status_packet
    #code = (16+0x00)
    code = 0x10
    protocol_version = 49
    network_id = 0

    total_difficulty = ChainManager.instance.total_difficulty
    #best_hash        = ChainManager.instance.best_hash
    head_hash        = ChainManager.instance.head_hash
    genesis_hash     = ChainManager.instance.genesis_hash

    data = [
      code,
      protocol_version,
      network_id,
      total_difficulty.to_s,
      #best_hash,
      head_hash,
      genesis_hash
    ]

    package(data)
  end

  def get_block_hashes_packet(peer)
    #code = (16+0x03)
    code = 0x13

    #starting_hash = "51ba59315b3a95761d0863b05ccc7a7f54703d99"
    #a = [119, 155, 27, 98, 11, 3, 192, 251, 36, 150, 62, 24, 61, 94, 136, 227, 219, 228, 72, 78, 63, 110, 42, 160, 89, 66, 227, 190, 123, 72, 225, 121]
    #genesis_hash = a.map(&:chr).join
    #starting_hash = genesis_hash
    starting_hash = peer.best_hash
    max_blocks = 2000

    data = [
      code,
      starting_hash,
      max_blocks
    ]

    package(data)
  end

  def get_blocks_packet(block_hashes)
    code = 0x15

    data = [
      code,
      block_hashes
    ].flatten

    package(data)
  end

  def package(data)
    payload = RLP.encode(Utils.recursive_int_to_big_endian(data))
    packet = ienc4(0x22400891).to_s
    packet += ienc4(payload.length).to_s
    packet += payload.to_s
    packet
  end
end
