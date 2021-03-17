# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")


# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
x <- read_tsv(file = "data/gravier_x.tsv.gz")
y <- read_tsv(file = "data/gravier_y.tsv.gz")

# Wrangle data ------------------------------------------------------------
my_data_clean <- bind_cols(y,x)

# Write data --------------------------------------------------------------
write_tsv(x = my_data_clean,
          path = "data/02_my_data_clean.tsv.gz")