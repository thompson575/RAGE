# -----------------------------------------------------------
# RAGE: Regression After Gene Expression
#
# Feature selection comparison
# Selected genes vs First few PCs vs Selected PCs
#
# Date: 19 Feb 2023
#       22 Feb 2023 .. added the scaled PCA results
#
library(tidyverse)
library(glue)
library(fs)

cache    <- "C:/Projects/RCourse/Masterclass/RAGE/data/cache"
code     <- "C:/Projects/RCourse/Masterclass/RAGE/code"
# -------------------------------------------------
# dependencies - input files used by this script
# vpca .. PCA of covariance,   scale = FALSE
# cpca .. PCA of correlations, scale = TRUE
#
valFILE <- path(cache, "norm_validation.rds")
trnFILE <- path(cache, "norm_training.rds")
patFILE <- path(cache, "patients.rds")
vstFILE <- path(cache, "train_vpca_scores.rds")
vsvFILE <- path(cache, "valid_vpca_scores.rds")
cstFILE <- path(cache, "train_cpca_scores.rds")
csvFILE <- path(cache, "valid_cpca_scores.rds")
# -------------------------------------------------
# targets - output files created by this script
#
flsFILE <- path(cache, "feature_loss.rds")
logFILE <- path(cache, "features_log.txt")
# --------------------------------------------------
# Divert warning messages to a log file
#
lf <- file(logFILE, open = "wt")
sink(lf, type = "message")

# --------------------------------------------------
# Read Computation Functions
#
source("C:/Projects/RCourse/Masterclass/CAGE/code/calculation_functions.R")

# --------------------------------------------
# Read data on the 1000 genes
# add patient: 0=Benign 1=Cancer
#
readRDS(patFILE) %>%
  select(id, BMI) -> patientDF
  
readRDS(valFILE) %>%
  left_join(patientDF, by = "id")  -> validDF 

readRDS(trnFILE) %>%
  left_join(patientDF, by = "id") -> trainDF 

readRDS(vstFILE) %>%
  left_join(patientDF, by = "id") -> vScoreTrainDF 

readRDS(vsvFILE) %>%
  left_join(patientDF, by = "id") -> vScoreValidDF 

readRDS(cstFILE) %>%
  left_join(patientDF, by = "id") -> cScoreTrainDF 

readRDS(csvFILE) %>%
  left_join(patientDF, by = "id") -> cScoreValidDF 

# ------------------------------------------------
# gene names
#
names(trainDF)[2:1001] -> geneNames

# ------------------------------------------------
# Loss from univariate linear regressions 
#
geneUniDF <- univariate_linear(trainDF, 
                                  "BMI", 
                                  geneNames) 


# ------------------------------------------------------------------
# linear Regression using 1 to 50 selected predictors
#
geneUniDF %>%
  arrange(loss) %>%
  multiple_linear(trainDF, 
                    validDF, 
                    "BMI") -> geneSelectedDF

  
# ------------------------------------------------------------
# PC names
#
pcaNames <- glue("PC{1:200}")

# ------------------------------------------------
# Loss from univariate linear regressions
#
vpcaUniDF <- univariate_linear(vScoreTrainDF, 
                                 "BMI", 
                                 pcaNames)


# ------------------------------------------------------------------
# Multivariate linear using 1 to 50 PCs selected by univariate loss
#
vpcaUniDF %>%
  arrange(loss) %>%
  multiple_linear(vScoreTrainDF, 
                    vScoreValidDF, 
                    "BMI") -> vpcaSelectedDF

# ------------------------------------------------------------------
# Multivariate linear using first 1 to 50 PCs
#
vpcaUniDF %>%
   multiple_linear(vScoreTrainDF, 
                     vScoreValidDF, 
                     "BMI") -> vpcaOrderedDF

# ------------------------------------------------
# Loss from univariate linear regressions
#
cpcaUniDF <- univariate_linear(cScoreTrainDF, 
                                 "BMI", 
                                 pcaNames)

# ------------------------------------------------------------------
# Multivariate linear using 1 to 50 selected PCs
#
cpcaUniDF %>%
  arrange(loss) %>%
  multiple_linear(cScoreTrainDF, 
                    cScoreValidDF, 
                    "BMI") -> cpcaSelectedDF

# ------------------------------------------------------------------
# Multivariate linear using first 1 to 50 PCs
#
cpcaUniDF %>%
  multiple_linear(cScoreTrainDF, 
                    cScoreValidDF, 
                    "BMI") -> cpcaOrderedDF

# ---------------------------------------------
# Save results to cache
#
list(geneUniDF      = geneUniDF, 
     geneSelectedDF = geneSelectedDF,
     vpcaUniDF       = vpcaUniDF, 
     vpcaSelectedDF  = vpcaSelectedDF, 
     vpcaOrderedDF   = vpcaOrderedDF, 
     cpcaUniDF       = cpcaUniDF, 
     cpcaSelectedDF  = cpcaSelectedDF, 
     cpcaOrderedDF   = cpcaOrderedDF) %>%
  saveRDS(flsFILE)

# -----------------------------------------------
# Close the log file
#
sink(type = "message") 
close(lf)
