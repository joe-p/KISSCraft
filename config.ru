#!/usr/bin/env ruby
require "roda"

require_relative 'web/webapp'

run KISSCraft::WebApp.freeze.app


