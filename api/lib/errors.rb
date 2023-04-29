# frozen_string_literal: true

module Errors
  class BasicError < StandardError
    def meta
      @meta || {}
    end

    def initialize *args, **meta
      super(*args)
      @meta = meta
    end
  end

  class RetryLaterError < BasicError; end
  class SequenceError < BasicError; end
  class LuaScriptNotFoundError < BasicError; end
  class WrongAttributesError < BasicError; end
  class NoDataError < BasicError; end
end
