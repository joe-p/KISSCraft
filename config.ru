#!/usr/bin/env -S falcon serve --count 1 --config

require "roda"

require_relative 'web/webapp'

run KISSCraft::WebApp.freeze.app


