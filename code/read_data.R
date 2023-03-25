# -----------------------------------------------------------
# RAGE: Regression After Gene Expression
#
# Read the processed and create 
#   patients.rds   ... patient characteristics
#   expression.rds ... expression data 
# Sample 1000 probes to create an exploratory subset
#   training.rds   ... 200 patients
#   validation.rds ... 194 patients
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
datFILE <- path(rawData, "GSE168753_processed_data.csv.gz")
exnFILE <- path(cache,   "expression.rds")
patFILE <- path(cache,   "patients.rds")
valFILE <- path(cache,   "validation.rds")
trnFILE <- path(cache,   "training.rds")
logFILE <- path(cache,   "read_data_log.txt")

# --------------------------------------------------
# Divert warning messages to a log file
#
lf <- file(logFILE, open = "wt")
sink(lf, type = "message")

# --------------------------------------------------
# Download the series file from GEO. Save as serFILE
#
if(!file.exists(datFILE) ) 
  download.file(url, datFILE)

# --------------------------------------------------
# patient characteristics
#
read_csv(datFILE) %>%
  select(id = patient_ID, cmv = CMV, gender = GENDER,
         age = AGE, BMI) %>%
  saveRDS(patFILE)


# --------------------------------------------------
# gene expressions
# 5090 genes for 394 patients
#
read_csv(datFILE) %>%
  select(everything(), id = patient_ID, -CMV, -GENDER,
         -AGE, -BMI) %>%
  saveRDS(exnFILE)


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
readRDS(exnFILE) %>%
  .[rows, c(1, cols)] %>%
  saveRDS(trnFILE) 

# -----------------------------------------------
# Validation data
#
readRDS(exnFILE) %>%
  .[-rows, c(1, cols)] %>%
  saveRDS(valFILE) 

# -----------------------------------------------
# Close the log file
#
sink(type = "message" ) 
close(lf)