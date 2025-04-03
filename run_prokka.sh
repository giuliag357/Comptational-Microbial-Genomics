#!/bin/bash

#initializing conda
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh

conda activate prokka

prokka -h

for f in mags/*
do
	mag=$( basename $f .fna )
	mkdir -p prokka_output/${mag}
	#echo $mag

	prokka mags/${mag}.fna \
		--outdir prokka_output/${mag} \
		--compliant \
		--prefix ${mag} \
		--force 
done

conda deactivate
