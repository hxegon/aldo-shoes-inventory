# validate_spec.rb
require 'invlib/validate'

describe InvLib::Validate do
  before do
    @validator =
      Class.new do
        extend InvLib::Validate

        def initialize(_obj)
          @validator = true
        end

        def validator?
          true
        end

        def self.validate(*validations)
          super(nil, *validations)
        end
      end
  end

  describe '#validate' do
    context 'succeeds when' do
      it 'validations return nil, false or empty values' do
        v = @validator.validate(
          proc { false },
          proc { nil },
          proc { [] }
        )
        expect(v).to be_success
        expect(v.success).to be_validator
      end
    end

    context 'fails when' do
      it 'validations return truthy values' do
        v = @validator.validate(proc { :validation_issue })

        expect(v).to be_failure
        expect(v.failure).to eq [:validation_issue]
      end
    end
  end
end
