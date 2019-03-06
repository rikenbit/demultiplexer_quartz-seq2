library(DNABarcodes)

args = commandArgs(TRUE)
# metric = "seqlev"
# metric = "hamming"

metric       = args[1]
# distance     = args[2]
xc_file      = args[2]
barcode_file = args[3]

output = sub(".cbr_fq.txt", ".cor_cbr.txt", xc_file)
print(output) 

## input files
xc_barcodes = read.table(xc_file)
xc_barcodes = as.vector(xc_barcodes[,1])
designed_barcodes = read.table(barcode_file)
designed_barcodes = as.vector(designed_barcodes[,1])

demultiplexed = demultiplex(xc_barcodes, designed_barcodes, metric = metric)
write.table(demultiplexed, file = output, sep = "\t", quote = F, row.names = FALSE)
# distance <= 2
