#!/usr/bin/env ruby

module KISSCraft
  class TreeParse

    attr_reader :array
    attr_reader :depth

    def initialize(_array)
      if _array.is_a? String
        @array = _array.split
      else
        @array = _array
      end

      @depth = 0
    end

    def parse(&blk)
      yield self
    end

    def is(matcher, &blk)
      if @array[@depth] == matcher
        @depth += 1
        yield
        @depth -= 1
      end 
    end

    def down
      @array[@depth..@array.size]
    end

    def up
      @array[0..@depth-2].reverse
    end
  end
end
