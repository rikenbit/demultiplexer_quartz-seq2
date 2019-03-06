#!/usr/bin/env ruby

picard = "$HOME/opt/local/bin/picard.jar"

output_dir, input_file_R1, input_file_R2 = ARGV

quality_format     = "Standard"
sample_name_header = "development"
sort_order         = "queryname"

output_file = File.join(
  output_dir,
  File.basename(input_file_R1, ".fastq.gz") + ".bam"
)

cmd = "java -XX:ParallelGCThreads=8 -Xmx128g \\\n" +
           "    -Djava.io.tmpdir=" + output_dir + " \\\n" +
           "    -jar #{picard} FastqToSam \\\n" +
           "    FASTQ="  + input_file_R1 + " \\\n" +
           "    FASTQ2=" + input_file_R2 + " \\\n" +
           "    QUALITY_FORMAT=" + quality_format + " \\\n" +
           "    OUTPUT=" + output_file + " \\\n" +
           "    SAMPLE_NAME=" + sample_name_header + " \\\n" +
           "    SORT_ORDER=" + sort_order + " \\\n" +
           "    TMP_DIR=" + output_dir + ""
system cmd
