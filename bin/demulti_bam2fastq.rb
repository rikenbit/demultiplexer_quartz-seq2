#!/usr/bin/env ruby

require 'zlib'

barcode = ARGV.shift
output  = ARGV.shift

# p [barcode, output]

fq1_file = output + "_#{barcode}_1.fastq.gz"
fq2_file = output + "_#{barcode}_2.fastq.gz"

fq1 = File.open(fq1_file, "w")
fq2 = File.open(fq2_file, "w")

# p [fq1, fq2]

gz1 = Zlib::GzipWriter.new(fq1)
gz2 = Zlib::GzipWriter.new(fq2)

i = 0
ARGF.each_slice(2) do |lines|

  f = lines[0].split(/\t/)
  seq = f[9]
  cb = seq[0..14]

  if barcode == cb

    # p lines

    read1 = ""
    header = f[0]
    read   = f[9]
    qv     = f[10]
    read1 = ['@' + header, read, '+', qv].join("\n")
    gz1.puts read1
    # fq1.puts read1

    read2 = ""
    f = lines[1].split(/\t/)
    read   = f[9]
    qv     = f[10]
    read2 = ['@' + header, read, '+', qv].join("\n")
    gz2.puts read2
    # fq2.puts read2

  end
end

gz1.close
gz2.close

#fq1.close
#fq2.close
