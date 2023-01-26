# invlib/monadic/coercable.rb

require 'dry/monads'

module InvLib
  module Monadic
    module Coercable
      extend Dry::Monads[:result, :try]
      VERSION = '0.0.1'

      # returns Success(new(coercion result)) or short circuts if a proc returns a failure
      def coerce_(obj, *coercions)
        coercions
          .reduce(Success(obj)) do |success, coercion|
          success.bind do |sv|
            result = coercion.to_proc.call sv
            result.respond_to?(:to_result) ? result.to_result : Success(result)
          end
        end
          .fmap do |result|
            new result
          end
      end

      def validate(obj)
        coerce_(obj).failure
      end
    end
  end
end
