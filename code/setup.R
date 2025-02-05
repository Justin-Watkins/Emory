#-------------------------------------------------------------------------------
# Pricing and Forecasting Workshop | Top-down forecasting exercise
#-------------------------------------------------------------------------------
setwd(".")
#-------------------------------------------------------------------------------
# Source graphics theme
#-------------------------------------------------------------------------------
source("code/theme.r")
#-------------------------------------------------------------------------------
# Libraries
#-------------------------------------------------------------------------------
library(devtools)

if("FOSBAAS" %in% rownames(installed.packages()) == FALSE) {
  
  devtools::install_github("Justin-Watkins/FOSBAAS"
                           ,ref="master"
                           ,auth_token = NULL)
}

library(FOSBAAS)
library(dplyr)
library(jtools)
library(ggplot2)
library(ggrepel)
library(purrr)
library(readr)
library(tidyr)
# Modeling libraries
library(janitor)
library(rsample)
library(recipes)
library(parsnip)
library(tune)
library(dials)
library(workflows)
library(yardstick)
library(doParallel)