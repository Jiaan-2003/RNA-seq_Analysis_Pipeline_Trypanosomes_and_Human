#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=50g
#SBATCH --time=12:00:00
#SBATCH --job-name=sam_to_bam_blood
#SBATCH --output=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines input and output paths
INPUT_DIR=/path/to/your_directory/trypanosomes/mapping_bowtie2/sam_files_blood
OUTPUT_DIR=/path/to/your_directory/trypanosomes/mapping_bowtie2/bam_files/blood
SORTED_DIR=/path/to/your_directory/trypanosomes/mapping_bowtie2/bam_files/blood/sorted

# Creates/checks output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$SORTED_DIR"

# Converts SAM files to BAM files
for FILE in "$INPUT_DIR"/*.sam.gz
do
    BASENAME=$(basename "$FILE" .sam.gz)
    samtools view -@ 8 -b "$FILE" > "$OUTPUT_DIR/${BASENAME}.bam"
done

# Sorts and indexes BAM files
for BAM in "$OUTPUT_DIR"/*.bam
do
    BASENAME=$(basename "$BAM" .bam)

    samtools sort -@ 8 "$BAM" -o "$SORTED_DIR/${BASENAME}.sorted.bam"
    samtools index "$SORTED_DIR/${BASENAME}.sorted.bam"
done

# Deactivates the conda environment
conda deactivate