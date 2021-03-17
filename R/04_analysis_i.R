# Clear workspace ---------------------------------------------------------
rm(list = ls())

#install.packages("cowplot")
# Load libraries ----------------------------------------------------------
library("tidyverse")
library("tidyr")
library("broom")
library("cowplot")


# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")

# Load data ---------------------------------------------------------------
my_data_clean_aug <- read_tsv(file = "data/03_my_data_clean_aug.tsv.gz")

# Wrangle data ------------------------------------------------------------
my_data_clean_aug_long = pivot_longer(data = my_data_clean_aug, 
                                 cols=-outcome, names_to = "gene", 
                                 values_to = "log2_expr_level")

#Making a nested tibble to sample from
my_data_clean_aug_long_nested <- my_data_clean_aug_long %>% 
  group_by(gene) %>% 
  nest() %>% 
  ungroup(gene)

#Sampling 100 random genes from this nested tibble
set.seed(100)
my_data_clean_aug_long_nested <- sample_n(my_data_clean_aug_long_nested, size = 100)

#PCA
#We pull out the 100 random genes from our original data inorder to continiue working with the 100 sample points.
my_data_clean_aug_wide = my_data_clean_aug %>%
  select(outcome, pull(my_data_clean_aug_long_nested, gene))


#We can use this data to run a PCA and store the result in pca_fit
pca_fit <- my_data_clean_aug_wide %>% 
  select(where(is.numeric)) %>% # retain only numeric columns
  prcomp(scale = TRUE) # do PCA on scaled data


# Visualise data ----------------------------------------------------------
#We now plot the data in PC coordinates.
plot1=pca_fit %>%
  augment(my_data_clean_aug_wide) %>% # add original dataset back in
  ggplot(aes(.fittedPC1, .fittedPC2, color = outcome)) + 
  geom_point(size = 1.5) +
  theme_half_open(12) + background_grid()


#Extracting the rotation matrix:
pca_fit %>%
  tidy(matrix = "rotation")

#We use an arrow style plot to visualize the vectors of the rotation matrix.
# define arrow style for plotting
arrow_style <- arrow(
  angle = 20, ends = "first", type = "closed", length = grid::unit(8, "pt")
)

# plot rotation matrix
plot2= pca_fit %>%
  tidy(matrix = "rotation") %>%
  pivot_wider(names_from = "PC", names_prefix = "PC", values_from = "value") %>%
  ggplot(aes(PC1, PC2)) +
  geom_segment(xend = 0, yend = 0, arrow = arrow_style) +
  geom_text(
    aes(label = column),
    hjust = 1, nudge_x = -0.02, 
    color = "#904C2F"
  ) +
  xlim(-0.25, 0.25) + ylim(-0.25, 0.25) +
  coord_fixed() + # fix aspect ratio to 1:1
  theme_minimal_grid(12)

#At last we look at the variance explained by each of the PC's. First we extract the eigenvalues
pca_fit %>%
  tidy(matrix = "eigenvalues")

#We now plot the variance explained by the top 10 PC's.
plot3=pca_fit %>%
  tidy(matrix = "eigenvalues") %>%
  ggplot(aes(PC, percent)) +
  geom_col(fill = "#56B4E9", alpha = 0.8) +
  scale_x_continuous(limits=c(0,11), breaks=1:10) +
  scale_y_continuous(
    labels = scales::percent_format(),
    expand = expansion(mult = c(0, 0.01))
  ) +
  theme_minimal_hgrid(12)

#As seen from the plot above the top 10 PC's together explain around 50% of the varriance in the data set.


# Write data --------------------------------------------------------------
#write_tsv(...)
ggsave(filename = "results/04_plot1.png", plot = plot1, width = 16, height = 9, dpi = 72)
ggsave(filename = "results/04_plot2.png", plot = plot2, width = 16, height = 9, dpi = 72)
ggsave(filename = "results/04_plot3.png", plot = plot3, width = 16, height = 9, dpi = 72)
