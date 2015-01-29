class Transaction < Struct.new(:nonce, :gas_price, :start_gas, :to, :value, :data, :signature)

  N = 10
  P = 100

  def sign(private_key)
    digest = Digest::SHA3.digest serialize(signed: false)

    signature = nil
    while signature.nil?
      temp_key = 1 + SecureRandom.random_number(group.order - 1)
      signature = ECDSA.sign(group, private_key, digest, temp_key)
    end
  end

  def sender
    @sender ||= determine_sender
  end

  private

  def determine_sender
    digest = Digest::SHA3.digest serialize(signed: false)
    ECDSA::Format::PointOctetString.decode(digest, group)
  end

  def serialize(signed: true)
    RLP.encode listfy(signed)
  end

  def listfy(signed)
    #    o = []
    #    for i, (name, typ, default) in enumerate(tx_structure):
    #        o.append(utils.encoders[typ](getattr(self, name)))
    #      return o if signed else o[:-3]
  end

  def group
    @group ||= ECDSA::Group::Secp256k1
  end
end
