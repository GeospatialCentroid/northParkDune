pacman::p_load(terra, dplyr, readr)

# preprocesses steps
source(
  "scripts/dataPreprocessing.R"
)

# change over time steps
source(
  "scripts/changeOverTime.R"
)
