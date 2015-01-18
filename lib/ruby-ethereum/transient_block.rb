class TransientBlock

  attr_accessor :block_data, :prevhash, :uncles_hash, :coinbase, :state_root, :tx_list_root, :receipts_root, :bloom, 
                :hex_difficulty, :difficulty, :number, :gas_limit, :gas_used, :timestamp, :extra_data, :nonce

  def initialize(blockdata)
    @block_data = MyRlp.encode(blockdata)
    header_args, transaction_list, uncles = blockdata

    #block_structure = [
    #0 ["prevhash", "bin", "\00" * 32],
    #1 ["uncles_hash", "bin", utils.sha3rlp([])],
    #2 ["coinbase", "addr", GENESIS_COINBASE],
    #3 ["state_root", "trie_root", trie.BLANK_ROOT],
    #4 ["tx_list_root", "trie_root", trie.BLANK_ROOT],
    #5 ["receipts_root", "trie_root", trie.BLANK_ROOT],
    #6 ["bloom", "int64", 0],
    #7 ["difficulty", "int", INITIAL_DIFFICULTY],
    #8 ["number", "int", 0],
    #9 ["gas_limit", "int", GENESIS_GAS_LIMIT],
    #10 ["gas_used", "int", 0],
    #11 ["timestamp", "int", 0],
    #12 ["extra_data", "bin", ""],
    #13 ["nonce", "bin", ""],
    #]

    @prevhash = header_args[0]
    @uncles_hash = header_args[1]
    @coinbase = [header_args[2]].pack("H*")
    @state_root = header_args[3]
    @tx_list_root = header_args[4]
    @receipts_root = header_args[5]
    @bloom = MyRlp.big_endian_to_int(header_args[6])
    @hex_difficulty = header_args[7]
    @difficulty = MyRlp.big_endian_to_int(header_args[7])
    @number = MyRlp.big_endian_to_int(header_args[8])
    @gas_limit = MyRlp.big_endian_to_int(header_args[9])
    @gas_used = MyRlp.big_endian_to_int(header_args[10])
    @timestamp = MyRlp.big_endian_to_int(header_args[11])
    @extra_data = header_args[12]
    @nonce = header_args[13]
  end

  def print_header
    puts "prevhash " + @prevhash.each_byte.map { |x| '%x' % x.ord }.join
    puts "uncles_hash " + @uncles_hash.each_byte.map { |x| '%x' % x.ord }.join
    puts "coinbase " + @coinbase.each_byte.map { |x| '%x' % x.ord }.join

    puts "difficulty " + @hex_difficulty.each_byte.map { |x| '%x' % x.ord }.join
    puts "difficulty " + @difficulty.to_s
  end

end
