#!/usr/bin/env ruby

require 'json'
module KISSCraft
  class ForgeMod
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
  end
end
