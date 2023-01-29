# coercable_spec.rb

require 'invlib/monadic/coercible'
require 'dry/monads'

include Dry::Monads[:result]

describe InvLib::Monadic::Coercible do
  describe '#coerce_' do
    # actually, this should be found at dev time, not runtime
    # it 'raises error for non-procable things' do
    #   expect { @coerce.coerce_(nil, 'f') }.to raise_error ArgumentError
    # end
    before do
      @coerce =
        Class.new do
          extend InvLib::Monadic::Coercible

          attr_reader :value

          def initialize(obj)
            @value = obj
          end

          def self.coerce_(obj, *coercions)
            super(obj, *coercions)
          end
        end
    end

    context 'threads coercions into a Success of new parent class' do
      it 'when returning Results from coercions' do
        c = @coerce.coerce_(
          1,
          proc { _1 + 1 },
          proc { Success(_1 + 1) }
        )

        expect(c).to be_success
        expect(c.success.value).to eq 3
      end

      it 'without returning Results from coercions' do
        c = @coerce.coerce_(
          1,
          proc { _1 + 1 },
          proc { _1 + 1 }
        )

        expect(c).to be_success
        expect(c.success.value).to eq 3
      end

      it 'when mixing procs returning and not returning results' do
        c = @coerce.coerce_(
          1,
          proc { Success(_1 + 1) },
          proc { _1 + 1 },
          proc { Success(_1 + 1) },
          proc { _1 + 1 }
        )

        expect(c).to be_success
        expect(c.success.value).to eq 5
      end

      it 'fails with proc return value when it returns a failure' do
        c = @coerce.coerce_(
          1,
          proc { Success(_1 + 1) },
          proc { _1 + 1 },
          proc { Failure(_1 + 1) },
          proc { _1 + 1 },
          proc { Success(_1 + 1) }
        )

        expect(c).to be_failure
        expect(c.failure).to eq 4
      end
    end
  end
end
