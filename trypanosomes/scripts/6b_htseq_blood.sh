#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100g
#SBATCH --time=04:00:00
#SBATCH --job-name=htseq_blood
#SBATCH --output=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/trypanosomes/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines input, output and reference annotation paths
INPUT_DIR=/path/to/your_directory/trypanosomes/mapping_bowtie2/bam_files/blood/sorted
OUTPUT_DIR=/path/to/your_directory/trypanosomes/htseq/blood
GFF_FILE=/path/to/your_directory/trypanosomes/reference_files/TriTrypDB-68_TbruceiTREU927.gff

# Creates/checks output directory
mkdir -p "$OUTPUT_DIR"

# Defines parameters for counting
FEATURE_TYPE="exon"
GENE_ATTR="Parent"
STRANDED="yes"
BAM_ORDER="pos"

# Uses BAM files from the mentioned directory and not any subdirectories
mapfile -t BAMS < <(find "$INPUT_DIR" -maxdepth 1 -type f -name "*.bam" | sort)

# Stops the script if no BAM files are found (error handling)
if [[ ${#BAMS[@]} -eq 0 ]]; then
  echo "No BAM files found in $INPUT_DIR" >&2
  exit 1
fi

# Runs HTSeq-count on each BAM file
for BAM in "${BAMS[@]}"
do
    BASENAME=$(basename "$BAM" .bam)
    OUT_FILE="${OUTPUT_DIR}/${BASENAME}.counts.txt"

    htseq-count \
    -f bam \
    -r "$BAM_ORDER" \
    -s "$STRANDED" \
    -t "$FEATURE_TYPE" \
    -i "$GENE_ATTR" \
    --mode union \
    "$BAM" "$GFF_FILE" > "$OUT_FILE"
done

# Deactivates the conda environment
conda deactivate