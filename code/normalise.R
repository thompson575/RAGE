# -----------------------------------------------------------
# RAGE: Regression After Gene Expression
#
# Normalise the data by mean and std  
#
# Date: 20 March 2023
#
library(tidyverse)
library(fs)

# -------------------------------------------------
# data folders
#
cache    <- "C:/Projects/RCourse/Masterclass/RAGE/data/cache"

# -------------------------------------------------
# dependencies - input files used by this script
#
valRDS <- path(cache,   "validation.rds")
trnRDS <- path(cache,   "training.rds")
# -------------------------------------------------
# targets - output files created by this script
#
nvlRDS <- path(cache,   "norm_validation.rds")
ntrRDS <- path(cache,   "norm_training.rds")

# --------------------------------------------------
# Divert warning messages to a log file
#
lf <- file(path(cache,   "normalise_log.txt"), open = "wt")
sink(lf, type = "message")

# -----------------------------------------------
# Training Data
#
readRDS(trnRDS) %>%
  pivot_longer(-id, names_to = "gene", values_to = "expression") %>%
  group_by(id) %>%
  mutate( expression = (expression - mean(expression)) / sd(expression)) %>%
  pivot_wider(names_from = gene, values_from = expression) %>%
  saveRDS(ntrRDS)

# -----------------------------------------------
# Validation Data
#
readRDS(valRDS) %>%
  pivot_longer(-id, names_to = "gene", values_to = "expression") %>%
  group_by(id) %>%
  mutate( expression = (expression - mean(expression)) / sd(expression)) %>%
  pivot_wider(names_from = gene, values_from = expression) %>%
  saveRDS(nvlRDS)

# -----------------------------------------------
# Close the log file
#
sink(type = "message" ) 
close(lf)
