# lib/monads.rb

require 'dry/monads'
require 'util/predicates'

module Ext
  module Monads
    # @todo Include in Success and Failure individually
    # @todo add block arg for #success and #failure i.e. Failure(1).failure { |v| v + 1 } #=> Failure(2) etc.
    module Result
      # @todo rename to #fail_unless, add #fail_if
      def unless(test, &failed)
        return self if failure? || test

        fmap { |v| failed ? failed.call(v) : v }.flip
      end

      def try(exceptions = StandardError, run, &catchfn)
        return self if failure?

        bind do |v|
          Dry::Monads::Try[*exceptions] { run.call(v) }
            .to_result
            .or { |e| Dry::Monads::Result::Failure.call(catchfn ? catchfn.call(e, v) : e) }
        end
      end
    end
  end
end

Dry::Monads::Result.include Ext::Monads::Result
