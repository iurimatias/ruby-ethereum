#port from pyethereum#rlp.py
class RLP

  def self.big_endian_to_int(string)
    #'''convert a big endian binary string to integer'''
    # '' is a special case, treated same as 0
    #s = string.encode('hex') or '0'
    #return long(s, 16)
    string_to_int(string)
  end

  def self.__decode(s, pos=0)
    #''' decode string start at `pos`
    #:param s: string of rlp encoded data
    #:param pos: start position of `s` to decode from
    #:return:
    #    o: decoded object
    #    pos: end position of the obj in the string of rlp encoded data
    #'''

    raise "read beyond end of string in __decode" unless pos < s.length

    fchar = s[pos].ord
    if fchar < 128
      return [s[pos], pos + 1]
    elsif fchar < 184
      b = fchar - 128
      return [s[(pos + 1)..(pos + 1 + b - 1)], pos + 1 + b]
    elsif fchar < 192
      b = fchar - 183
      b2 = big_endian_to_int(s[(pos + 1)..(pos + 1 + b - 1)])
      return [s[(pos + 1 + b)..(pos + 1 + b + b2 - 1)], pos + 1 + b + b2]
    elsif fchar < 248
      o = []
      pos += 1
      pos_end = pos + fchar - 192

      while pos < pos_end
        obj, pos = __decode(s, pos)
        #o.append(obj)
        o.push(obj)
      end
      raise "read beyond list boundary in __decode" unless pos == pos_end
      return o, pos
    else
      b = fchar - 247
      b2 = big_endian_to_int(s[(pos + 1)..(pos + 1 + b - 1)])
      raise "b2 >= 56" unless b2 >= 56
      o = []
      pos += 1 + b
      pos_end = pos + b2
      while pos < pos_end
        obj, pos = __decode(s, pos)
        #o.append(obj)
        o.push(obj)
      end
      raise "read beyond list boundary in __decode" unless pos == pos_end
      return o, pos
    end
  end

  def self.decode(s)
    #assert isinstance(s, str)
    raise "wrong instance" unless s.class == String
    if s
      return __decode(s)[0]
    end
  end

  ########

  def self.encode(s)
    if s.class.ancestors.include? String
      #puts "encode: is a string"
      s = s.to_s
      if s.length == 1 and s.ord < 128
        #puts "encode: length=1 and #{s.ord} < 128"
        #puts "returning: #{s.each_byte.to_a.to_s}"
        return s
      else
        #puts "encode: else"
        res = encode_length(s.length, 128) + s
        #puts "returning: #{res.each_byte.to_a.to_s}"
        return encode_length(s.length, 128) + s
      end
    elsif s.class.ancestors.include? Enumerable
      #puts "encode: is an array"
      mapping = s.map { |x| encode(x) }
      #puts "returning: #{concat(mapping).each_byte.to_a.to_s}"
      return concat(mapping)
    end

    raise "type error Encoding of %s not supported #{s.class}"
  end

  def self.encode_length(l, offset)
    #puts "encode_length: #{l} offset: #{offset}"
    if l < 56
      #puts "encode_length: #{l} < 56"
      res = (l + offset).chr
      #puts "returning: #{res.ord}"
      return (l + offset).chr
    elsif l < 256 ** 8
      #puts "encode_length: #{l} < #{256 ** 8}"
      bl = int_to_big_endian(l)
      #puts "encode_length: big endian #{bl}"
      res = (bl.length + offset + 55).chr + bl
      #puts "returning: #{res.each_byte.to_a.to_s}"
      return (bl.length + offset + 55).chr + bl
    else
      raise "input too long"
    end
  end

  def self.concat(s)
    #'''
    #:param s: a list, each item is a string of a rlp encoded data
    #'''
    raise "wrong type" unless s.class.ancestors.include?(Enumerable)
    output = s.join
    res = encode_length(output.length, 192) + output
    #puts "returning: #{res.each_byte.to_a.to_s}"
    return encode_length(output.length, 192) + output
  end

end
