library(rio)
library(tidyverse)
#uni path
#file_path='C:/Users/ccuffe22/OneDrive - Royal Veterinary College/Admin or Training/Data + Material Info/ATAC Galaxy files/Annotation/WB_narrow_peaks.xlsx'
#laptop path
file_path="C:/Users/charl/OneDrive - Royal Veterinary College/Admin or Training/Data + Material Info/ATAC Galaxy files/Annotation/WB_narrow_peaks.xlsx"
wb_peaks<-import(file= file_path, fileext='.xlsx', which=2) #which says the sheet to open
all_wb_peaks<-import(file= file_path, fileext='.xlsx', which=1)
#uni computer file path
#file_path2='C:/Users/ccuffe22/OneDrive - Royal Veterinary College/Admin or Training/Data + Material Info/ATAC Galaxy files/Annotation/TB_narrow_peaks.xlsx'
#laptop path
file_path2="C:/Users/charl/OneDrive - Royal Veterinary College/Admin or Training/Data + Material Info/ATAC Galaxy files/Annotation/TB_narrow_peaks.xlsx"
tb_peaks<-import(file= file_path2, fileext='.xlsx', which=2)
all_tb_peaks<-import(file= file_path2, fileext='.xlsx', which=1)


####playing around with the data and stats #########
tb_peaks %>%
  select(start,end) %>%
  mutate(peak_length=end-start) %>%
  cummean()

all_tb_peaks_filtered %>%
  group_by(chrom) %>%
  summarise(num_rows=n()) %>%
  {.->>per_chr_peaks}

all_wb_peaks_filtered %>%
  group_by(chrom) %>%
  summarise(num_rows=n()) %>%
  {.->>per_chr_peaks_wb}

peaks_per_chrom_all<- full_join(per_chr_peaks, per_chr_peaks_wb, by='chrom')
colnames(peaks_per_chrom_all)<-c('chrom','tb','wb')

ggplot(data=peaks_per_chrom_all) +
  aes( y=tb,wb) +
  geom_bar(position='dodge')


  
  

##########PCA plots to look at variation and clustering################
##package admin etc
install.packages('ggfortify')
library(ggfortify)

###filtering for the PCA 1.all peaks and info, 2. just the peak regions and no animal info 
#### 3.Separating per breed and muscle type

all_wb_peaks %>% 
  filter(chrom==c(1:31)) %>%
  # select(c(1:3,5:13)) %>% #tried 6:13 to include each point
  relocate(list, .after=last_col()) %>%
  relocate(num, .before=list) %>%
  #filter(num>=4) %>%
  select(c(1:3,4,6,8,10,12,13)) %>%
  filter(num==4)%>%
  view()
  {.->> all_wb_peaks_filtered}

###filtering for the PCA below but for tbs
all_tb_peaks %>% 
  filter(chrom==c(1:31)) %>%
  # select(c(1:3,5:13)) %>% #tried 6:13 to include each point
  relocate(list, .after=last_col()) %>%
  relocate(num, .before=list) %>%
  {.->> all_tb_peaks_filtered}

#PCA to explore how just the peaks cluster with no further info, with colouring showing number of samples with that peak
df1 <- all_wb_peaks_filtered[1:3]
df2 <- all_tb_peaks_filtered[1:3]
pca_res_wb <- prcomp(df1, scale. = TRUE)
pca_res_tb <- prcomp(df2, scale. = TRUE)

autoplot(pca_res_wb, data=all_wb_peaks_filtered, colour = 'num')
autoplot(pca_res_tb, data=all_tb_peaks_filtered, colour = 'num')


