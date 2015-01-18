require 'singleton'
require 'set'

class ChainManager
  include Singleton
  attr_accessor :genesis_block, :hash_list

  def initialize
    @genesis_block = nil
    #originally this is a db key store
    @blockchain = {}
    #Index.init(@blockchain)
    @hash_list = Set.new
  end

  def genesis_hash
    genesis = [119, 155, 27, 98, 11, 3, 192, 251, 36, 150, 62, 24, 61, 94, 136, 227, 219, 228, 72, 78, 63, 110, 42, 160, 89, 66, 227, 190, 123, 72, 225, 121]
    genesis.map(&:chr).join
  end

  def head_hash
    genesis_hash
  end

  def total_difficulty
    (2 ** 17)
  end

  def receive_hashes(block_hashes)
    block_hashes.each do |block_hash|
      next if @hash_list.include?(block_hash)
      @hash_list << block_hash
    end
  end

  def head
    initialize_blockchain unless blockchain.has_key?('HEAD')
    blockhash = blockchain.fetch('HEAD')
    blocks.get_block blockhash
  end

  def initialize_blockchain(genesis_block=nil)
    if genesis_block.nil?
      @genesis_block = blocks.get_genesis_block()
      add_genesis_block_to_db
    end
    store_block(genesis_block)
    update_head(genesis_block)
  end

  def add_genesis_block_to_db
    Index.add_block(genesis_block)
  end

end
