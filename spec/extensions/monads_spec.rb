# monads_spec.rb

require 'dry/monads'
require 'extensions/monads'

describe Dry::Monads::Result do
  before do
    @success = Dry::Monads::Result::Success
    @failure = Dry::Monads::Result::Failure
  end

  describe '#unless' do
    context 'on Failure' do
      it 'always returns self' do
        f = @failure.call(:orig)

        expect(f.unless(false)).to eq f
        expect(f.unless(false) { |_v| :with_block }).to eq f

        expect(f.unless(true)).to eq f
        expect(f.unless(true) { |_v| :with_block }).to eq f
      end
    end

    context 'on Success' do
      it 'returns self with passing test' do
        s = @success.call(:orig)

        expect(s.unless(true)).to eq s
        expect(s.unless(true) { |_v| :with_block }).to eq s
      end

      it 'returns Failure with failing test' do
        s = @success.call(:orig)

        expect(s.unless(false)).to eq @failure.call(:orig)
        expect(s.unless(false) { |_v| :with_block }).to eq @failure.call(:with_block)
      end
    end
  end

  describe '#try' do
    before do
      @success = Dry::Monads::Result::Success
      @s       = @success.call(:original_success)
      @failure = Dry::Monads::Result::Failure
      @f       = @failure.call(:original_failure)
    end

    it '== fmap for Failures' do
      expect(
        @f.try([NoMethodError], ->(_fv) { raise NoMethodError })
      ).to eq @f
    end

    it "== fmap when there's no error" do
      expect(@s.try([NoMethodError], ->(v) { v }))
        .to eq @success.call(:original_success)
    end

    it 'catches errors' do
      errored = @s.try([NoMethodError], ->(_sv) { raise NoMethodError })

      expect(errored.failure?)
      expect(errored.failure.class).to eq NoMethodError
    end

    it 'uses block return for failure value' do
      errored =
        @success.call(1)
                .try(
                  [NoMethodError],
                  ->(_v) { raise NoMethodError }
                ) { |v| v }
      expect(errored.failure).to eq 1
    end
  end
end
