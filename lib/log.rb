#!/usr/bin/env ruby

module KISSCraft

  module Log
    
    class << self
      def puts(str, level = "", server = "", activity = "" )
        if level.empty?
          Kernel.puts "#{str.strip}\r"
        else
          time = Time.new.strftime("%H:%M:%S")
          Kernel.puts "[#{time}] [KISSCraft/#{level}] [#{server}/#{activity}]: #{str.strip}\r"
        end
      end
    end

  end
end

