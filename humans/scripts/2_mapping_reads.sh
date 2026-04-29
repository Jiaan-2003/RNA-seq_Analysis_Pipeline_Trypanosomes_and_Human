#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=100g
#SBATCH --time=12:00:00
#SBATCH --job-name=mapping_reads
#SBATCH --output=/path/to/your_directory/human/scripts/logs/slurm-%x-%j.out
#SBATCH --error=/path/to/your_directory/human/scripts/logs/slurm-%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.name@example.example

# Activates the conda environment
source $HOME/.bash_profile
conda activate rotation2

# Defines output directory paths
OUTPUT_DIR_ADENO=/path/to/your_directory/human/mapping/adeno_align
OUTPUT_DIR_HEPATO=/path/to/your_directory/human/mapping/hepato_align

# Defines index directory path
INDEX_DIR=/path/to/your_directory/human/reference_files/GRCh38_index

# Defines input directory paths
INPUT_DIR_ADENO=/path/to/your_directory/human/raw_data/adeno_carcinoma
INPUT_DIR_HEPATO=/path/to/your_directory/human/raw_data/hepatocellular_carcinoma

# Creates/checks output directories
mkdir -p "$OUTPUT_DIR_ADENO"
mkdir -p "$OUTPUT_DIR_HEPATO"

# Adenocarcinoma samples
SAMPLE1_ADENO=ERR1404760
SAMPLE2_ADENO=ERR1404761
SAMPLE3_ADENO=ERR1404762
SAMPLE4_ADENO=ERR1404763
SAMPLE5_ADENO=ERR1404764
SAMPLE6_ADENO=ERR1404765
SAMPLE7_ADENO=ERR1404766
SAMPLE8_ADENO=ERR1404767
SAMPLE9_ADENO=ERR1404768
SAMPLE10_ADENO=ERR1404769
SAMPLE11_ADENO=ERR1404770
SAMPLE12_ADENO=ERR1404771
SAMPLE13_ADENO=ERR1404772
SAMPLE14_ADENO=ERR1404773
SAMPLE15_ADENO=ERR1404774

# Hepatocellular carcinoma samples
SAMPLE1_HEPATO=ERR1404781
SAMPLE2_HEPATO=ERR1404782
SAMPLE3_HEPATO=ERR1404783
SAMPLE4_HEPATO=ERR1404784

# Runs STAR alignment for adenocarcinoma samples
cd $INPUT_DIR_ADENO

for samples in $SAMPLE1_ADENO $SAMPLE2_ADENO $SAMPLE3_ADENO $SAMPLE4_ADENO $SAMPLE5_ADENO $SAMPLE6_ADENO \
$SAMPLE7_ADENO $SAMPLE8_ADENO $SAMPLE9_ADENO $SAMPLE10_ADENO $SAMPLE11_ADENO \
$SAMPLE12_ADENO $SAMPLE13_ADENO $SAMPLE14_ADENO $SAMPLE15_ADENO
do
STAR --runThreadN 32 --genomeDir $INDEX_DIR --quantMode GeneCounts \
--readFilesIn ${samples}_1.fastq.gz ${samples}_2.fastq.gz \
--readFilesCommand zcat \
--outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix $OUTPUT_DIR_ADENO/${samples}_
done

# Runs STAR alignment for hepatocellular carcinoma samples
cd $INPUT_DIR_HEPATO

for samples in $SAMPLE1_HEPATO $SAMPLE2_HEPATO $SAMPLE3_HEPATO $SAMPLE4_HEPATO
do
STAR --runThreadN 32 --genomeDir $INDEX_DIR --quantMode GeneCounts \
--readFilesIn ${samples}_1.fastq.gz ${samples}_2.fastq.gz \
--readFilesCommand zcat \
--outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix $OUTPUT_DIR_HEPATO/${samples}_
done

# Deactivates the conda environment
conda deactivate