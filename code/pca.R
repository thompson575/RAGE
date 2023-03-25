# -----------------------------------------------------------
# Project RAGE
# Principal Component Analysis of 1000 Probes
#
# Date: 20 March 2023
#
# -----------------------------------------------------------
library(tidyverse)
library(fs)

cache    <- "C:/Projects/RCourse/Masterclass/RAGE/data/cache"
# -------------------------------------------------
# dependencies - input files used by this script
#
valFILE <- path(cache, "norm_validation.rds")
trnFILE <- path(cache, "norm_training.rds")
patFILE <- path(cache, "patients.rds")

# -------------------------------------------------
# targets - output files created by this script
# vpca .. PCA of covariance, scale = FALSE
# cpca .. PCA of correlations, scale = TRUE
#
vpcFILE <- path(cache, "train_vpca.rds")
vstFILE <- path(cache, "train_vpca_scores.rds")
vsvFILE <- path(cache, "valid_vpca_scores.rds")
cpcFILE <- path(cache, "train_cpca.rds")
cstFILE <- path(cache, "train_cpca_scores.rds")
csvFILE <- path(cache, "valid_cpca_scores.rds")
logFILE <- path(cache, "pca_log.txt")

# --------------------------------------------------
# Divert warning messages to a log file
#
lf <- file(logFILE, open = "wt")
sink(lf, type = "message")

# --------------------------------------------
# Read data on 1000 probes
#
validDF   <- readRDS(valFILE)
trainDF   <- readRDS(trnFILE)
patientDF <- readRDS(patFILE)

# --------------------------------------------
# covariance pca of the training data
#
trainDF %>%
  select(-id) %>%
  as.matrix() %>% 
  prcomp(scale = FALSE) %>%
  saveRDS(vpcFILE) 

# --------------------------------------------
# vpca scores of the training data
#
readRDS(vpcFILE) %>%
  predict() %>%
  as_tibble() %>%
  mutate(id = trainDF$id) %>%
  relocate(id) %>%
  saveRDS(vstFILE) 

# --------------------------------------------
# vpca scores of the validation data
#
readRDS(vpcFILE) %>%
  predict(newdata = validDF) %>%
  as_tibble() %>%
  mutate(id = validDF$id) %>%
  relocate(id) %>%
  saveRDS(vsvFILE) 

# --------------------------------------------
# correlation pca of the training data
#
trainDF %>%
  select(-id) %>%
  as.matrix() %>% 
  prcomp(scale = TRUE) %>%
  saveRDS(cpcFILE) 

# --------------------------------------------
# pca scores of the training data
#
readRDS(cpcFILE) %>%
  predict() %>%
  as_tibble() %>%
  mutate(id = trainDF$id) %>%
  relocate(id) %>%
  saveRDS(cstFILE) 

# --------------------------------------------
# pca scores of the validation data
#
readRDS(cpcFILE) %>%
  predict(newdata = validDF) %>%
  as_tibble() %>%
  mutate(id = validDF$id) %>%
  relocate(id) %>%
  saveRDS(csvFILE) 

# -----------------------------------------------
# Close the log file
#
sink(type = "message") 
close(lf)