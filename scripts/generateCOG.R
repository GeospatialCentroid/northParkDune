pacman::p_load(dplyr, terra, readr, purrr, furrr)

#source the COG function
source("functions/cog_functions.R")

paths <- list.files(
  path = "data/derived/cot",
  pattern = ".tif",
  full.names = TRUE,
  recursive = TRUE
)

# render cloud optimized geotiffs
generatgenerateCOGseCOT(paths = paths)
