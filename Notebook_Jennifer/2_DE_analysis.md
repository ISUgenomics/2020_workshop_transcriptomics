R Analysis
================
Jennifer Chang
1/8/2021

## R Markdown

This is a placeholder to store any analysis in R (edgeR, DESeq2). Also a
way to look at the underlying assumptions (RNASeq distribution functions
and how it behaves in an analysis pipeline. Is the distribution
realistic?)

## Install any required libraries

``` r
# == Install any CRAN packages
# cran_pkgs <- c("QuasiSeq")
# install.packages(cran_pkgs)

# == Install any Bioconductor packages
# bioc_pkgs <- c("edgeR", "baySeq", "DESeq2", "NOISeq", "limma")
# BiocManager::install(bioc_pkgs)

# ====================   Year of development
library(tidyverse)
library(magrittr)
library(edgeR)         # 2010
library(baySeq)        # 2010
library(QuasiSeq)      # 2012
library(DESeq2)        # 2014    # <= actually a bit strange that DESeq2 & edgeR tend to be equivalent, despite being 4yrs later
library(NOISeq)        # 2015
library(limma)         # 2015
```

## Distribution

RNASeq is assumed to be [negatively binomially
distributed](https://en.wikipedia.org/wiki/Negative_binomial_distribution)
according to the edgeR and DESeq2 papers.

*Y*<sub>*g**i*</sub> ∼ *N**B*(*M*<sub>*i*</sub>*p**g**j*, *ϕ*<sub>*g*</sub>)

What does a negative binomial distribution look like?

``` r
y  <- rnbinom( n = 1000,       # Randomly generate 1000 entries (number of replicates?)
               size = 5,       # at least 5 successes (expressed/not?)
               prob = 0.5      # probability of success in each case...maybe length of genome may affect this
               )

df <- data.frame(x = c(1:1000),
                 y = y)
                  
ggplot(data = df, aes(x=y)) + 
  geom_histogram(binwidth = 1) +
  theme_bw() +
  labs(title="Negative Binomial Distribution (n=1000, size=5, prob=0.5)") +
  geom_vline(xintercept=5, color="blue")
```

![](imgs/R_negbinomial-1.png)<!-- -->

Notice how the peak of the distribution is around 5 (`size=5`). Play
around with the `rnbinom` parameters, how does that change the shape of
the distribution? What implications does this have for RNASeq to
determine if a gene is differentially expressed across two treatments?
