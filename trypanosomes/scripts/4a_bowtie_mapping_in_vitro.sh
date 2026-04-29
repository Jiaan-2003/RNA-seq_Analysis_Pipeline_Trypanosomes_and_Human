#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100g
#SBATCH --time=03:00:00
#SBATCH --job-name=bowtie2_mapping_in_vitro
#SBATCH --output=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines paths for input, output and index files
INPUT_DIR=/path/to/your_directory/trypanosomes/trim_galore/in_vitro
OUTPUT_DIR=/path/to/your_directory/trypanosomes/mapping_bowtie2/sam_files_in_vitro
INDEX=/path/to/your_directory/trypanosomes/reference_files/index/index_tbrucei

# Creates/checks output directory
mkdir -p "$OUTPUT_DIR"

# Creates a loop so each trimmed file is mapped individually
for FILE in $INPUT_DIR/*.fq.gz
do
        BASENAME=$(basename "$FILE" .fq.gz)

        echo "Processing $BASENAME"

        bowtie2 \
        -x "$INDEX" \
        -U "$FILE" \
        -p 8 \
        | gzip > "$OUTPUT_DIR/${BASENAME}.sam.gz"

done

# Deactivates the conda environment
conda deactivate