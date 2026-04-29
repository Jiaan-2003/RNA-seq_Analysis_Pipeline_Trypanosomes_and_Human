#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=100g
#SBATCH --time=24:00:00
#SBATCH --job-name=fastqc_blood
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
BLOOD=/path/to/your_directory/trypanosomes/raw_data/Blood*.fastq.gz
OUTDIR=/path/to/your_directory/trypanosomes/fastqc/blood

# Creates/checks output directory
mkdir -p "$OUTDIR"

# Runs FastQC on blood samples
fastqc $BLOOD -o $OUTDIR

# Deactivates the conda environment
conda deactivate