#!/usr/bin/env ruby

require 'json'

module KISSCraft
  class ForgeMod
    # The attributes from mcmod.info
    attr_reader :modid
    attr_reader :name
    attr_reader :description
    attr_reader :version
    attr_reader :credits
    attr_reader :url
    attr_reader :author_list
    attr_reader :required_mods
    attr_reader :dependencies

    def initialize(jar_path)
      @path = jar_path

      mcmod_info = `unzip -p #{jar_path} mcmod.info`
      mcmod_info = JSON.parse(mcmod_info)

      if mcmod_info.is_a? Array
        mcmod_info = mcmod_info.first
      end

      keys = 
        [
          "modid", 
          "name", 
          "description", 
          "version", 
          "credits", 
          "url", 
          "authorList",
          "requiredMods",
          "dependencies"
        ]

      keys.each do |key|
        value = mcmod_info[key]

        cap_letter = key[/[A-Z]/]

        if cap_letter
          key.gsub!(cap_letter, "_#{cap_letter.downcase}")
        end

        instance_variable_set("@#{key}".to_sym, value)

      end
    end

    def enabled?
      !@path.include? ".disabled"
    end

    def toggle
      enabled? ? disable : enable
    end

    def disable
      old = @path.dup
      new = @path.gsub!(".jar", ".disabled")

      File.rename(old, new) 
    end

    def enable
      old = @path.dup
      new = @path.gsub!(".disabled", ".jar")
      
      File.rename(old, new)
    end
  end
end
