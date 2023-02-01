# lib/db/key.rb

require 'db/saveable'

module DB
  class KeyError; end

  class Key
    PAIR_SEPARATOR = '__'
    FIELD_SEPARATOR = '___'

    attr_reader :value_addresses

    def initialize(key_hash)
      @key_hash = key_hash.to_h

      # the number of keys is factorial(h.keys.count), putting a limit to prevent n of keys from exploding
      key_count = @key_hash.keys.count
      raise ArgumentError, 'A maximum of 2 keys is allowed' if key_count > 2

      # The group of keys that should be set to the value
      # There's 2 parts to the key name, the format and the values
      # The permutations of keys need to be stored to enable quick prefix searching
      # for different key types. An ugly hack to be sure.
      @value_addresses =
        @key_hash
        .map { |k, v| self.class.partial_value_address(k, v) }
        .permutation(key_count)
        .map { |ks| ks.join(FIELD_SEPARATOR) }
    end

    # address for key's transaction time
    # NOTE: immudb indexes revisions starting @ 1
    def txtime_addresses(revision_index)
      @value_addresses.map { |k| ['TX_TIME', k, "REV_#{revision_index}"].join(FIELD_SEPARATOR) }
    end

    def txtime_address(revision_index)
      txtime_addresses(revision_index).first
    end

    def ==(other)
      to_h == (other.respond_to?(:to_h) && other.to_h)
    end

    class << self
      def parse(keystring)
        key_hash =
          keystring
          .split(FIELD_SEPARATOR)
          .map { _1.split(PAIR_SEPARATOR) }
          .map do |field, value|
            [_unnormalize_string(field).downcase.to_sym,
             _unnormalize_string(value)]
          end.to_h

        new(key_hash)
      end

      def partial_value_address(field_k, value_k)
        [field_k, value_k].map { |e| _normalize_string(e) }.join(PAIR_SEPARATOR)
      end

      private

      def _normalize_string(k)
        k.to_s.gsub(/\s+/, '_').upcase
      end

      def _unnormalize_string(s)
        s.to_s.gsub(/_+/, ' ').downcase
      end
    end

    # Conversions
    def to_h
      @key_hash
    end

    # Mixin Methods
    include DB::Saveable

    def to_dbkey
      self
    end

    def to_dbval
      # ???: Should this be a kind of DB::Saveable error?
      raise KeyError, "Can't convert a DB::Key into a database value!"
    end
  end
end
