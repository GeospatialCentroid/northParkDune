pacman::p_load(terra, dplyr, readr, furrr)
# load in all images mask/crop them to the aoi file
source("functions/dataPreprocessing_functions.R")

# # testing
# r1 <- terra::rast("data/derived/cot/Creek Middle_westside_dem.tif")
# terra::minmax(r1)

## process AOI
aois <- processAOI()
# input data is in wgs84
# project to nad83 utm zone 13 for processing
# export both the wgs84 and utm13 versions for processing steps

# process 2017 imagery
## 2017 data is in utm 13, reprojection to wgs84 to match 2025
## this is lower resolution and there are only two objects, so decided to reproject his layer
process2017Rasts(wgs = TRUE, overwrite = FALSE)


# process 2025 imagery
## read in all images
rasts <- list.files(
  path = "data/raw",
  pattern = ".tif",
  full.names = TRUE,
  recursive = TRUE
)

# the dsm data is stored in a WGS 84 / UTM zone 13N (EPSG:32613) projects which is really odd
utmRasts <- rasts[grep("dsm.tif", rasts)]
# the dem data is stored in lon/lat WGS 84 (EPSG:4326)
wgsRasts <- rasts[grep("dem", rasts)]


plan(multisession, workers = 2)

# east side processing
furrr::future_walk(
  .x = wgsRasts,
  .f = process2025Rast,
  areaName = "eastside",
  wgs = TRUE,
  overwrite = FALSE
)
# will need to alter for nad83 once original 2017 data is processed

# west side processing
furrr::future_walk(
  .x = wgsRasts,
  .f = process2025Rast,
  areaName = "westside",
  wgs = TRUE,
  overwrite = FALSE
)
