# encoding: UTF-8

class JobPosting
  module BitColumnModel
    def self.included(klass)
      klass.include Methods
      klass.extend ClassMethods
    end

    module Methods
      attr_accessor :job_posting_id
      attr_reader :value

      def initialize(attrs = {})
        fail('Hash required') unless attrs.is_a?(Hash)

        self.job_posting_id = attrs['job_posting_id'] || attrs[:job_posting_id]
        self.value = attrs['value'] || attrs[:value]
      end

      def value=(v)
        fail("Invalid value '#{v}'") unless v.nil? || self.class::VALUES.include?(v)

        @value = v
      end
    end

    module ClassMethods
      def from_bits(bits)
        i = bits_to_i(bits)

        self::VALUES
          .each_with_index
          .select { |_v, idx| 1 << idx & i > 0 }
          .collect(&:first)
          .map { |v| new(value: v) }
      end

      def to_bits(values)
        self::VALUES
          .each_with_index
          .select { |v, _idx| values.include?(v) }
          .collect(&:second)
          .inject(0) { |a, e| a | 1 << e }
      end

      private

      def bits_to_i(bits)
        bits.bytes.inject { |a, e| a * 256 + e }
      end

      def i_to_bits(i)
        bytes = []

        loop do
          break unless i > 0
          bytes.unshift (i & 255).chr
          i /= 256
        end

        bytes.join
      end
    end
  end
end
