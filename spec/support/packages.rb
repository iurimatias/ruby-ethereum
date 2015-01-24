
def simple_package
  [34, 64, 8, 145, 0, 0, 0, 9].map(&:chr).join + "some_data"
end

def package_part1
  [34, 64, 8, 145, 0, 0, 0, 18].map(&:chr).join + "some_data"
end

def package_part2
  "some_data"
end

def sync_code
  [34, 64, 8, 145].map(&:chr).join
end

def size_string(num)
  Utils.ienc4(num)
end

def create_packet
  text = "somedata"
  "#{sync_code}#{size_string(text.size)}#{text}"
end

