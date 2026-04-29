#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100g
#SBATCH --time=24:00:00
#SBATCH --job-name=trim_galore_in_vitro
#SBATCH --output=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines output directory
OUTDIR=/path/to/your_directory/trypanosomes/trim_galore/in_vitro

# Creates/checks output directory
mkdir -p "$OUTDIR"

# Runs Trim Galore on In vitro samples
trim_galore --phred33 --fastqc --a G{20} --a T{20} --a A{20} \
/path/to/your_directory/trypanosomes/raw_data/In_vitro*.fastq.gz \
-o $OUTDIR

# Deactivates the conda environment
conda deactivate