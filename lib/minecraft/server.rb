#!/usr/bin/env ruby

require 'open3'
require_relative 'forge_mod'

module KISSCraft

  module Minecraft

    class Server
      class << self
        def instances
          @@instances
        end

        def get(names)
          if names.is_a? String
            names = [names]
          end

          @@instances.select {|s| names.include? s.name}
        end
      end

      attr_reader :status
      attr_reader :name
      attr_reader :current_players
      attr_reader :pid

      attr_accessor :server_input_queue
      attr_accessor :server_output_queue 
      attr_accessor :console_queue
      attr_accessor :console_connections

      attr_reader :mods

      def initialize(_name)
        @name = _name

        if Dir["./servers/#{name}"].empty?
          Log.puts "ERROR: #{name} does not exit"
          raise ArgumentError
        else
          @server_dir = "./servers/#{name}"
        end

        @current_players = []

        @putting_block = false
        @capturing_error = false

        @server_input_queue = Queue.new
        @server_output_queue = Queue.new
        @console_queue = Queue.new
        @console_connections = Set.new

        @mods = []

        @@instances ||= []
        @@instances << self


        Dir.glob("#{@server_dir}/mods/*").each do |mod_link|

          mod_file = File.realpath mod_link
          
          @mods << KISSCraft::ForgeMod.new(mod_link)
        end
      end

      def start
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
              loop do
                input = server_input_queue.pop
                stdin.puts input
              end
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

      def mod(name)
        @mods.find {|mod| mod.name == name}
      end

      def start_input_output_threads 
        @output_thread = Thread.new do
          errors = []
          loop do
            line = server_output_queue.pop 
            
            Log.server(self, line)
            
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
              Log.server(self, "#{name} is up!", "INFO", "Startup")
              @status = :running 
              next
            end

            if line.include? "UUID of player"
              player_info = line[/(?<=player )\w+ \w+ [-\w+]/].split
              player_uuid = player_info.last
              player_name = player_info.first

              @current_players << KISSCraft::Minecraft::Player.new(player_name, player_uuid)

              next
            end

            if line[/(?<=join with) \d* (?=mods)/]
              mods = line.split(":").last.split(",")
              @current_players.last.set_mods mods
              next
            end

            if line.include? "FAILED TO BIND TO PORT"
              Log.server(server, "There was already a service running on port #{@port}", "ERROR", "Startup")
            end
       
          end
        end
      end
    end
  end
end
