########################################
#      DESeq 2 Analysis for Blood      #
#          and In vitro Samples        #
########################################

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
counts_directory <- "/path/to/your_directory/trypanosomes/htseq/all_counts" # Sets to HTSeq all count directory as required for use of the count text files
setwd(counts_directory)
list.files() # Lists files to check required sample count files are in working directory


# Sample table creation for DESeq2

sampleTable <- data.frame(
  sampleName = c("Blood1","Blood2","Blood3","Blood4","Blood5",
                 "In_vitro1","In_vitro2","In_vitro3","In_vitro4","In_vitro5"),  # Names samples accordingly into a dataframe
  
  
  fileName = c("Blood1_trimmed.counts.txt",
               "Blood2_trimmed.counts.txt",
               "Blood3_trimmed.counts.txt",
               "Blood4_trimmed.counts.txt",
               "Blood5_trimmed.counts.txt",
               "In_vitro1_trimmed.counts.txt",
               "In_vitro2_trimmed.counts.txt",
               "In_vitro3_trimmed.counts.txt",
               "In_vitro4_trimmed.counts.txt",
               "In_vitro5_trimmed.counts.txt"),        # Inputs the file names for htseq count output
  
  
  condition = factor(c(rep("Blood", 5), rep("In_vitro", 5)))   # Condition sets comparison for Blood samples vs In vitro samples
)


sampleTable # Outputs table to check code worked correctly

# Produces DESeq dataset from the htseq count files provided

dds <- DESeqDataSetFromHTSeqCount(
  sampleTable = sampleTable,
  directory = counts_directory, # Ensures files needed are being inputed
  design = ~ condition # Condition creates column to compare Blood vs In vitro
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

write.csv(as.data.frame(results), file = "blood_and_in_vitro_deseq2_results.csv") # Saves DESeq2 results to a file

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

png("Heatmap_blood_vs_invitro.png", width = 1200, height = 900) # Saves the heatmap

pheatmap(sampleDistMatrix,
         clustering_distance_rows = sampleDists,
         clustering_distance_cols = sampleDists,
         col = colors,
         main = "Blood vs In vitro Sample to Sample Distances Heatmap")

dev.off()

# Load HTSeq counts from the count files directory
dds <- DESeqDataSetFromHTSeqCount(
  sampleTable = sampleTable,
  directory   = counts_directory,
  design      = ~ condition
)
# Filter low-count genes
dds <- dds[rowSums(counts(dds)) > 10, ]
# Variance-stabilizing transformation for PCA
vsd <- vst(dds, blind = TRUE)
# PCA plot
plotPCA(vsd, intgroup = "condition")
# Save plot
ggsave("PCA_blood_vs_invitro.png", width = 7, height = 5, dpi = 300) # Saves plot to set working directory

dds_IV5RM <- dds[, colnames(dds) != "In_vitro5"] # Creates a subset of data with the outlier seen in the heatmap removed (OPTIONAL)
colnames(dds_IV5RM) # Outputs column names to confirm the removal of the outlier (In vitro 5 removed)

dds_IV5RM <- DESeq(dds_IV5RM) # Reruns DESeq on the filtered data
results_IV5RM <- results(dds_IV5RM) # DESeq results containing no In vitro 5

results_df <- as.data.frame(results_IV5RM) # Converts DESeq2 results into a dataframe

clean_results <- results_df |> # Tidyverse approach to remove padj NA values and create cleaned data
  dplyr::filter(!is.na(padj))

significant_genes <- clean_results |> # tidyverse approach applies standard threshold to pajd
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
  labs(title = "Volcano plot: Blood vs In vitro (DESeq2)", x = "Log2 Fold Change", y = "-Log10 (adjusted P-value)") # Titles the plot and axis
ggsave("Volcanoplot_blood_vs_invitro.png", width = 7, height = 5, dpi = 300) # Saves plot to set working directory

results_df <- as.data.frame(results_IV5RM) # Converts DESeq2 results into a dataframe (no In_vitro5)

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
  labs(title = "MA plot: Blood vs In vitro (DESeq2 data)", x = "Log10 (mean expression)", y = "Log2 Fold Change") # Titles the MA plot and labels the axis
ggsave("MAplot_blood_vs_invitro.png", width = 7, height = 5, dpi = 300) # Saves plot to set working directory