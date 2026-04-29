#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=100g
#SBATCH --time=12:00:00
#SBATCH --job-name=genome_index
#SBATCH --output=/path/to/your_directory/human/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/human/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines reference input paths and STAR index output path
OUTDIR=/path/to/your_directory/human/reference_files/GRCh38_index
REF_FASTA=/path/to/your_directory/human/reference_files/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa
REF_GTF=/path/to/your_directory/human/reference_files/Homo_sapiens.GRCh38.115.gtf

# Creates/checks index directory
mkdir -p "$OUTDIR"

# Builds STAR genome index from the human reference genome and annotation
STAR \
--runThreadN 32 \
--runMode genomeGenerate \
--genomeDir "$OUTDIR" \
--genomeFastaFiles "$REF_FASTA" \
--sjdbGTFfile "$REF_GTF" \
--sjdbOverhang 100

# Deactivates the conda environment
conda deactivate