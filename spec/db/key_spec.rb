# key_spec.rb

require 'db/key'

describe DB::Key do
  before do
    @data = { store: 'santa barbara branch', model: 'nike air whatevers' }
    @key = DB::Key.new @data
  end

  describe '#value_addresses' do
    it 'produces a number addresses = the number of key combinations' do
      addrs = @key.value_addresses
      expect(addrs.count).to eq 2
    end

    it 'outputs keys in the right format' do
      expected_keys = %w[STORE__SANTA_BARBARA_BRANCH___MODEL__NIKE_AIR_WHATEVERS
                         MODEL__NIKE_AIR_WHATEVERS___STORE__SANTA_BARBARA_BRANCH]

      actual_keys = @key.value_addresses

      expected_keys.each { |ek| expect(actual_keys).to include ek }
    end
  end
end
