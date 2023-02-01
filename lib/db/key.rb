# lib/db/key.rb

module DB
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

    class << self
      def partial_value_address(field_k, value_k)
        [field_k, value_k].map { |e| _normalize_key(e) }.join(PAIR_SEPARATOR)
      end

      private

      def _normalize_key(k)
        k.to_s.gsub(/\s+/, '_').upcase
      end
    end
  end
end
