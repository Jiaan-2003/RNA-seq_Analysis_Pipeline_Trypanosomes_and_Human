#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=100g
#SBATCH --time=24:00:00
#SBATCH --job-name=fastqc_In_vitro
#SBATCH --output=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Loads the fastqc module
module load fastqc

# Defines input and output paths
INV=/path/to/your_directory/trypanosomes/raw_data/In_vitro*.fastq.gz
OUTDIR=/path/to/your_directory/trypanosomes/fastqc/in_vitro

# Creates/checks output directory
mkdir -p "$OUTDIR"

# Runs fastqc on In vitro samples
fastqc $INV -o $OUTDIR

# Deactivates the conda environment
conda deactivate