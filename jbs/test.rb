#!/usr/bin/env ruby

if ARGV.empty?
  puts "oops"
  exit
else
  puts ARGV
end

puts "This should never be printed if ARGV is empty"
