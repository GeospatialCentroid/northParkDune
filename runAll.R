pacman::p_load(terra, dplyr, readr)

# preprocesses steps
source(
  "scripts/dataPreprocessing.R"
)

# change over time steps
source(
  "scripts/changeOverTime.R"
)


# testing 
# gather the min max of the original data for a speicific locaiton 
r17 <- terra::rast("~/trueNAS/work/northParkDune/data/raw/2017/blm_co_kfo_northsandcreek_dsm_3_1cm_westside.tif")
val17 <- minmax(r17, compute = TRUE)
hist17 <- his
r25 <- terra::rast("~/trueNAS/work/northParkDune/data/raw/Alluvial Fan/NSH - Alluvial Fan_dsm.tif")
val25 <- minmax(r25, compute = TRUE)
