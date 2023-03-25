# -----------------------------------------------------------
# RAGE: Regression After Gene Expression
#
# Normalise the training data by scaling  
# Normalise the validation data using mean and std 
# of the training data
#
# Date: 20 March 2023
#
library(tidyverse)
library(fs)

# -------------------------------------------------
# data folders
#
cache    <- "C:/Projects/RCourse/Masterclass/RAGE/data/cache"
rawData  <- "C:/Projects/RCourse/Masterclass/RAGE/data/rawData"

# -------------------------------------------------
# dependencies - input files used by this script
#
valFILE <- path(cache,   "validation.rds")
trnFILE <- path(cache,   "training.rds")
# -------------------------------------------------
# targets - output files created by this script
#
nvlFILE <- path(cache,   "norm_validation.rds")
ntrFILE <- path(cache,   "norm_training.rds")
logFILE <- path(cache,   "normalise_log.txt")

# --------------------------------------------------
# Divert warning messages to a log file
#
lf <- file(logFILE, open = "wt")
sink(lf, type = "message")

# -----------------------------------------------
# Training Data
#
readRDS(trnFILE) %>%
  pivot_longer(-id, names_to = "gene", values_to = "expression") %>%
  pivot_wider(names_from = id, values_from = expression) -> byPatDF

geneName <- byPatDF$gene

byPatDF %>%
  select(-gene) %>%
  scale() %>%
  as_tibble() %>%
  mutate( gene = geneName) %>%
  relocate(gene) %>%
  pivot_longer(-gene, names_to = "id", values_to = "expression") %>%
  mutate( id = as.numeric(id)) %>%
  arrange(id, gene) %>%
  pivot_wider(names_from = gene, values_from = expression) %>%
  saveRDS(ntrFILE)

# -----------------------------------------------
# Validation Data
#
readRDS(valFILE) %>%
  pivot_longer(-id, names_to = "gene", values_to = "expression") %>%
  pivot_wider(names_from = id, values_from = expression) -> byPatDF

geneName <- byPatDF$gene

byPatDF %>%
  select(-gene) %>%
  scale()  %>%
  as_tibble() %>%
  mutate( gene = geneName) %>%
  relocate(gene) %>%
  pivot_longer(-gene, names_to = "id", values_to = "expression") %>%
  mutate( id = as.numeric(id)) %>%
  arrange(id, gene) %>%
  pivot_wider(names_from = gene, values_from = expression) %>%
  saveRDS(nvlFILE)

# -----------------------------------------------
# Close the log file
#
sink(type = "message" ) 
close(lf)
