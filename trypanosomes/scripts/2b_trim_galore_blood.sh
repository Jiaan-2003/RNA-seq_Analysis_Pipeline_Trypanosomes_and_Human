#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100g
#SBATCH --time=24:00:00
#SBATCH --job-name=trim_galore_blood
#SBATCH --output=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines output directory
OUTDIR=/path/to/your_directory/trypanosomes/trim_galore/blood

# Creates/checks output directory
mkdir -p "$OUTDIR"

# Runs Trim Galore on blood samples
trim_galore --phred33 --a G{20} --fastqc \
/path/to/your_directory/trypanosomes/raw_data/Blood*.fastq.gz \
-o $OUTDIR

# Deactivates the conda environment
conda deactivate