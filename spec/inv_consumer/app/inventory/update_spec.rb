# update_spec.rb

require './inv_consumer/app/inventory/update'

describe Inventory::Update do
  describe '#coerce_' do
    it 'succeeds with valid updates' do
      valid = { store: 'foo', model: 'bar', inventory: 10 }
      [valid, { 'store': 'foo', 'model': 'bar', inventory: '10' }]
        .each do |update|
          coerced = described_class.coerce_ update
          expect(coerced).to be_success
          expect(coerced.success.to_h.slice(:store, :model, :inventory))
            .to eq valid.slice(:store, :model, :inventory)
        end
    end

    it 'Fails with bad updates' do
      [
        { store: 'foo', model: 'bar', inventory: 'f' }, # Bad inv value
        { model: 'bar', inventory: 10 },                # Missing store value
        { store: 'foo', inventory: 10 },                # Missing model value
        :not_hashable
      ]
        .each do |update|
        coerced = described_class.coerce_ update
        expect(coerced).to be_failure
      end
      actual = described_class.coerce_(store: 'foo', model: 'bar', inventory: 'baz')
      expect(actual).to be_failure
    end
  end
end
