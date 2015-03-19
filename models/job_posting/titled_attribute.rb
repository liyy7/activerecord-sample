# encoding: UTF-8

class JobPosting
  module TitledAttribute
    def self.included(klass)
      klass.include Methods
      klass.extend ClassMethods
    end

    module Methods
      attr_accessor :job_posting_id
      attr_reader :title

      def initialize(attrs = {})
        fail('Hash required') unless attrs.is_a?(Hash)

        self.job_posting_id = attrs['job_posting_id'] || attrs[:job_posting_id]
        self.title = attrs['title'] || attrs[:title]
      end

      def title=(t)
        fail("Invalid title '#{t}'") unless t.nil? || class_eval('TITLES').include?(t)

        @title = t
      end
    end

    module ClassMethods
      def from_bits(bits)
        i = bits_i(bits)

        class_eval('TITLES')
          .each_with_index
          .select { |_t, idx| 1 << idx & i > 0 }
          .collect(&:first)
          .map { |t| new(title: t) }
      end

      private

      def bits_i(bits)
        bits.bytes.inject { |a, e| a * 256 + e }
      end
    end
  end
