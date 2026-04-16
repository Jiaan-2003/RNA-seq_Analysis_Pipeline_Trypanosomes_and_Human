### LIFE4136-Rotation2: RNA-seq Analysis Pipeline: Trypanosomes and Human Data

This repository contains an RNA-Seq workflow produced for LIFE4136 Rotation 2 Coursework. The study includes Trypanosome blood and in vitro samples, as well as human cancer samples of adenocarcinoma and hepatocellular carcinoma.

## Introduction and Biological Background

This GitHub repository details a pipeline used to conduct an RNA sequencing (RNA-Seq) analysis on Trypanosome and human datasets. RNA-Seq is a highly effective tool for studying the transcriptome, due to its high sensitivity and accuracy for measuring expression, which aids in analysing differentially expressed genes between biological conditions. Its importance is highlighted by its role in allowing researchers to identify previously undetected changes that occur in disease states in response to studies that focus on treatment [1]. RNA-Seq succeeds older methods such as Sanger sequencing and microarrays, as it provides higher coverage and greater resolution, which are able to detect both known and novel transcripts [2]. 

The Trypanosome dataset used in this project was selected for its biological relevance, as it is associated with the Human African trypanosomiasis (HAT), which is also referred to as the sleeping sickness. HAT is caused by the parasite Trypanosoma brucei (T.brucei) and is primarily transmitted by tsetse flies. The life-cycle of the disease is complex due to the infection transferring from the fly to a human host, where it can live in the human host for a long period of time before obvious symptoms. These symptoms vary in severity and time depending on the type of HAT infection. The disease in its final stage causes coma, which is followed by death due to the parasite crossing the blood-brain barrier [3]. RNA-Seq can be applied to data focusing on this disease to study the transcriptomic differences between blood and in vitro conditions, as it may provide insights into how genetic differentiation allows the parasite to thrive in different host environments.

The human dataset focused on two types of cancer samples, adenocarcinoma (AC) and hepatocellular carcinoma (HCC). AC is a cancer found in the glands that line many organs, where tumour formation can occur if the glands are influenced to grow out of control. These tumours can then break apart and spread around the body [4]. HCC is the most common form of liver cancer that initially begins in liver cells known as hepatocytes. Tumour formation in this occurs due to a pre-diseased liver that undergoes cellular changes, which produce more abnormal cells that can result in tumour growth. Similar to AC, these cells can break apart and spread to other areas of the body, causing harm [5].

Both of these datasets provided vital raw data that could be processed in the pipeline so an RNA-Seq analysis could be completed. The project aimed to demonstrate how appropriate bioinformatics pipelines can produce biologically correct and interpretable results that may help to identify potential therapeutic targets or biomarkers to combat diseases such as those involved in this study.

## About the Data

These scripts include an assumed "raw_data" directory, which is empty in this repository due to large file sizes. Both datasets were copied from a shared HPC resource into working directories prior to running the original pipeline

The Trypanosome raw dataset consists of 10 samples, including 5 blood and 5 in vitro conditions. Each FASTQ file ranged approximately between 3.3G-4.8G in file size.

The human raw dataset consists of pre-quality controlled paired-end RNA-Seq FASTQ files of adenocarcinoma and hepatocellular carcinoma samples. The dataset used was E-MTAB-4681, accessed via ArrayExpress, to determine which sample types corresponded to the conditions being studied. A total of 19 samples were identified for use in the pipeline, including 15 adenocarcinoma samples and 4 hepatocellular carcinoma samples. Each relevant paired-end FASTQ file was copied to a working directory on the HPC, ranging from 0.7G to 2.8G individually in file size. The IDs of the samples can be seen below, with the corresponding condition they belong to. These samples are important for this specific pipeline as they are processed into count files used in downstream DESeq2 analysis.

| Adenocarcinoma Sample IDs | Hepatocellular Carcinoma Sample IDs |
| ------------------------- | ----------------------------------- |
| ERR1404760                | ERR1404781                          |
| ERR1404761                | ERR1404782                          |
| ERR1404762                | ERR1404783                          |
| ERR1404763                | ERR1404784                          |
| ERR1404764                |                                     |
| ERR1404765                |                                     |
| ERR1404766                |                                     |
| ERR1404767                |                                     |
| ERR1404768                |                                     |
| ERR1404769                |                                     |
| ERR1404770                |                                     |
| ERR1404771                |                                     |
| ERR1404772                |                                     |
| ERR1404773                |                                     |
| ERR1404774                |                                     |

## Reference Files

It is crucial to use the correct reference files when conducting this workflow. Scripts in the workflow point to placeholder paths that contain “/trypanosomes/reference_files” and “/humans/reference_files”, so ensure these directories contain the correct files before using the pipeline.

The Trypanosoma brucei reference genome and annotation files were obtained from TriTrypDB (release 68) and can be downloaded [here](https://tritrypdb.org/tritrypdb/app/downloads). These files are also available in this repository under “trypanosomes/reference_files” as their file size is not too large (8.8M and 35M). If the user decides to download these reference files independently, ensure they are “TriTrypDB-68_TbruceiTREU927.gff” and “TriTrypDB-68_TbruceiTREU927.fasta”.

The human reference genome and annotation files (GRCh38) were obtained from Ensembl and can be downloaded [here](https://www.ensembl.org/). These files are not available in the “humans/reference_files” directory in this repository, as they are too large in file size (3.0G and 3.1G). Before running the humans part of the pipeline, ensure “Homo_sapiens.GRCh38.115.gtf” and “Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa” have been downloaded, and ideally placed into the reference files directory in the humans directory.


## Part 1: Trypanosome Pipeline

The Trypanosome pipeline is a core RNA-Seq workflow that includes quality control, trimming, indexing, sample counting and differential expression analysis. 

This is a 7-step pipeline for the trypanosomes analysis that contains the full workflow needed to obtain DESeq2 results of the in vitro and blood samples. Some steps contain 2 scripts (e.g., 1a and 1b), as “a” corresponds to in vitro samples and “b” corresponds to blood samples, so be sure to run both. Upon successful completion of a script, any files or results produced by the final step of the pipeline should be found in the trypanosomes directory. Files produced throughout the pipeline can be found in their respective subdirectories within the trypanosomes folder.

# FastQC Quality Control

This script is the first step of the pipeline that uses FastQC to analyse the quality of the raw blood and in vitro FASTQ files selected for the analysis. This script provides FastQC HTML reports, which can be downloaded and viewed to assess the quality of each sample. A range of statistics can be assessed by these reports, including per-base sequence quality, per-sequence GC content, overrepresented sequences, and much more. Reports can be found in the “/fastqc/in_vitro” and “/fastqc/blood” directories.

Input: Raw FASTQ sample files

Output: FastQC reports

# Read Trimming with Trim Galore

This next script uses Trim Galore to trim the reads by removing any low-quality bases and adapter sequences from the reads. This provides updated trimmed reports of each sample and trimmed reads that have been quality-controlled for further use in the pipeline. Reports and trimmed data can be found in the “/trim_galore/in_vitro” and “/trim_galore/blood” directories.

Input: Raw FASTQ files

Output: Trimmed FASTQ files and Trimmed FastQC reports (txt and html)

# Reference Indexing with Bowtie2-build

This script utilises Bowtie2-build to create an index from the reference genome file “TriTrypDB-68_TbruceiTREU927_Genome.fasta” for use downstream in the pipeline. The indexed files can be found in the “/references_files/index” directory.

Input: Reference genome

Output: Bowtie2 index files


# Read Mapping with Bowtie2

This step uses a script to map reads from in vitro and blood samples to the indexed reference genome, producing SAM files for both sample types. SAM files can be found in the “/mapping_bowtie2/sam_files_in_vitro” and “/mapping_bowtie2/sam_files_blood” directories.

Input: Trimmed FASTQ files

Reference: Indexed genome

Output: SAM files

# Conversion from SAM to BAM, Sorting and Indexing with SAMtools

This script uses SAMtools to first convert the SAM files for samples into BAM files for downstream use, and then sort and index the files. The converted BAM files can be found in the “/mapping_bowtie2/bam_files/in_vitro” and “/mapping_bowtie2/bam_files/blood” directories. The sorted and indexed files can be found in the “/mapping_bowtie2/bam_files/in_vitro/sorted” and “/mapping_bowtie2/bam_files/blood/sorted” directories.

Input: SAM files

Output: BAM files, sorted BAM files and index bam.bai files

# Sample Counting with HTSeq

This stage involves a script that applies HTSeq-count on each sorted BAM file for the samples, along with a “TriTrypDB-68_TbruceiTREU927.gff” file as an annotation file. The count text file for each sample can be found in “/htseq/in_vitro” and “/htseq/blood” directories. The gff file is located in the reference files (“/references_files”).

Input: sorted BAM files

Annotation input: gff file

Output: Count text (txt) files

# Differential Expression Analysis with DESeq2 and R Studio Packages

 This final step of the pipeline uses an R script, which produced a range of results from the workflow. It is an R script that uses the DESeq2 package to produce the differential expression analysis results that can be used to compare blood and in vitro samples. Following this, various visualised plots were produced to aid in the assessment of the comparison between the two result types. This includes a PCA plot, a volcano plot, an MA plot, and a heatmap, all made with “ggplot” and “pheatmap”. All results from this script should be found in the “/results” directory. 

Input: all trimmed count text files

Output: DESeq2 (differential expression analysis) results table, heatmap, PCA plot, volcano plot and MA plot.


## Part 2: Human Pipeline

The human pipeline uses pre-processed data to perform downstream analysis, following genome indexing, read mapping and count file creation.

This is a 3-script pipeline required to obtain DESeq2 results that compare human samples of adenocarcinoma and hepatocellular carcinoma, along with a heatmap, PCA plot, volcano plot and MA plot. This pipeline is much shorter than the Trypanosomes pipeline, as the raw data were already pre-processed, meaning steps like trimming and sample removal were not required. Upon successful completion of a script, any files or results produced by the final step of the pipeline should be found in the human path of the directory. Other files produced in the pipeline can be found in their allocated paths in the human folder as well.

# Reference Indexing with STAR

The first script used STAR to build a genome index from the reference genome file, required for downstream analysis, “Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa” and the reference annotation file “Homo_sapiens.GRCh38.115.gtf”. The indexed reference file can be found in the “/reference_files/GRCh38_index”.

Input: reference FASTA and GTF

Output: STAR indexed reference

# Read Mapping and Count Files Creation with STAR

The second script utilises STAR again, as this time it aligned samples alongside the indexed reference produced. This script used STAR’s GeneCounts quantmode to produce the count files required for the final DESeq2 analysis script and also produced sorted BAM files. The count file and sorted BAM outputs can be found in “/mapping/adeno_align” and “/mapping/hepato_align”.

Input: pair-end raw data FASTQ files and indexed reference

Output: ReadsPerGene.out.tab (count files) and sorted BAM files

# Differential Expression Analysis with DESeq2 and R Studio Packages

This final step for the pipeline is an R script that uses the DESeq2 package to produce the differential expression analysis results that can be used to compare adenocarcinoma and hepatocellular carcinoma samples. Following this, various visualised plots were produced to aid in the assessment of the comparison between the two result types. This includes a PCA plot, a volcano plot, an MA plot, and a heatmap, all made with “ggplot” and “pheatmap”. All results from this script should be found in the “/results” directory.

Input: ReadsPerGene.out.tab files

Output: DESeq2 (differential expression analysis) results table, heatmap, PCA plot, volcano plot and MA plot. 

## Key Steps for Reproducibility and Usage

Ideally, this pipeline should be reproducible with the raw data discussed in this GitHub repo.  However, the reproducibility of this pipeline does have certain requirements, and there are some key tips to know when using the pipeline:

- All of the BASH SLURM scripts were run on an HPC system, making an HPC essential for this workflow.
Certain SLURM setting options at the start of the BASH scripts have placeholders (e.g., “logs” file paths, SLURM job email address, etc.); these placeholders must be updated to the correct file/user setup.

- The directory “logs” is in the same directory as the scripts for Trypanosomes and humans; it contains SLURM outputs and error logs, which are useful for identifying any errors that caused a script to fail.

- File paths in all scripts are partially filled out to organise the work; it is specifically the “path/to/your_directory” that users must fill out to match their system.

- Commands like “mkdir -p” in BASH scripts and “dir.create” in R scripts attempt to help automate the workflow by creating output directories if they do not already exist under the output path name.

- Ensure the previously mentioned reference files for both parts of the pipeline are present in the correct file paths for the scripts, as these reference files are required.

- Lastly, it is important to ensure scripts are run in the correct order (1-7 and 1-3) by their designated numerical values, to ensure the correct outputs and results are produced. 



### Required Tools and Packages

This section contains all the tools and packages that were used within the pipeline. It is important that the versions used match this pipeline to support reproducibility. Simply click on the names of tools and package listed to access their source pages.

## BASH Command-line Tools

| Tool | Version |
|------|--------|
| [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) | 0.12.1 |
| [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/) | 0.6.10 |
| [Bowtie2](https://bowtie-bio.sourceforge.net/bowtie2/index.shtml) | 2.5.4 |
| [STAR](https://github.com/alexdobin/STAR) | 2.7.11b |
| [SAMtools](https://github.com/samtools/samtools) | 1.21 |
| [HTSeq](https://htseq.readthedocs.io/en/latest/) | 2.1.2 |

## R Packages

| Package | Version |
|--------|--------|
| [DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html) | 1.50.2 |
| [ggplot2](https://ggplot2.tidyverse.org/) | 4.0.2 |
| [pheatmap](https://cran.r-project.org/web/packages/pheatmap/index.html) | 1.0.13 |
| [dplyr](https://cran.r-project.org/web/packages/dplyr/index.html) | 1.1.4 |
| [RColorBrewer](https://cran.r-project.org/web/packages/RColorBrewer/index.html) | 1.1-3 |

## Command-line Enviornment Setup

In this repository is "rotation2.yml", which is a provided conda environment containing all the command line programmes used in this pipeline. To access this pipline used the following commands:

```{r}
conda env create -f rotation2.yml # Creates the environment
conda activate rotation2 # Activates the conda environment
```

## Troubleshooting

The following points are troubleshooting tips and aim to act as guide if any errors are occur when running the pipeline.

-The “logs” directory can be found within the script directories for both parts of the pipeline, so check these if any errors occur when running scripts.
-If no outputs can be seen from scripts in “logs”, then ensure the slurm “--output” and “--errors” in the scripts have the correct pathways defined.
-Before running scripts, ensure that all placeholder pathways (“path/to/your_directory/”) have been updated to match the user's system.
-Another potential error that may occur is input file names, so verify these match the names of files inputted in the pipeline.
-Additionally, ensure that all output pathways are correct to keep track of successful script outputs.
-SLURM job settings, such as memory or CPU allocation, may need to be varied for certain jobs, as these can cause errors. A guide to many of the different options can be found [here](https://slurm.schedmd.com/sbatch.html).
-Verify the correct reference files stated in this repository are located in the correct directories, and correctly named in scripts to ensure the successful execution of certain scripts in the pipeline.
-Some errors may arise from a mismatch of tools and package versions, so ensure these are fully updated to the specific versions mentioned previously.
-Before continuing to a new step in the pipeline, ensure that the scripts have been executed successfully, and the outputs generated have been obtained.

## References

# Biological background

1.RNA Sequencing | RNA-Seq methods and workflows [Internet]. emea.illumina.com. Available from: https://emea.illumina.com/techniques/sequencing/rna-sequencing.html

2.Kukurba KR, Montgomery SB. RNA Sequencing and Analysis. Cold Spring Harbor Protocols [Internet]. 2015 Apr 13;2015(11):pdb.top084970. Available from: https://pmc.ncbi.nlm.nih.gov/articles/PMC4863231/

3.World Health Organization. Trypanosomiasis, Human African (sleeping sickness) [Internet]. WHO. World Health Organization: WHO; 2023. Available from: https://www.who.int/news-room/fact-sheets/detail/trypanosomiasis-human-african-(sleeping-sickness)

4.Cleveland Clinic. Adenocarcinoma Cancers: Symptoms, Causes, Diagnosis & Treatment [Internet]. Cleveland Clinic. 2024. Available from: https://my.clevelandclinic.org/health/diseases/21652-adenocarcinoma-cancers

5.Hepatocellular carcinoma (HCC) - Symptoms and causes [Internet]. Mayo Clinic. 2025. Available from: https://www.mayoclinic.org/diseases-conditions/hepatocellular-carcinoma/symptoms-causes/syc-20589101

# Reference File Resources

6.TriTrypDB [Internet]. Tritrypdb.org. 2026. Available from: https://tritrypdb.org/tritrypdb/app/downloads

7.Ensembl [Internet]. Ensembl.org. 2020. Available from: https://www.ensembl.org/

# Tools and Packages

8.Andrews S. FastQC a quality control tool for high throughput sequence data [Internet]. Babraham.ac.uk. 2010. Available from: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

9. 1.Krueger F. Babraham Bioinformatics - Trim Galore! [Internet]. www.bioinformatics.babraham.ac.uk. Available from: https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/

10.Bowtie 2: fast and sensitive read alignment [Internet]. bowtie-bio.sourceforge.net. Available from: https://bowtie-bio.sourceforge.net/bowtie2/index.shtml

11.alexdobin. alexdobin/STAR [Internet]. GitHub. 2019. Available from: https://github.com/alexdobin/STAR

12.samtools/samtools [Internet]. GitHub. 2020. Available from: https://github.com/samtools/samtools

13.HTSeq: High-throughput sequence analysis in Python — HTSeq 2.0.4 documentation [Internet]. htseq.readthedocs.io. Available from: https://htseq.readthedocs.io/en/latest/

14. Posit team (2025). RStudio: Integrated Development Environment for R.
Posit Software, PBC, Boston, MA. URL http://www.posit.co/.

15.Bioconductor. DESeq2 [Internet]. Bioconductor. 2017. Available from: https://bioconductor.org/packages/release/bioc/html/DESeq2.html

16.Wickham H. Create Elegant Data Visualisations Using the Grammar of Graphics [Internet]. Tidyverse.org. 2019. Available from: https://ggplot2.tidyverse.org/

17.Kolde R. pheatmap: Pretty Heatmaps [Internet]. R-Packages. 2019. Available from: https://cran.r-project.org/web/packages/pheatmap/index.html

18.Wickham H, François R, Henry L, Müller K, RStudio. dplyr: A Grammar of Data Manipulation [Internet]. R-Packages. 2020. Available from: https://cran.r-project.org/web/packages/dplyr/index.html

19.Neuwirth E. RColorBrewer: ColorBrewer Palettes [Internet]. R-Packages. 2022. Available from: https://cran.r-project.org/web/packages/RColorBrewer/index.html

# SLURM SBATCH Guide

20.Slurm Workload Manager - sbatch [Internet]. slurm.schedmd.com. Available from: https://slurm.schedmd.com/sbatch.html

## Authors

Jiaan Randhawa-Heer - mbxjr7@nottingham.ac.uk

Aabha Shailesh Salunkhe - mbxas28@nottingham.ac.uk

Smriti Chaudary - mbxsc9@nottingham.ac.uk

Mohammad Parsa Faraji - mbxmf5@nottingham.ac.uk
