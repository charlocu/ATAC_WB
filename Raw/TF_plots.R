#some plotting fun from tobias results
#first thing is plotting a heatmap of correlations or overlap between TFBS
setwd("O:/Research_Storage/Psifidi_Androniki/RER_project/ATAC-data/Analysis/Intermediate output/TOBIAS_results/results/binDetect")

# Load required libraries, install missing ones
required_packages <- c("BiocManager", "tidyverse", "RColorBrewer", "pheatmap", 
                       "readxl", "ggplot2",  "rio",  "stringr", 
                       "MetBrewer", "patchwork", "rhdf5", "paletteer", "magrittr")
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
install_if_missing <- function(pkg) if (!require(pkg, character.only = TRUE)) BiocManager::install(pkg)
lapply(required_packages, install_if_missing)
lapply(required_packages[-1], library, character.only = TRUE)

#plotting guidelines
theme_set(
  theme_grey(base_size = 14) +  # Base theme
    theme(
      panel.grid.major = element_line(color = "grey90"),  # Major grid lines
      panel.grid.minor = element_line(color = "grey90"),  # Minor grid lines
      panel.background = element_rect(fill = "white"),   # White background
      plot.background = element_rect(fill = "white")     # White surrounding area
    )
)


#filter the motifs for the vertebrate list only
#JASPAR core vertebrate 2022
df <- read_excel("O:/Research_Storage/Psifidi_Androniki/RER_project/Reference/JASPAR2022_CORE_vertebrates_non-redundant_pfms_jaspar.xls", sheet = 2, col_names = "motif_id")
vert_motifs <- as.data.frame(apply(df,2,function(x) gsub(">","",x)))
results <- read_excel("./SM_cases_vs_SM_controls/bindetect_results.xlsx")

vert_controls <- left_join(vert_motifs,results)
vert_controls$signal_SM_cases_filtered_signal_SM_controls_filtered_pvalue <-as.numeric(vert_controls$signal_SM_cases_filtered_signal_SM_controls_filtered_pvalue)
vert_controls %>% 
  mutate(p_val_rank=percent_rank(signal_SM_cases_filtered_signal_SM_controls_filtered_pvalue)) %>%
  mutate(DBR_rank=percent_rank(signal_SM_cases_filtered_signal_SM_controls_filtered_change)) %>%
  mutate(sig=case_when(
    #p_val_rank>=0.8|DBR_rank>=0.9|DBR_rank<=0.1 ~ "True",
    p_val_rank<=0.2 ~ "True",
    DBR_rank>=0.90 ~ "True",
    DBR_rank<=0.1 ~ "True",
    TRUE ~ "False")) %>%
  {. ->> vert_controls}
sig_motifs <- vert_controls[(vert_controls$sig=="True"),]
export(sig_motifs, "sm_vs_sm_cases_sig_motifs.txt", format = "txt") 

#volcano plot of just the vertebrate genes
vert_controls$log_pvalue <-abs(log10(vert_controls$signal_SM_cases_filtered_signal_SM_controls_filtered_pvalue))
volcano <- ggplot(vert_controls, aes(x = signal_SM_cases_filtered_signal_SM_controls_filtered_change, y = log_pvalue, color = sig)) +
  geom_point() +
  scale_colour_met_d("Demuth", -1) +
  labs(title = "Volcano Plot of Transcription factors", subtitle="from RER cases and controls, SM only", x = "Differential binding score ", y = "-log10(pvalue)") 
volcano
 ggsave(filename = "volcanoplot_cases_TFs.tiff", plot= volcano, width = 20, height = 20, units = "cm", dpi= 320)
