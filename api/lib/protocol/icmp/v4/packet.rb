# frozen_string_literal: true

# Code from https://github.com/normelton/icmp4em

module Protocol
  module Icmp
    module V4
      class Packet
        ICMP_CODE           = 0
        ICMP_ECHO_REQUEST   = 8
        ICMP_ECHO_REPLY     = 0

        attr_accessor :type, :code, :checksum, :sequence, :payload

        def self.from_bytes(data)
          unless data.length >= 8
            raise ArgumentError,
                  'Must provide at least eight bytes in order to craft an ICMP packet'
          end

          fields = data.unpack('C2 n3 A*')
          type = fields.shift
          code = fields.shift
          fields.shift
          checksum = fields.shift
          sequence = fields.shift
          payload = fields.shift

          Packet.new type:, code:, sequence:, checksum:, payload:
        end

        def initialize(sequence:, type: ICMP_ECHO_REQUEST, code: ICMP_CODE, payload: nil, checksum: nil)
          @type         = type
          @code         = code
          @sequence     = sequence
          @checksum     = checksum

          @payload = if payload.nil?
                       ''
                     elsif payload.is_a? Integer
                       'A' * payload
                     else
                       payload
                     end
        end

        def request?
          @type == ICMP_ECHO_REQUEST
        end

        def reply?
          @type == ICMP_ECHO_REPLY
        end

        def valid_checksum?
          @checksum == compute_checksum
        end

        def to_bytes
          [@type, @code, compute_checksum, 0, @sequence, @payload].pack('C2 n3 A*')
        end

        def key
          [0, @sequence].pack('n2')
        end

        def key_string
          key.unpack1('H*')
        end

        private

        # Perform a checksum on the message.  This is the sum of all the short
        # words and it folds the high order bits into the low order bits.
        # This method was stolen directly from the old icmp4em - normelton
        # ... which was stolen directly from net-ping - yaki

        def compute_checksum
          msg = [@type, @code, 0, 0, @sequence, @payload].pack('C2 n3 A*')

          length    = msg.length
          num_short = length / 2
          check     = 0

          msg.unpack("n#{num_short}").each do |short|
            check += short
          end

          check += msg[length - 1, 1].unpack1('C') << 8 if (length % 2).positive?

          check = (check >> 16) + (check & 0xffff)
          (~((check >> 16) + check) & 0xffff)
        end
      end
    end
  end
end
