class ServerPackets

  def self.hello_packet(payload)
    network_protocol_version = payload[0]
    client_version = payload[1]
    capabilities = payload[2]
    listen_port = Utils.string_to_int(payload[3])
    node_id = payload[4]

    puts ">>>> hello from #{client_version}"
    #puts "server> network protocol version: #{network_protocol_version}"
    #puts "server> client version: #{client_version}"
    #puts "server> capabilities: #{capabilities}"
    #puts "server> listen_port: #{listen_port}"
    #puts "server> node_id: #{node_id.each_byte.map(&:ord).to_s}"

    [listen_port, node_id]
  end

  def self.peers_packet(payload)
    puts "-------------------"
    payload.each do |peer|
      ip   = peer[0].each_byte.map(&:ord).join('.')
      port = Utils.string_to_int(peer[1])
      id   = peer[2]

      puts "server> ip: #{ip} port: #{port}"
      begin
        next if PeerManager.has_peer?(ip, port)
        EventMachine::connect(ip, port, EthereumClient)
      rescue
        puts "********************************************************"
        puts "********************************************************"
        puts "********************************************************"
        puts "********************************************************"
        puts "error with server> ip: #{ip} port: #{port}"
        puts "********************************************************"
        puts "********************************************************"
        puts "********************************************************"
        puts "********************************************************"
      end
    end
  end

  def self.disconnect_packet(payload)
    reasons = {
      0x00 => 'Disconnect requested',
      0x01 => 'TCP sub-system error',
      0x02 => 'Bad protocol',
      0x03 => 'Useless peer',
      0x04 => 'Too many peers',
      0x05 => 'Already connected',
      0x06 => 'Wrong genesis block',
      0x07 => 'Incompatible network protocols',
      0x08 => 'Client quitting',
      0x09 => 'Unexpected Identity',
      0xa  => 'Local Identity',
      0xb  => 'Ping Timeout',
      0x10 => 'Other'
    }

    cmd = payload[0].ord

    puts "server> disconnect reasons: #{reasons[cmd]}"
  end

end
