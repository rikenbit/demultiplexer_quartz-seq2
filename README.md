# Demultiplexer for Quartz-Seq2

## Requirements
### system
* docker
* docker wrapper for Open Grid Scheduler

### software
* samtools 1.3 (fs000:5000/itoshi/samtools)
* Picard (fs000:5000/danno/picard:1.0)
* R + DNABarcodes (fs000:5000/danno/pyper:1.2)
* Ruby (fs000:5000/itoshi/ruby:2.5.1)

## setup 
```
$ cp -a /data2/itoshi/demultiplexer .
$ cd demultiplexer
```

Edit config.yaml. Please add fastq directory and barcode file path to config.yaml.
You should change User ID and Group ID in docker command (-u option).

## Usage 
```
$ rake correct_barcode
$ rake correct_bam
$ rake demulti
```

## Setup rbenv
```
mkdir ~/src
cd ~/src
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
~/.rbenv/bin/rbenv init
```
