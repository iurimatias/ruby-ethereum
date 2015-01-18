class Utils

  def self.int_to_big_endian(v)
    return '' if v == 0
    hex = '%x' % v
    if (hex.length & 1) != 0
      a = "%#04x" % v
      hex = a.split("0x").last
      if (hex.length & 1) != 0
        hex = '0' + hex
      end
    end
    [hex].pack('H*')
  end

  def self.recursive_int_to_big_endian(item)
    if item.class.ancestors.include?(Fixnum)
      int_to_big_endian(item)
    elsif item.class.ancestors.include?(Enumerable)
      item.map { |i| recursive_int_to_big_endian(i) }
    else
      item
    end
  end

  def self.ienc4(num)
    #struct.pack('>I', num)
    [num].pack('>I').reverse
  end

  def self.to_rlp(num)
    #binding.pry
    #num.to_rlp.map { |x| x == 0 ? 0x00 : int_to_big_endian(x) }.join
    MyRlp.encode(num)
  end

  def self.string_to_int(str)
    binary_string = ""
    str.size.times do |i|
      num = str[i].ord.to_s(2)
      while num.length < 8
        num = '0' + num
      end
      binary_string += num
    end
    binary_string.to_i(2)
  end

end
