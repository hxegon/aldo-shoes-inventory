# invlib/validate.rb

require 'dry/monads'

module InvLib
  module Validate
    include Dry::Monads[:result]
    VERSION = '0.0.1'

    # add validate function that supers with an array of procs that return some kind of error value
    # validations should return a truthy value if it detects the error state in self
    # i.e. { odd_number: ->(x) { :not_odd if x.odd? } }
    # validation return results are flattened
    def validate(obj, *validators)
      errors =
        validators
        .map { |v| v.call obj }
        .flatten
        .filter(&:itself) # remove falsey values

      errors.empty? ? Success(new(obj)) : Failure(errors)
    end
  end
end
