######Differential Accessibility using DiffBind########
##All code and further details from:
#https://bioconductor.org/packages/release/bioc/vignettes/DiffBind/inst/doc/DiffBind.pdf

#package installation
required_packages <- c("BiocManager", "DiffBind", "tidyverse", "ggplot2", "rio", "BiocParallel")

if (!require("BiocManager", quietly = TRUE)) {
install.packages("BiocManager")
}
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {BiocManager::install(pkg)
  }
}
invisible(lapply(required_packages, install_if_missing))
invisible(lapply(required_packages[-1], library, character.only = TRUE))

register(SerialParam())
#########DiffBind###########
#setting up data#
setwd("O:/Research_Storage/Psifidi_Androniki/RER_project/ATAC-data/Analysis/Intermediate output")
#setwd("R:/RER_project/ATAC-data/Analysis/Intermediate output")
file_path <- "R:/RER_project/ATAC-data/Analysis/Intermediate output/"
file_path <- "O:/Research_Storage/Psifidi_Androniki/RER_project/ATAC-data/Analysis/Intermediate output/"
tmpdir <- tempdir()
setwd(file_path)
getwd()

######Beginning the differential binding analysis#####
##step 1 to experiments is creating a sample sheet, either in a dataframe or directly from the csv file#####
#datasheet from a csv:
#samples <- read.csv( "high_pass_control_sheet.csv")
samples <- read.csv( "diffbind_sheet_test.csv")
samples_SM <-samples[samples$Tissue=="SM",]
samples_biglibs <-samples[samples$SampleID %in% c("TB4B","TB4A", "TB3A","TB3B","TB2B", "TB1B", "WB4A", "WB6B"),]
samples_controls<- samples[samples$Condition=="Control",]
samples_wbs<- samples[samples$Breed=="WB",]

#use sample sheet to directly create DBA:
muscles <- dba(sampleSheet = samples_biglibs, peakFormat ='narrow', scoreCol=8, bRemoveM=T, bRemoveRandom =T)
#scoreCol is specifying where to look for score, bremoveM/Random removes mito file and Random
#scoreCol does change, eg narrowPeak files scorecol=8
#this can then be plotted with:
tiff(filename="corrplot_atac_biglib_controls_1.tiff", width = 20, height = 20, units="cm", res = 320)
plot(muscles)
dev.off()

#beginning to save plots as pdfs not tiffs
pdf(file = "corrplot_atac_WB_controls_1.pdf" , width = 20, height = 20, units="cm", res = 320)
plot(muscles)
dev.off()

##Step 2 count reads##########
muscles <- dba.count(muscles, summits=250)
muscles #visually inspect
#can also examine the amount of reads overlapping a consensus peak
info <- dba.show(muscles)
libsizes <- cbind(LibReads=info$Reads, FRiP=info$FRiP,PeakReads=round(info$Reads * info$FRiP))
rownames(libsizes) <- info$ID
libsizes
#plotting at this point is a new correlation heatmap, slightly diff clustering 
#and higher cor values bc used normalised read values vs if peak called or not
plot(muscles)
#attempting some heatmap customisation
heatmap_cols <- colorRampPalette(c("red", "white", "blue"), space = "Lab") 
dba.plotHeatmap(muscles, correlations = T, colScheme = heatmap_cols(10))

##Step 3- Normalise the Data#######
muscles <- dba.normalize(muscles)
muscles2 <-dba.normalize(muscles, normalization = DBA_NORM_RLE)
#default normalisation is based on seq depth
norm <- dba.normalize(muscles, bRetrieve=TRUE)
norm
norm2 <-dba.normalize(muscles2, normalization = DBA_NORM_RLE, bRetrieve=TRUE)
norm2
#lib.sizes is the total number of reads in the associated .bam files
#default library-size normalisation method means all lib.sizes normalised to the norm or mean lib size
#can inspect this with:
normlibs <- cbind(FullLibSize=norm$lib.sizes, NormFacs=norm$norm.factors,
                   NormLibSize=round(norm$lib.sizes/norm$norm.factors))
rownames(normlibs) <- info$ID
normlibs

##Step 4 establish a model design and contrast####
#use dba.contrast to tell diffbind the model needed for your data incl comparisons of interest
muscles2 <- dba.contrast(muscles2,
                           reorderMeta=list(Tissue='SM'))
muscles2
#need a minimum of 3 replicates per factor in the metadata for the programme to 
#assume yhat is the contrast we want to look and in above it puts responsive condition as baseline

## Step 5 performing the diff analysis########
#main differential analysis done as so:
muscles2 <- dba.analyze(muscles2)
dba.show(muscles2, bContrasts=TRUE)
#above runs the default DESeq2 analysis and then results can be displayed using:
#plots differentially bound sites only
plot(muscles2, contrast=1)

##Step 6-Retrieving differentially bound sites######
muscles.DB <- dba.report(muscles)
#to view the report:
muscles.DB
#comparing the number of diff bound sites with enriched binding in muscles from SCDM samples vs SM samples:
sum(muscles.DB$Fold>1)
sum(muscles.DB$Fold<1)

######  plotting##########
#First is Venn Diagrams####
#example: contrast between the 'Gain' and 'Loss' sites (those with higher or lower enrichment)
dba.plotVenn(muscles, contrast=1, bDB=TRUE,
              bGain=TRUE, bLoss=TRUE, bAll=FALSE)
#venn diagrams most useful to compare overlaps bw peaksets 
#specially to look at consensus peakset for read counting and further analysis
#dba.plotVenn has more examples on help page

#Next is PCA plots####
#cor heatmaps good for showing clustering but PCA plots give better insight
#example of PCA based on normalised read counts for all binding sites
dba.plotPCA(muscles,DBA_TISSUE,label=DBA_CONDITION)
#experiment with the other PCA components
dba.plotPCA(muscles,
            DBA_CONDITION, label=DBA_TISSUE, components=2:3)
#or a plot looking only at the differentially bound sites with FDR of 0.05
dba.plotPCA(muscles, contrast=1, label=DBA_TISSUE)
#or looking at replicates for each unique breed x muscle combo:
dba.plotPCA(muscles, attributes=c(DBA_TISSUE,DBA_CONDITION), label=DBA_ID)
#nstall.packages('rgl') using rgl gives 3D pca plots of 3 components vs 2
dba.plotPCA(muscles,contrast=1,
            b3D=TRUE)
###MA plots####
#MA plots look at relationship bw overall binding level/site and magnitude
#of change in binding enrichments between conditions
dba.plotMA(muscles)
#each point = binding site, magenta ones= differentially bound, blue line is through origin 
#red curve is non-linear loess fit showing underlying relationship bw coverage lvls and fold changes
#same plot as above but with conc of samples groups plotted against each other
dba.plotMA(muscles, bXY=TRUE)

##Volcano plots#####
#similar idea to MA plots but also highlight significantly differentially bound 
#sites & show fold changes
#confidence statistic is shown on a negative log scale to help visualise magnitude 
#of fold change & confidence
dba.plotVolcano(muscles)

###Boxplots####
#look at how read distributions differ bw classes of binding sites
pvals <- dba.plotBox(muscles)
#to look at the values within the plotbox
pvals

##Heamaps#####
#first is a correlation heatmap like seen already#
corvals <- dba.plotHeatmap(muscles)
#adjustments can include changing the normalisation (score) eg:
dba.plotHeatmap(muscles,
                score=DBA_SCORE_RPKM_FOLD)

#Binding affinity heatmap - looks at patterns of binding affinity directly in the binding sites
hmap <- colorRampPalette(c("red", "black", "green"))(n = 13)
readscores <- dba.plotHeatmap(muscles, contrast=1, correlations=FALSE,
                               scale="row", colScheme = hmap)
#above the samples cluster first based on WB vs TB, then by tissue (SM vs SCDM), then by replicate (1 so kinda mootpoint here)

####Profiling and Profile Heatmaps#####
#computing peakset profiles and plotting complex heatmaps is done in two steps bc computationally expensive
#first step is computing peakset profiles and outputting to a profileplyr object
#second is plotting this object
#different parameters can control how data treated, how many sites to include,
#data normalisation, sample merging an appearance more detail found online
#Default profile plot is merged based on DBA_replicate attribute
#so that each sample class has it's own heatmap based on normalised read counts for the 1000 top sites
#BiocManager::install("profileplyr")
#library(DiffBind)

profiles <- dba.plotProfile(muscles)
dba.plotProfile(profiles)
#adjustments you can make:include merging different groups
profiles <- dba.plotProfile(muscles,merge=c(DBA_TISSUE, DBA_REPLICATE))
dba.plotProfile(profiles)
#another layer of adjustment comes with defining masks
mask.TB <- muscles$masks$TB
mask.SM <- muscles$masks$SM
mask.SCDM <-muscles$masks$SCDM
profiles <- dba.plotProfile(muscles,
                             samples=list(TB_SM=
                                              mask.TB & mask.SM,
                                           TB_SCDM=
                                              mask.TB & mask.SCDM),
                             merge=NULL)
dba.plotProfile(profiles)

#to be repeated with WBs
mask.WB <- muscles$masks$WB
profiles_WB <- dba.plotProfile(muscles,
                            samples=list(WB_SM=
                                           mask.WB & mask.SM,
                                         WB_SCDM=
                                           mask.WB & mask.SCDM),
                            merge=NULL)
dba.plotProfile(profiles_WB)

######Multi factor design#######
#This is done by specifying a model/design formula to dba.contrast
#specifying a design will clear the previous results => analysis must be done new
muscles2 <-dba.contrast(muscles2, design = '~Tissue + Condition + Treatment')
muscles2 <- dba.analyze(muscles2)
dba.show(muscles2, bContrasts=TRUE)

#original analysis found ~246 differentially bound sites, 2-factor design found 782
#can see diff if plot
dba.plotMA(muscles)
dba.plotVolcano(muscles)
#changes quantified with a report as follows:
multifactor.DB <- dba.report(muscles)
multifactor.DB
#to compare proportions of diff binding sites identified in single and multi-factor analysis
#specifically diffs between binding in Resistant condition vs responsive
sum(muscles.DB$Fold > 0) / sum(muscles.DB$Fold < 0)
sum(multifactor.DB$Fold > 0) / sum(multifactor.DB$Fold < 0)

###Some experimentation with normalisation####
#first non-normalised
dba.plotMA(muscles, contrast=list(SM=muscles$masks$SM),
              bNormalized=FALSE, sub="Non-Normalized")

#normalisation with only library size taken into account
muscles <- dba.normalize(muscles, normalize=DBA_NORM_LIB)
muscles <- dba.analyze(muscles)
dba.plotMA(muscles, method=DBA_DESEQ2, sub="DESeq2:lib:full")


########Alternate analysis ################
consensus <-dba.peakset(muscles,
                        consensus = DBA_TISSUE,
                        minOverlap = 2)
consensus
