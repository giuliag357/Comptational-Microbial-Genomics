#!/bin/bash

cd SGB2208/

# quality checking
mkdir checkm_output

conda deactivate && conda activate checkm

bunzip2 mags/*
checkm taxonomy_wf domain Bacteria mags checkm_output -t 4

less -S checkm_output/storage/bin_stats_ext.tsv

conda deactivate

# taxonomic assignment
mkdir phylophlan_output

conda activate ppa

phylophlan_metagenomic --database_list

phylophlan_metagenomic -i mags -o phylophlan_output/ppa_m \
--nproc 4 -n 1 -d CMG2324 --database_folder ~/ppa_db --verbose

less -S phylophlan_output/ppa_m.tsv

conda deactivate

# genome annotation

./run_prokka.sh

cat prokka_output/${mag}/${mag}.txt

cat prokka_output/${mag}/${mag}.tsv | grep `hypothetical`

cat prokka_output/${mag}/${mag}.tsv | grep -v `hypothetical` | grep `CDS` | wc -l

# pangenome analysis

conda activate roary

roary prokka_output/*/*.gff \
	-f roary_output \
	-i 95 \
	-cd 90 \
	-p 4

cd roary_output

curl https://github.com/sanger-pathogens/Roary/blob/master/bin/create_pan_genome_plots.R \
	-o create_pan_genome_plots.R
chmod +x create_pan_genome_plots.R

conda deactivate && conda activate roary_plots

Rscript create_pan_genome_plots.R

curl https://github.com/sanger-pathogens/Roary/blob/master/contrib/roary_plots/roary_plots.py \
	-o roary_plots.py

python roary_plots.py accessory_binary_genes.fa.newick gene_presence_absence.csv

conda deactivate

# phylogenetic analysis

conda activate roary

roary prokka_output/*/*.gff \
	-f roary_output_w_aln \
	-cd 90 \
	-p 4
	-e -n

FastTreeMP -pseudo -spr 4 -mlacc 2 -slownni -fastest -no2nd -mlnni 4 -gtr -nt \
	-out roary_output_w_aln/core_gene_phylogeny.nwk roary_output_w_aln/core_gene_alignment.aln

conda deactivate

