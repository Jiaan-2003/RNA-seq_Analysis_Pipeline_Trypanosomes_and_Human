#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100g
#SBATCH --time=02:00:00
#SBATCH --job-name=bowtie2_index
#SBATCH --output=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines reference input path and index output path
REF=/path/to/your_directory/trypanosomes/reference_files/TriTrypDB-68_TbruceiTREU927_Genome.fasta
OUTDIR=/path/to/your_directory/trypanosomes/reference_files/index

# Creates/checks index directory
mkdir -p "$OUTDIR"

# Bowtie build command builds an index from the reference genome
bowtie2-build $REF $OUTDIR/index_tbrucei

# Deactivates the conda environment
conda deactivate