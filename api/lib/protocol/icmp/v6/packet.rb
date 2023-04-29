# frozen_string_literal: true

# Code from https://github.com/normelton/icmp4em

module Protocol
  module Icmp
    module V6
      class Packet
        ICMP_CODE           = 0
        ICMP_ECHO_REQUEST   = 128
        ICMP_ECHO_REPLY     = 129
        PROTOCOL_NUMBER     = 58

        attr_accessor :type, :code, :checksum, :sequence, :payload

        def self.from_bytes(data, src:, dest:)
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

          Packet.new type:, code:, sequence:, checksum:, payload:, src:, dest:
        end

        def initialize(sequence:, src:, dest:, type: ICMP_ECHO_REQUEST, code: ICMP_CODE, payload: nil, checksum: nil)
          @type         = type
          @code         = code
          @sequence     = sequence
          @checksum     = checksum
          @src          = src
          @dest         = dest

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
          checksum = ipv6_calc_sum_on_addr
          checksum += PROTOCOL_NUMBER
          checksum += message_length
          # Then compute it on ICMPv6 header + payload
          checksum += (@type.to_i << 8) + @code.to_i
          chk_body = (@payload.to_s.size.even? ? @payload.to_s : "#{@payload}\u0000")
          if 1.respond_to? :ord
            chk_body.chars.each_slice(2).map { |x| (x[0].ord << 8) + x[1].ord }
                    .each { |y| checksum += y }
          else
            chk_body.chars.each_slice(2).map { |x| (x[0] << 8) + x[1] }
                    .each { |y| checksum += y }
          end
          checksum = checksum % 0xffff
          checksum = 0xffff - checksum
          checksum.zero? ? 0xffff : checksum
        end

        def ipv6_calc_sum_on_addr
          checksum = 0
          [IPAddr.new(@src).to_i, IPAddr.new(@dest).to_i].each do |iaddr|
            8.times do |i|
              checksum += (iaddr >> (i * 16)) & 0xffff
            end
          end
          checksum
        end

        def message_length
          [@type, @code, 0, 0, @sequence, @payload].pack('C2 n3 A*').length
        end
      end
    end
  end
end
