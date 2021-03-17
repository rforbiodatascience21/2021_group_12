# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")


# Define functions --------------------------------------------------------
#source("R/99_project_functions.R")


# Load data ---------------------------------------------------------------
#my_data_raw <- load("data/raw/gravier.RData")
load("data/raw/gravier.RData")

# Wrangle data ------------------------------------------------------------
y= as_tibble(pluck(gravier, "y"))
x= as_tibble(pluck(gravier, "x"))


# Write data --------------------------------------------------------------
write_tsv(x,
          path = "data/gravier_x.tsv.gz")

write_tsv(y,
          path = "data/gravier_y.tsv.gz")