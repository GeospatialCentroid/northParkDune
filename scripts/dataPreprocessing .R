pacman::p_load(terra, dplyr, readr)
# load in all images mask/crop them to the aoi file
source("functions/dataPreprocessing_functions.R")

## process AOI
aois <- processAOI()

# process 2017 imagery
process2017Rasts()
