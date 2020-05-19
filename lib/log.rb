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

      def server(server, str, level ="", activity = "")
        line = ""

        if level.empty?
           line = "#{str.strip}"
        else
          time = Time.new.strftime("%H:%M:%S")
          line = "[#{time}] [KISSCraft/#{level}] [#{server.name}/#{activity}]: #{str.strip}"
        end

        if !server.console_connections.empty?
          server.console_connections.each do |con|
            begin
              con.write line
              con.flush

            rescue IOError
              server.console_connections.delete(con)
              next
            end
          end
        end
      end
    end

  end
end

