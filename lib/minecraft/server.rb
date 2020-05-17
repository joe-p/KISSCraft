#!/usr/bin/env ruby

require 'open3'

module KISSCraft

  module Minecraft

    class Server
      class << self
        def get_servers(status = nil)

          all_servers = ObjectSpace.each_object(self).to_a

          if status
            return all_servers.select {|s| s.status == status}
          else
            return all_servers
          end

        end
      end

      attr_reader :status
      attr_reader :name
      attr_reader :current_players
      attr_reader :pid

      attr_accessor :server_input_queue
      attr_accessor :server_output_queue 

      def initialize(_name)
        @name = _name

        if Dir["./servers/#{name}"].empty?
          Log.puts "ERROR: #{name} does not exit"
          return 1
        else
          @server_dir = "./servers/#{name}"
        end

        @current_players = Hash.new

        @putting_block = false
        @capturing_error = false

        @server_input_queue = Queue.new
        @server_output_queue = Queue.new

        start_server
        start_input_output_threads
      end

      def start_server
        @server_thread = Thread.new do 
          Open3.popen2e("cd #{@server_dir} && java -jar forge.jar nogui") do |stdin, output, thr|
            @open3_thread = thr

            Thread.new do 
              output.each_line do |ln|
                server_output_queue << ln
              end
            end

            Thread.new do
              input = server_input_queue.pop
              stdin.puts input
            end

            thr.join
          end
        end
      end

      def stop 
        server_input_queue << "stop"

        sleep 5

        @server_thread.kill
        @output_thread.kill

      end

      def start_input_output_threads 
        @output_thread = Thread.new do
          loop do
            line = server_output_queue.pop 

            if @putting_block
              if /^\[\d\d:\d\d:\d\d\]/ =~ line
                @putting_block = false
                Log.puts errors[-1]
              else  
                if capturing_error
                  errors[-1] += line
                end
              end
            end

            if line.include? "Stopping server"
              @status = :stopped
            end

            if line.include? "ERROR" or line.include? "FATAL"
              errors << line
              @putting_block = true
              capturing_error = true

              next
            end

            if line.include? "Starting Minecraft server on"
              @port = line.split(":").last
            end


            if line.include? "[minecraft/DedicatedServer]: Done"
              Log.puts("#{name} is up!", "INFO", name, "Startup")
              Log.puts(@open3_thread.pid.to_s)
              @status = :running
              
              next
            end

            if line.include? "UUID of player"
              player_info = line[/(?<=player )\w+ \w+ [-\w+]/].split
              player_uuid = player_info.last
              player_name = player_info.first

              @current_players[player_name] = KISSCraft::Minecraft::Player.new(player_name, player_uuid)

              next
            end

            if line[/(?<=join with) \d (?=mods)/]
              mods = line.split(":").last.split(",")
              @current_players.values.last.mods = mods
              next
            end

            if line.include? "FAILED TO BIND TO PORT"
              Log.puts("There was already a service running on port #{@port}", "ERROR", name, "Startup")
            end
       
          end
        end
      end
    end
  end
end
