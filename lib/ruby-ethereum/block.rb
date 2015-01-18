class Block
  #GENESIS_PREVHASH = '\00' * 32
  GENESIS_PREVHASH = 0.chr * 32
  GENESIS_COINBASE = "0" * 40
  #GENESIS_NONCE = Utils.sha3(chr(42))
  GENESIS_NONCE = Digest::SHA3.digest(42.chr, 256)
  GENESIS_GAS_LIMIT = 10 ** 6
  BLANK_ROOT = ''
  INITIAL_DIFFICULTY = 2 ** 17

  attr_accessor :prevhash, :coinbase, :tx_list_root, :difficulty, :nonce, :gas_limit, :caches, :journal, :block_structure, :state_root

  def initialize(prevhash: GENESIS_PREVHASH,
                 uncles_hash: sha3rlp([]),
                 coinbase: GENESIS_COINBASE,
                 state_root: BLANK_ROOT,
                 tx_list_root: BLANK_ROOT,
                 receipts_root: BLANK_ROOT,
                 bloom: 0,
                 difficulty: INITIAL_DIFFICULTY,
                 number: 0,
                 gas_limit: GENESIS_GAS_LIMIT,
                 gas_used: 0,
                 timestamp: 0,
                 extra_data: '',
                 nonce: '',
                 transaction_list: [],
                 uncles: []
                 )
    @prevhash = prevhash
    @uncles_hash = uncles_hash
    @coinbase = coinbase
    @state_root = state_root
    @tx_list_root = tx_list_root
    @receipts_root = receipts_root
    @bloom = bloom
    @difficulty = difficulty
    @number = number
    @gas_limit = gas_limit
    @gas_used = gas_used
    @timestamp = timestamp
    @extra_data = extra_data
    @nonce = nonce
    @transaction_list = transaction_list
    @uncles = uncles
    #blocks#129

    #@block_structure = [
    #  ["prevhash", "bin", "\00" * 32],
    #  ["uncles_hash", "bin", Digest::SHA3.digest(RLP.encode([]), 256)],
    #  ["coinbase", "addr", GENESIS_COINBASE],
    #  ["state_root", "trie_root", trie.BLANK_ROOT],
    #  ["tx_list_root", "trie_root", trie.BLANK_ROOT],
    #  ["difficulty", "int", INITIAL_DIFFICULTY],
    #  ["number", "int", 0],
    #  ["min_gas_price", "int", GENESIS_MIN_GAS_PRICE],
    #  ["gas_limit", "int", GENESIS_GAS_LIMIT],
    #  ["gas_used", "int", 0],
    #  ["timestamp", "int", 0],
    #  ["extra_data", "bin", ""],
    #  ["nonce", "bin", ""],
    #]

    #see https://en.wikipedia.org/wiki/Trie
    #transactions = trie.Trie(utils.get_db_path(), tx_list_root)
    @transactions = Trie.new
    @transaction_count = 0

    #added by me
    @caches = {
      'all' => {},
      'balance' => {},
      'nonce' => {},
      'code' => {}
    }
    @journal = []
  end

  def sha3rlp(x)
    Digest::SHA3.digest(RLP.encode(x), 256)
  end

  def set_balance(address, balance)
     set_and_journal('balance', address, balance)
     set_and_journal('all', address, true)
  end

  def set_and_journal(cache, index, value)
    prev = caches[cache].fetch(index) { 'None' }
    if prev != value
      journal.append([cache, index, prev, value])
      caches[cache][index] = value
    end
  end

  def hash
    #utils.sha3(serialize_header)
    Digest::SHA3.digest(serialize_header, 256)
  end

  def serialize_header
    #rlp.encode(list_header)
    #list_header.to_rlp
    to_rlp(list_header)
  end

  def list_header(exclude=[])
    header = []

    #block_structure = [
    #6 ["bloom", "int64", 0],
    #]

    encoded_value = @prevhash
    header << encoded_value
    encoders = @uncles_hash
    header << encoders
    encode = @coinbase
    header << encode
    encoded_value = @state_root
    header << encoded_value
    encoders = @tx_list_root
    header << encoders
    encode = @receipts_root
    header << encode
    encoded_value = int64(@bloom)
    header << encoded_value
    encoders = int_to_big_endian(@difficulty)
    header << encoders
    encode = int_to_big_endian(@number)
    header << encode
    encoded_value = int_to_big_endian(@gas_limit)
    header << encoded_value
    encoders = int_to_big_endian(@gas_used)
    header << encoders
    encode = int_to_big_endian(@timestamp)
    header << encode
    encode = @extra_data
    header << encode
    encode = @nonce
    header << encode

    #block_structure.each do |name, typ, default|
    #  # print name, typ, default , getattr(self, name)
    #  if !exclude.include?(name)
    #    encoded_value = Encoders.encoders(typ, send(name.to_sym))
    #    header << encoded_value
    #    #header.append(utils.encoders[typ](getattr(name)))
    #  end
    #end
    return header
  end

  def int64(v)
    zpad(int_to_big_endian(v), 64)
  end

  def zpad(x, l)
    0.chr * [0, l - x.length].max + x
  end

end
