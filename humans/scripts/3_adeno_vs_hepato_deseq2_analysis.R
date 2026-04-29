############################################
#     DESeq 2 Analysis for Adenocarcinoma  #
#                    and                   #
#   Hepatocellular Carcinoma Samples       #
############################################

# The following script produces a DESeq2 analysis with results, and visualised results such as a heatmap, pca plot, volcano plot and MA plot.
# All results will save to the user's set working directory

# install.packages("BiocManager") # Installs package BiocManager if required
# BiocManager::install("DESeq2") # Installs package DESeq2 if required
# install.packages("pheatmap") # Installs package pheatmap if required
# install.packages("RColorBrewer") # Installs package RColourBrewer if required
# install.packages("tidyverse") # installs package tidyverse if required
# install.packages("ggplot2") # installs ggplot 2 if required
# install.packages("dplyr") # installs dplyr if required

library(DESeq2) # Loads DESeq2 package
library(pheatmap) # Loads heatmap package
library(RColorBrewer) # Loads RColorBrewer
library(dplyr) # Loads required dplyr package
library(ggplot2) # Loads required ggplot2 package

getwd() # Finds current working directory
counts_directory <- "/path/to/your_directory/human/mapping/all_counts" # Sets to the mapping directory as required for use of the count text files
setwd(counts_directory) 
list.files() # Lists files to check required sample count files are in working directory


# Sample table creation for DESeq2

sampleTable <- data.frame(
  sampleName = c("adeno_ERR1404760","adeno_ERR1404761","adeno_ERR1404762","adeno_ERR1404763","adeno_ERR1404764",
                 "adeno_ERR1404765","adeno_ERR1404766","adeno_ERR1404767","adeno_ERR1404768","adeno_ERR1404769",
                 "adeno_ERR1404770","adeno_ERR1404771","adeno_ERR1404772","adeno_ERR1404773","adeno_ERR1404774",
                 "hepato_ERR1404781","hepato_ERR1404782","hepato_ERR1404783","hepato_ERR1404784"),  # Names samples accordingly into a dataframe
  
  
  fileName = c("adeno_ERR1404760_ReadsPerGene.out.tab",
               "adeno_ERR1404761_ReadsPerGene.out.tab",
               "adeno_ERR1404762_ReadsPerGene.out.tab",
               "adeno_ERR1404763_ReadsPerGene.out.tab",
               "adeno_ERR1404764_ReadsPerGene.out.tab",
               "adeno_ERR1404765_ReadsPerGene.out.tab",
               "adeno_ERR1404766_ReadsPerGene.out.tab",
               "adeno_ERR1404767_ReadsPerGene.out.tab",
               "adeno_ERR1404768_ReadsPerGene.out.tab",
               "adeno_ERR1404769_ReadsPerGene.out.tab",
               "adeno_ERR1404770_ReadsPerGene.out.tab",
               "adeno_ERR1404771_ReadsPerGene.out.tab",
               "adeno_ERR1404772_ReadsPerGene.out.tab",
               "adeno_ERR1404773_ReadsPerGene.out.tab",
               "adeno_ERR1404774_ReadsPerGene.out.tab",
               "hepato_ERR1404781_ReadsPerGene.out.tab",
               "hepato_ERR1404782_ReadsPerGene.out.tab",
               "hepato_ERR1404783_ReadsPerGene.out.tab",
               "hepato_ERR1404784_ReadsPerGene.out.tab"),        # Inputs the file names for STAR count output
  
  
  condition = factor(c(rep("Adeno", 15), rep("Hepato", 4)))   # Condition sets comparison for Adeno samples vs Hepato samples
)


sampleTable # Outputs table to check code worked correctly

# Produces count matrix from the STAR count files provided

files <- sampleTable$fileName # Uses file names from the sample table to keep sample order consistent
files # Outputs file names to check code worked correctly

count_list <- lapply(files, function(f) {
  df <- read.table(file.path(counts_directory, f), header = FALSE) # Reads in STAR count files
  df <- df[1:(nrow(df) - 4), c(1, 2)] # Uses gene IDs and unstranded counts, removing summary rows at the bottom
  colnames(df) <- c("gene", gsub("_ReadsPerGene.out.tab", "", basename(f))) # Sets clear sample names
  df
})

counts <- Reduce(function(x, y) merge(x, y, by = "gene"), count_list) # Merges all count files into one dataframe

count_matrix <- as.matrix(counts[,-1]) # Creates count matrix from merged dataframe
rownames(count_matrix) <- counts$gene # Sets gene names as row names

rownames(sampleTable) <- sampleTable$sampleName # Matches sample table row names to count matrix column names

# Produces DESeq dataset from the count matrix provided

dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = sampleTable,
  design = ~ condition # Condition creates column to compare Adeno vs Hepato
)

dds # Outputs dataset to ensure it has loaded correctly
dds <- DESeq(dds) # Runs DESeq on the data

results <- results(dds)
summary(results) # Outputs results from DESeq2 on the data

mainDir <- getwd()
subDir <- "../../results"

if (dir.exists(file.path(mainDir, subDir))) {  # Checks if a results directory exists and creates it if it does not
  setwd(file.path(mainDir, subDir))
} else {
  dir.create(file.path(mainDir, subDir))
  setwd(file.path(mainDir, subDir))    #Updates the working directory so results from this script are saved in "results"
}

write.csv(as.data.frame(results), file = "adeno_vs_hepato_deseq2_results.csv") # Saves DESeq2 results to a file

# Transformation function that returns normalised values
# Blind set to false makes run times shorter
vsd <- vst(dds, blind=FALSE)
rld <- rlog(dds, blind=FALSE)
head(assay(vsd), 3) # Outputs top results to check
sampleDists <- dist(t(assay(vsd))) # Calculates Euclidean distance between samples, transforming data into a distance calculated data set

sampleDistMatrix <- as.matrix(sampleDists) # Calculates sample to sample distances with transformed data
rownames(sampleDistMatrix) <- colnames(vsd) # Matches heatmap row names to the distance data set
colnames(sampleDistMatrix) <- colnames(vsd) # Matches heatmap column nmaes to the distance data set
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255) # Colours and sizes the heatmap

png("Heatmap_adeno_vs_hepato.png", width = 1200, height = 900) # Saves the heatmap

pheatmap(sampleDistMatrix,
         clustering_distance_rows = sampleDists,
         clustering_distance_cols = sampleDists,
         col = colors,
         main = "Adeno vs Hepato Sample to Sample Distances Heatmap")

dev.off()

# Load STAR counts
files <- sampleTable$fileName
count_list <- lapply(files, function(f) {
  df <- read.table(file.path(counts_directory, f), header = FALSE)
  df <- df[1:(nrow(df) - 4), c(1, 2)]
  colnames(df) <- c("gene", gsub("_ReadsPerGene.out.tab", "", basename(f)))
  df
})
counts <- Reduce(function(x, y) merge(x, y, by = "gene"), count_list)
count_matrix <- as.matrix(counts[,-1])
rownames(count_matrix) <- counts$gene
rownames(sampleTable) <- sampleTable$sampleName

dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData   = sampleTable,
  design    = ~ condition
)
# Filter low-count genes
dds <- dds[rowSums(counts(dds)) > 10, ]
# Variance-stabilizing transformation for PCA
vsd <- vst(dds, blind = TRUE)
# PCA plot
plotPCA(vsd, intgroup = "condition")
# Save plot
ggsave("PCA_adeno_vs_hepato.png", width = 7, height = 5, dpi = 300) # Saves plot to set working directory

results_df <- as.data.frame(results) # Converts DESeq2 results into a dataframe

clean_results <- results_df |> # Tidyverse approach to remove padj NA values and create cleaned data
  dplyr::filter(!is.na(padj))

significant_genes <- clean_results |> # Tidyverse approach applies standard threshold to padj
  dplyr::filter(padj < 0.05)

up_genes <- significant_genes |>
  dplyr::filter(log2FoldChange > 0) |> nrow() # Counts upregulated genes

down_genes <- significant_genes |>
  dplyr::filter(log2FoldChange < 0) |> nrow() # Counts downregulated genes
up_genes # Outputs number of upregulated genes
down_genes # Outputs number of downregulated genes


volcanoplot_results <- clean_results |> # Creates dataframe for volcano plot
  mutate(neg_log10_padj = -log10(padj), # Calculates -log10 for the y axis, which is adjusted p values
         gene_regulation = ifelse(
           padj < 0.05 & log2FoldChange > 0, "UPREGULATED", # Thresholds to determine upregulated genes
           ifelse(
             padj < 0.05 & log2FoldChange < 0, "DOWNREGULATED", # Thresholds to determine downregulated genes
             "NOT SIGNIFICANT")) # Plots as not significant for genes outside thresholds
  )

ggplot(volcanoplot_results, aes(x = log2FoldChange, y = neg_log10_padj, # Sets data for axis
                                colour = gene_regulation)) + # Determines colour by regulation classification
  geom_point(alpha = 0.5, size = 2) + # Sets mid transparency and size for plots
  scale_color_manual(values = c("UPREGULATED" = "blue", "DOWNREGULATED" = "red", "NOT SIGNIFICANT" = "grey")) + # Colours classified gene regulations
  labs(title = "Volcano plot: Adeno vs Hepato (DESeq2)", x = "Log2 Fold Change", y = "-Log10 (adjusted P-value)") # Titles the plot and axis
ggsave("Volcanoplot_adeno_vs_hepato.png", width = 7, height = 5, dpi = 300) # Saves plot to set working directory

results_df <- as.data.frame(results) # Converts DESeq2 results into a dataframe

clean_results <- results_df |> # Tidyverse approach to remove padj NA values and create cleaned data
  dplyr::filter(!is.na(padj))

MAplot_results_1 <- clean_results |> # Creates a new dataframe to be used in the MA plot
  mutate (log10_baseMean = log10(baseMean), # Applies mean to log10 values
          significance_class = ifelse(padj < 0.05, "SIGNIFICANT", "NOT SIGNIFICANT") # classifies genes by the threshold
  )

ggplot(MAplot_results_1, aes(x = log10_baseMean, y = log2FoldChange, # Sets data for the axis
                             colour = significance_class)) + # Determines colour by classification of genes
  geom_point(alpha = 0.5, size = 1.5) + # Applies some transparency and sets size for plots
  scale_color_manual(values = c("SIGNIFICANT" = "red", "NOT SIGNIFICANT" = "green"))+ # Sets colour differences for classified genes
  geom_hline(yintercept = 0, colour = "black")+ # Function that produces a horiztonal line to show no fold change
  labs(title = "MA plot: Adeno vs Hepato (DESeq2 data)", x = "Log10 (mean expression)", y = "Log2 Fold Change") # Titles the MA plot and labels the axis
ggsave("MAplot_adeno_vs_hepato.png", width = 7, height = 5, dpi = 300) # Saves plot to set working directory