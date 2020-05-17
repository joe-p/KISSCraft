#!/usr/bin/env ruby

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

  def on(matcher, &blk)
    if @array[@depth] == matcher
      @depth += 1
      yield
      @depth -= 1
    end 
  end

  def down(n = nil)
    arr = @array[@depth..@array.size]

    n ? arr[n-1] : arr 
  end

  def up(n = nil)
    arr = @array[0..@depth-2].reverse

    n ? arr[n-1] : arr
  end

  def current
    @array[@depth-1]
  end

  def next
    down(1)
  end

  def last
    up(1)
  end
end
