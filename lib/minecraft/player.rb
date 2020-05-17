#!/usr/bin/env ruby

module KISSCraft

  module Minecraft
    class Player
      attr_reader :name
      attr_reader :uuid
      attr_reader :mods

      def initialize(_name, _uuid)
        @name = _name
        @uuid = _uuid
      end

      def set_mods(mod_arr)
        @mods = mod_arr
      end

      def to_json(*args)
        {name: @name, uuid: @uuid, mods: @mods}.to_json(args)
      end
    end

  end
end

