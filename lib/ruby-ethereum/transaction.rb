class Transaction < Struct.new(:nonce, :gas_price, :start_gas, :to, :value, :data, :v, :r, :s)

end
