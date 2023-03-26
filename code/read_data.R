# -----------------------------------------------------------
# RAGE: Regression After Gene Expression
#
# Read the processed data and save in cache 
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
url <- "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE168nnn/GSE168753/suppl/GSE168753_processed_data.csv.gz"

# -------------------------------------------------
# targets - output files created by this script
#
datRDS <- path(rawData, "GSE168753_processed_data.csv.gz")
exnRDS <- path(cache,   "expression.rds")
patRDS <- path(cache,   "patients.rds")
valRDS <- path(cache,   "validation.rds")
trnRDS <- path(cache,   "training.rds")
logRDS <- path(cache,   "read_data_log.txt")

# --------------------------------------------------
# Divert warning messages to a log file
#
lf <- file(logRDS, open = "wt")
sink(lf, type = "message")

# --------------------------------------------------
# Download the series file from GEO. Save as serRDS
#
if(!file.exists(datRDS) ) 
  download.file(url, datRDS)

# --------------------------------------------------
# patient characteristics
#
read_csv(datRDS) %>%
  select(id = patient_ID, cmv = CMV, gender = GENDER,
         age = AGE, BMI) %>%
  saveRDS(patRDS)


# --------------------------------------------------
# gene expressions
# 5090 genes for 394 patients
#
read_csv(datRDS) %>%
  select(everything(), id = patient_ID, -CMV, -GENDER,
         -AGE, -BMI) %>%
  saveRDS(exnRDS)


# -----------------------------------------------
# Create a sample of 1000 probes 
# Select 200 patients for training
#
set.seed(7382)
sample(2:5091, size = 1000, replace = FALSE) %>%
  sort() -> cols
sample(1:394, size = 200, replace = FALSE) %>%
  sort() -> rows

# -----------------------------------------------
# Training Data
#
readRDS(exnRDS) %>%
  .[rows, c(1, cols)] %>%
  saveRDS(trnRDS) 

# -----------------------------------------------
# Validation data
#
readRDS(exnRDS) %>%
  .[-rows, c(1, cols)] %>%
  saveRDS(valRDS) 

# -----------------------------------------------
# Close the log file
#
sink(type = "message" ) 
close(lf)