#!/usr/bin/env ruby

i = 0
cbs = Hash.new
ARGF.each do |line|
  i = i + 1 
  if (i % 4) == 2
    # puts line
    cb = line[0..14]
    cbs[cb] = nil
  end
end

cbs.keys.each do |cb|
  puts cb
end
