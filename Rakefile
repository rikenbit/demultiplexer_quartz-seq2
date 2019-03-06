$LOAD_PATH.push("#{Dir.pwd}/lib")
options = ''
config = File.join(Dir.pwd, "config.yaml")

require 'sge'
require "yaml"
require "pp"
require "fileutils"

desc "View configuration of your project"
task :default do 
  pp "Current directory: " + config
  sge = SGE.new(options , "default", config)
  pp sge
end

desc "001: make unique cell barcode list from fastq file and correct barcodes (options: metric)"
task :correct_barcode do

  metric   = ENV['metric']
  # distance = ENV['distance']

  top_dir = "/" + Dir.pwd.split(/\//)[1]

  # options = ['#!/bin/bash'].join("\n")
  options = ['#!/bin/zsh'].join("\n")
  sge = SGE.new(options , "corcb", config)
  dir = sge.params['db']['fastq_dir']
  r   = sge.params['docker']['run'] +
        " -v #{top_dir}\:#{top_dir} #{sge.params['docker']['image']['R']} "
  ruby = sge.params['docker']['run'] +
         " -i -v #{top_dir}\:#{top_dir} #{sge.params['docker']['image']['ruby']}"

  Dir.open(dir).each do |file|
    next unless /R1_.+\.fastq\.gz$/ =~ file
    fastq_basename = file.sub(/_R1_\d{3}\.fastq\.gz/, "")
    output = File.join(sge.params['results'], fastq_basename + ".cor_cbr.txt")
    output = File.expand_path(output)

    fastq  = File.expand_path(File.join(dir, file))

=begin
    puts file
    puts fastq_basename
    puts output
    puts fastq
=end

    program = File.join(sge.params['bin'], "make_unique_cb.rb")
    program = File.expand_path(program)
    # cmd = "#{ruby} ruby #{program} <(zcat #{fastq}) > #{output}\n"
    # cmd = "zcat #{fastq} | #{ruby} ruby #{program} > #{output}\n"
    # cmd = "sh -c 'zcat #{fastq} | #{ruby} ruby #{program} > #{output}'\n"
    cmd = "zcat #{fastq} | ruby #{program} > #{output}\n"

    program = File.join(sge.params['bin'], "correct_barcodes.R")
    program = File.expand_path(program)
    cmd << "#{r} \\\nsh -c 'R -q -f #{program} --args #{metric} #{output} #{sge.params['db']['barcode_list']}'\n"

    # ruby make_unique_cb.rb <(zcat 20180502_HCA_pilot/results/fastq/HCA_p2_S5_R1_001.fastq.gz) > all_cb.txgt
    puts cmd
    sge.prepare(cmd)
    sge.submit('node.q')

  end
end

desc "002: make Bam file from fastq1 and fastq2 and correct barcode in the bam file (options: distance, length)"
task :correct_bam do
  # options = ['#!/bin/bash'].join("\n")
  barcode_distance = ENV['distance']
  barcode_length   = ENV['length']
  options = ['#!/bin/zsh'].join("\n")
  sge = SGE.new(options , "corbam", config)
  dir = sge.params['db']['fastq_dir']

  top_dir = "/" + Dir.pwd.split(/\//)[1]
  picard   = sge.params['docker']['run'] +
               " -v #{top_dir}\:#{top_dir} #{sge.params['docker']['image']['picard']} "
  samtools = sge.params['docker']['run'] +
               " -v #{Dir.pwd}\:#{Dir.pwd} #{sge.params['docker']['image']['samtools']} "
  ruby = sge.params['docker']['run'] +
         " -i -v #{Dir.pwd}\:#{Dir.pwd} #{sge.params['docker']['image']['ruby']}"

  corrector = File.join(sge.params['bin'], "correct_bam.rb")
  corrector = File.expand_path(corrector)

  Dir.open(dir).each do |file|
    next unless /R1_.+\.fastq\.gz$/ =~ file
    fastq_basename = file.sub(/_R1_\d{3}\.fastq\.gz/, "")

    output_dir = File.join(sge.params['results'], fastq_basename)
    output_dir = File.expand_path(output_dir)
    Dir.mkdir(output_dir) unless FileTest.exist? output_dir

    fastq1 = File.expand_path(File.join(dir, file))
    fastq2 = fastq1.sub(/_R1_/, "_R2_")

    program = "/usr/local/picard-tools-1.134/picard.jar"
    quality_format     = "Standard"
    sample_name_header = "development"
    sort_order         = "queryname"

    output_file = File.join(
      output_dir,
      fastq_basename + ".unaln.bam"
    )
    correct_sam_file = File.join(
      output_dir,
      fastq_basename + ".correct.sam"
    )
    correct_bam_file = File.join(
      output_dir,
      fastq_basename + ".correct.bam"
    )

=begin
    cmd = "#{picard} sh -c 'java -XX:ParallelGCThreads=8 -Xmx128g " +
             " -Djava.io.tmpdir=" + output_dir       +
             " -jar #{program} FastqToSam \\\n"      +
             " FASTQ="          + fastq1             +
             " FASTQ2="         + fastq2             +
             " QUALITY_FORMAT=" + quality_format     +
             " OUTPUT="         + output_file        +
             " SAMPLE_NAME="    + sample_name_header +
             " SORT_ORDER="     + sort_order         +
             " TMP_DIR="        + output_dir         + "'\n"
=end
    cmd = "" 
    borcode_list = output_dir + ".cor_cbr.txt"
    cmd << "#{samtools} sh -c 'samtools view -h #{output_file}' |"
    cmd << " ruby #{corrector} #{barcode_distance} #{barcode_length} #{borcode_list} > #{correct_sam_file}\n"
    cmd << "#{samtools} sh -c 'samtools view -Sb #{correct_sam_file} > #{correct_bam_file}'"
    # puts cmd
    sge.prepare(cmd)
    sge.submit('node.q')
    break

  end
end

desc "003: demulti fastq"
task :demulti do
  # options = ['#!/bin/bash'].join("\n")
  options = ['#!/bin/zsh'].join("\n")
  sge = SGE.new(options , "dm", config)
  barcode_file = sge.params['db']['barcode_list']

  program = File.join(sge.params['bin'], "demulti_bam2fastq.rb")
  program = File.expand_path(program)

  samtools = sge.params['docker']['run'] +
               " -v #{Dir.pwd}\:#{Dir.pwd} #{sge.params['docker']['image']['samtools']}"
  ruby     = sge.params['docker']['run'] +
               " -i -v #{Dir.pwd}\:#{Dir.pwd} #{sge.params['docker']['image']['ruby']}"

  input_dir = File.expand_path(sge.params['results'])
  puts input_dir
  Dir.glob("#{input_dir}/*/*.correct.bam").each do |bam|

    bam_basename = File.basename(bam, ".correct.bam")
    output_dir = File.dirname(File.expand_path(bam))
    output_fq_basename = File.join(output_dir, bam_basename)

    barcodes = File.open(barcode_file).readlines
    unknown_bc = 'N' * 15
    barcodes.push(unknown_bc)

    barcodes.each do |barcode|
      barcode.chomp!

      cmd = <<~"EOS"
      #{samtools} sh -c 'samtools view #{bam}' | ruby #{program} #{barcode} #{output_fq_basename}
      EOS

      puts cmd
      sge.prepare(cmd)
      sge.submit('node.q')
    end
  end
end

desc "004: cat demulti-ed fastq"
task :cat_fq do
  # ir = File.join(ENV['PWD'], "results")
  dir = File.join(Dir.pwd, "results")
  Dir.open(dir).each do |path|
    next if /^\./ =~ path
    path = File.join(dir, path) 
    next unless FileTest.directory? path

    fq1_pat = File.join(path, "*_1.fastq.gz")
    fq2_pat = File.join(path, "*_2.fastq.gz")
    # puts fq1_pat
    # puts fq2_pat

    cat_fq1 = path + "_1.fastq.gz"
    cat_fq2 = path + "_2.fastq.gz"
    # puts cat_fq1
    # puts cat_fq2
    cmd = "zcat #{fq1_pat} > #{cat_fq1}; zcat #{fq2_pat} > #{cat_fq2}"
    sh cmd

  end
end

desc "004: count a number of reads in FASTQ"
task :count_fq do
  # dir = File.join(Dir.pwd, "results")
  sge = SGE.new(options , "count_fq", config)
  dir = '../hca2/results'
  output = File.join(sge.params['results'], "total_read.tsv")
  cmd = 'ls DIR/*/*_2.fastq.gz|xargs wc -l|perl -pe "s/^\s+//g; s/ /\t/g"|sort -k 1 -g'
  cmd << " > #{output}"
  cmd.sub!(/DIR/, dir)
  puts cmd
end
