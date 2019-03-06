#!/usr/bin/env ruby

my_distance, length_barcode, barcode_file = ARGV
length_barcode = length_barcode.to_i - 1 # 15
# puts my_distance
# puts barcode_file

# import bc
barcodes = Hash.new
File.open(barcode_file).each_with_index do |line, i|
  line.chomp!
  next if i == 1
  read, barcode, distance = line.split(/\t/)
  next if distance.to_i > my_distance.to_i
  barcodes[read] = barcode
end

# ARGF.each_with_index do |line, i|
STDIN.each_with_index do |line, i|
  line.chomp!

  if i <= 2 
    puts line
    next
  end

  if (i % 2) == 0

    f = line.split(/\t/)
    seq = f[-3]
    cb = seq[0..length_barcode]
    correct_barcode = barcodes[cb]
    correct_barcode = 'N' * (length_barcode + 1) if correct_barcode == nil

=begin
    puts "### debug ###"
    puts "Original: #{line}"
    puts seq
    puts "cb (seq): #{cb}"
    puts "cb (cor): #{correct_barcode}"
    puts "#############"
=end
    read = correct_barcode + seq[15..-1]
    f[-3] = read
    puts f.join("\t")
  else
    puts line
  end
end
