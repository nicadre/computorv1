#!/usr/bin/env ruby

$LOAD_PATH << '.'
require "Polynome.class"

if ARGV.length != 1
    puts "usage: ./computorv1 \"Polynome formula\""
else
    poly = Polynome.new(ARGV[0].to_s).resolve
end
