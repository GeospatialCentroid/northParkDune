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
generateCOGs(paths = paths)



# cog of the input data for examples 
r17 <- terra::rast("~/trueNAS/work/northParkDune/data/raw/2017/blm_co_kfo_northsandcreek_dsm_3_1cm_westside.tif")
r25 <- terra::rast("~/trueNAS/work/northParkDune/data/raw/Alluvial Fan/NSH - Alluvial Fan_dsm.tif")
e1 <- "data/derived/cog/blm_co_kfo_northsandcreek_dsm_3_1cm_westside.tif"
e2 <- "data/derived/cog/NSH - Alluvial Fan_dsm.tif"

genericCOG(importPath ="data/raw/2017/blm_co_kfo_northsandcreek_dsm_3_1cm_westside.tif",
           exportPath = e1)
genericCOG(importPath ="data/raw/Alluvial Fan/NSH - Alluvial Fan_dsm.tif",
           exportPath = e2)
