class Buffer
  attr_accessor :buffer

  def initialize
    @buffer = ""
    @blocks = []
    @payload_size = 0
  end

  def on_receiving_package(&block)
    @blocks << block
  end

  def trigger(package)
    @blocks.each { |b| b.call(package) }
  end

  def receive(data)
    packages = extract_packages(data)
    packages.each { |package| trigger(package) }
  end

  def extract_packages(data)
    return [] if data.to_s == ""

    @buffer += data
    return [] if @buffer.length > 0 && @buffer.length - 8 < @payload_size

    @sync_code    = Utils.string_to_int(@buffer[0..3])
    @payload_size = Utils.string_to_int(@buffer[4..7])
    return [] if @buffer.length > 0 && @buffer.length - 8 < @payload_size

    package      = @buffer[8..(7 + @payload_size)]
    remain       = @buffer[(8 + @payload_size)..-1]
    @buffer = ""
    @payload_size = 0

    [package, extract_packages(remain)].flatten
  end

  def code
    [34, 64, 8, 145].map(&:chr).join
  end

end
