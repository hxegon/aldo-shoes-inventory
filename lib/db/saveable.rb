# lib/saveable.rb

module DB
  # abstract mixin for saveable db object
  module Saveable
    def to_dbkey
      raise NotImplementedError
    end

    def to_dbval
      raise NotImplementedError
    end
  end
end
