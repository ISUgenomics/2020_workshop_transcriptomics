#! /usr/bin/env Rscript
# Auth: Jennifer Chang
# Date: 2021/02/23
# Desc: Combine featureCounts output (1st and last column) files

# === Load Libraries
library(tidyverse)
library(magrittr)
library(readxl)

# === Get list of featureCount output files
dir_org="bee"         # counts are in a "bee" or "maize" subdirectory
featureCount_files <- list.files(path = dir_org, pattern = "*genecounts.txt$", full.names = TRUE)

# === Read in 1st file
data <- read_delim(featureCount_files[1], delim="\t", comment = "#" ) %>%
  select(Geneid, ends_with(".bam")) %>%              # Get 1st and last column (column was named after bam file)
  pivot_longer(cols=ends_with(".bam")) %>%           # Melt data (tidy data)
  mutate(
    name = gsub(".aligned.out.bam", "", name)        # No longer need the bam extension, easier to read
  )

# === Loop and append the rest
for (count_file in featureCount_files[-1]){
  print(count_file)
  temp <- read_delim(count_file, delim="\t", comment = "#") %>%
    select(Geneid, ends_with(".bam")) %>%
    pivot_longer(cols=ends_with(".bam")) %>%
    mutate(
      name = gsub(".aligned.out.bam", "", name)
    )
  data = rbind(data, temp)
}

# === Convert to excell like data (wider)
wide_data <- data %>%
  pivot_wider(id_cols=Geneid)

# === Save tab delimited file (smaller file size)
write_delim(wide_data, 
            paste(dir_org, "genecounts.txt", sep="_"), 
            delim="\t")

# === Save Excel file (can be easier to work with)
writexl::write_xlsx(wide_data, 
                    path=paste(dir_org, "genecounts.xlsx", sep="_"))
