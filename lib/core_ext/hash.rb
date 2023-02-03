module CoreExt
  module Hash
    # Return a new hash with key's value transformed by block
    # @note port of Clojure's update. #update is already taken, so named #exchange instead
    def exchange(key)
      merge({ key => nil }) { |_key, oldval, _newval| yield oldval }
    end
  end
end

Hash.include CoreExt::Hash
