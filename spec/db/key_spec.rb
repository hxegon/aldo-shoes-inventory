# key_spec.rb

require 'db/key'

describe DB::Key do
  before do
    @key_hash = { STORE: 'SANTA BARBARA BRANCH', model: 'nike air whatevers' }
    @key = DB::Key.new @key_hash
    @keystrings = %w[STORE__SANTA_BARBARA_BRANCH___model__nike_air_whatevers
                     model__nike_air_whatevers___STORE__SANTA_BARBARA_BRANCH]
  end

  describe '#value_addresses' do
    it 'produces a number addresses = the number of key combinations' do
      addrs = @key.value_addresses
      expect(addrs.count).to eq 2
    end

    it 'outputs keys in the right format' do
      expected_keys = @keystrings

      actual_keys = @key.value_addresses

      @keystrings.each { |ek| expect(actual_keys).to include ek }
    end
  end

  describe '.parse' do
    context 'has idempotent' do
      it 'value addresses' do
        @keystrings.each do |ks|
          parsed = described_class.parse ks
          expect(parsed.value_addresses).to include ks
        end
      end

      it 'key hashes' do
        @keystrings.each do |ks|
          key_hash = described_class.parse(ks).to_h.transform_values(&:downcase)
          expect(key_hash).to eq @key_hash.transform_values(&:downcase)
        end
      end
    end
  end
end
