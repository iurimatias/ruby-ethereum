class Peer
  attr_reader :connection, :node_ip, :expected_port, :node_id, :best_hash

  def initialize(connection)
    @connection = connection
    set_ip_and_port
    #EventMachine.add_periodic_timer(20) do
    #  packet = Packeter.new
    #  puts "client> Ping > #{@ip}:#{@port}"
    #  connection.send_data packet.ping_packet
    #end
    #EventMachine.add_periodic_timer(30) do
    #  packet = Packeter.new
    #  puts "client> Get Peers > #{@ip}:#{@port}"
    #  connection.send_data packet.get_peers_packet
    #end
    #EventMachine.add_periodic_timer(10) do
    #  packet = Packeter.new
    #  puts "client> Get Blocks Hashes > #{@ip}:#{@port}"
    #  @connection.send_data packet.get_block_hashes_packet
    #end
    #EventMachine.add_periodic_timer(5) do
    #  packet = Packeter.new
    #  puts "client> Peer List > #{@ip}:#{@port}"
    #  connection.send_data packet.peers_packet
    #end
  end

  def on_connect
    send_hello
  end

  def set_ip_and_port
    @port, @ip = Socket.unpack_sockaddr_in(@connection.get_peername)
  end

  def ip
    port, @node_ip = Socket.unpack_sockaddr_in(@connection.get_peername)
    @node_ip
  rescue
    puts "error getting ip"
    ""
  end

  def receive_data(data)
    return if needs_more_data?(data)

    _, cmd, payload, remain = unpack(@data)
    @data = ""

    puts "#{@ip}:#{@port}> #{p2p_cmd(cmd)}"

    packet = Packeter.new
    case p2p_cmd(cmd)
    when :hello
      @expected_port, @node_id = ServerPackets.hello_packet(payload)
      send_hello
      #send_get_peers
    when :disconnect
      puts "#{@ip}:#{@port}> Disconnect"
      ServerPackets.disconnect_packet(payload)
    when :ping
      puts "client> Pong > #{@ip}:#{@port}"
      connection.send_data packet.pong_packet
      send_status
    when :pong
    when :get_peers
      #if @last_sent_peers.nil? || @last_sent_peers < Time.now - 30
      #  puts "client> Peer List > #{@ip}:#{@port}"
      #  connection.send_data packet.peers_packet
      #  @last_sent_peers = Time.now
      #end
    when :peers
      ServerPackets.peers_packet(payload)
    when :block_hashes
      #binding.pry
      payload.each do |hash|
        hex = hash.each_byte.map { |x| '%x' % x.ord }.join
        #puts "received #{hex}"
      end
      ChainManager.instance.receive_hashes(payload)
      if payload.size > 0
        @best_hash = payload.last
        #send_get_blocks
        packet = Packeter.new
        @connection.send_data packet.get_block_hashes_packet(self)
      else
        send_get_blocks
      end
    when :status
      handle_status(payload)
      send_status
    when :blocks
      handle_blocks(payload)
    when :unknown
      #binding.pry
      puts "===================================================="
      puts "#{@ip}:#{@port}> Unknown command: #{cmd}"
      puts "#{@ip}:#{@port}> #{payload}"
      puts "===================================================="
    else
      puts "===================================================="
      puts "#{@ip}:#{@port}> Undealt command: #{p2p_cmd(cmd)}"
      puts "#{@ip}:#{@port}> #{payload}"
      puts "===================================================="
    end
  rescue => e
    puts "==!!==!!!=!!!=!!!=="
    puts "an error occurred with #{@ip}:#{@port}"
    puts e.message
    puts e.backtrace.inspect
    puts "==!!==!!!=!!!=!!!=="
  end

  def unpack(data)
    sync_token   = data[0..3]
    payload_size = Utils.string_to_int(data[4..7])
    payload      = data[8..(7 + payload_size)]
    remain       = data[(8 + payload_size)..-1]

    begin
    real_payload = MyRlp.decode(payload)
    rescue
      binding.pry
    end
    cmd = real_payload[0]

    cmd = cmd == "" ? 0 : cmd.ord

    [sync_token, cmd, real_payload[1..-1], remain]
  end

  def needs_more_data?(data)
    puts "sync code is #{Utils.string_to_int(data[0..3])}"
    sync_code = Utils.string_to_int(data[0..3])

    if (sync_code == 574621841)
      @original_payload_size = Utils.string_to_int(data[4..7])
    end

    @data ||= ""
    @data  += data

    (@data.length < @original_payload_size)
  end

  def p2p_cmd(cmd)
    #{0: 'Hello', 1: 'Disconnect', 2: 'Ping', 3: 'Pong', 4: 'GetPeers', 5: 'Peers', 16: 'Status', 17: 'Transactions', 18: 'Transactions', 19: 'GetBlockHashes', 20: 'BlockHashes', 21: 'GetBlocks', 22: 'Blocks', 23: 'NewBlock'}
    {
      []   => :hello,
      0x00 => :hello,
      0x01 => :disconnect,
      0x02 => :ping,
      0x03 => :pong,
      0x04 => :get_peers,
      0x05 => :peers,
      16 => :status,
      17 => :transactions,
      18 => :transactions,
      19 => :get_block_hashes,
      20 => :block_hashes,
      21 => :get_blocks,
      22 => :blocks,
      23 => :new_block
    }.fetch(cmd) {
      :unknown
    }
  end

  def disconnect
    packet = Packeter.new
    puts "client> Disconnect > #{@ip}:#{@port}"
    @connection.send_data packet.disconnect_packet
  end

  def send_hello
    return if @sent_hello_already
    puts "client> Hello > #{@ip}:#{@port}"
    packet = Packeter.new
    @connection.send_data packet.hello_packet
    @sent_hello_already = true
  end

  def send_get_peers
    puts "client> Get Peers > #{@ip}:#{@port}"
    packet = Packeter.new
    @connection.send_data packet.get_peers_packet
  end

  def send_status
    return if @sent_status_already
    puts "client> Status > #{@ip}:#{@port}"
    packet = Packeter.new
    @connection.send_data packet.status_packet
    @sent_status_already = true
  end

  def handle_status(payload)
    send_status
    #code, protocol_version, network_id, total_difficulty, head_hash, genesis_hash = payload
    protocol_version, network_id, total_difficulty, head_hash, genesis_hash = payload

    @best_hash = head_hash

    #TODO: create hash of genesis block
    if genesis_hash != ChainManager.instance.genesis_hash
      #peer.send_Disconnect(reason='Wrong genesis block')
      puts "different genesis block!!"
      packet = Packeter.new
      @connection.send_data packet.disconnect_packet
      exit
      return
    end

    packet = Packeter.new
    @connection.send_data packet.get_block_hashes_packet(self)

    ## request chain
    #with peer.lock:
    #    chain_manager.synchronizer.synchronize_status(
    #        peer, peer.status_head_hash, peer.status_total_difficulty)
  end

  def send_get_blocks
    puts "client> Get Blocks > #{@ip}:#{@port}"
    packet = Packeter.new
    block_hashes = ChainManager.instance.hash_list
    #block_hashes.each_slice(50) do |blocks|
    #blocks = block_hashes.reverse.first(100)
    $current_block_num ||= 0
    #blocks = block_hashes.reverse.first(100)
    blocks = block_hashes.reverse[$current_block_num..$current_block_num+100]
    @connection.send_data packet.get_blocks_packet(blocks)
  end

  def handle_blocks(payload)
    transient_blocks = payload.map do |block|
      TransientBlock.new(block)
    end

    transient_blocks.sort_by(&:number).each do |transient_block|

      blockchain = {}
      #block = blocks.Block.deserialize(self.blockchain, t_block.rlpdata)
      block = deserialize(blockchain, transient_block.block_data)
      binding.pry
      #binding.pry if block.prevhash.each_byte.map { |x| '%x' % x.ord }.join == "779b1b620b03c0fb24963e183d5e88e3dbe4484e3f6e2aa05942e3be7b48e179"

      #unless ChainManager.instance.hash_list.include?(block.hash)
      #unless blockchain.has_key?(block.hash)
        add_block(block)
      #end
    end
    $current_block_num += 101
    send_get_blocks
  end

  def add_block(block)
    return false unless check_proof_of_work(block, block.nonce)

    #broadcast block to peers
    if block.has_parent?
      process_and_verify_block(block)
    end

    #index.add_block(block)
    #store_block(block)

    if block.chain_difficulty > ChainManager.instance.head.chain_difficulty
      ChainManager.instance.update_head(block)
    end

    #blockchain.commit
  end

  def check_proof_of_work(block, nonce)
    #H = self.list_header()
    #H[-1] = nonce
    #return check_header_pow(H)

    #def check_header_pow(header)
    #rlp_Hn = rlp.encode(header[:-1])
    #nonce = header[-1]
    #assert len(nonce) == 32
    #diff = utils.decoders['int'](header[block_structure_rev['difficulty'][0]])
    #h = utils.sha3(utils.sha3(rlp_Hn) + nonce)
    #return utils.big_endian_to_int(h) < 2 ** 256 / diff

    header = block.list_header

    rlp_Hn = MyRlp.encode(header)

    diff = Utils.string_to_int(header[7])

    sha = Digest::SHA3.digest(rlp_Hn, 256)
    h = Digest::SHA3.digest(sha + nonce, 256)

    binding.pry if block.state_root.each_byte.map { |x| '%x' % x.ord }.join == "828d28295d82497c565d94c21872c62b7fe4ca237e5ffa6f3fddda98709439aa"
    #binding.pry
    Utils.string_to_int(h) < ((2 ** 256) / diff)
  end

  def deserialize(db, rlpdata)
    header_args, transaction_list, uncles = MyRlp.decode(rlpdata)
    kargs = deserialize_header(header_args)
    kargs['header'] = header_args
    kargs['transaction_list'] = transaction_list
    kargs['uncles'] = uncles

    #binding.pry
    # if we don't have the state we need to replay transactions
    # #dude
    if kargs['state_root'].size == 32 and db.include?(kargs['state_root'])
      return Block.new(
        prevhash: kargs["prevhash"],
        uncles_hash: kargs["uncles_hash"],
        coinbase: kargs["coinbase"],
        state_root: kargs["state_root"],
        tx_list_root: kargs["tx_list_root"],
        receipts_root: kargs["receipts_root"],
        bloom: kargs["bloom"],
        difficulty: kargs["difficulty"],
        number: kargs["number"],
        gas_limit: kargs["gas_limit"],
        gas_used: kargs["gas_used"],
        timestamp: kargs["timestamp"],
        extra_data: kargs["extra_data"],
        nonce: kargs["nonce"],
        transaction_list: kargs["transaction_list"],
        uncles: kargs["uncles"]
      )
    #elsif kargs['prevhash'] == Block::GENESIS_PREVHASH
    else
      return Block.new(
        prevhash: kargs["prevhash"],
        uncles_hash: kargs["uncles_hash"],
        coinbase: kargs["coinbase"],
        state_root: kargs["state_root"],
        tx_list_root: kargs["tx_list_root"],
        receipts_root: kargs["receipts_root"],
        bloom: kargs["bloom"],
        difficulty: kargs["difficulty"],
        number: kargs["number"],
        gas_limit: kargs["gas_limit"],
        gas_used: kargs["gas_used"],
        timestamp: kargs["timestamp"],
        extra_data: kargs["extra_data"],
        nonce: kargs["nonce"],
        transaction_list: kargs["transaction_list"],
        uncles: kargs["uncles"]
      )
    #else  # no state, need to replay
      #binding.pry
      #parent = get_block(db, kargs['prevhash'])
      #return parent.deserialize_child(rlpdata)
      #parent = db.
    end
  end

  def get_block
    blk = Block.deserialize(db, db.get(blockhash))
    return CachedBlock.create_cached(blk)
  end

  def deserialize_header(header_data)
    if header_data.class == String
      header_data = rlp.decode(header_data)
    end
    #assert len(header_data) == len(block_structure)
    #raise "size does not match" unless header_data.size == 11
    kargs = {}
    # Deserialize all properties
    #for i, (name, typ, default) in enumerate(block_structure)

    header_args = header_data

    kargs["prevhash"] = header_args[0]
    kargs["uncles_hash"] = header_args[1]
    #TODO: try to replicate original value
    #kargs["coinbase"] = [header_args[2]].pack("H*")
    kargs["coinbase"] = header_args[2]
    kargs["state_root"] = header_args[3]
    kargs["tx_list_root"] = header_args[4]
    kargs["receipts_root"] = header_args[5]
    kargs["bloom"] = MyRlp.big_endian_to_int(header_args[6])
    #kargs["hex_difficulty"] = header_args[7]
    kargs["difficulty"] = MyRlp.big_endian_to_int(header_args[7])
    kargs["number"] = MyRlp.big_endian_to_int(header_args[8])
    #binding.pry
    kargs["gas_limit"] = MyRlp.big_endian_to_int(header_args[9])
    kargs["gas_used"] = MyRlp.big_endian_to_int(header_args[10])
    kargs["timestamp"] = MyRlp.big_endian_to_int(header_args[11])
    kargs["extra_data"] = header_args[12]
    kargs["nonce"] = header_args[13]

    return kargs
  end

end
