pacman::p_load(dplyr, terra, readr, purrr, furrr)
source("functions/cot_functions.R")

# clean up
## some rasters have no data values, remove these
r25 <- list.files("data/derived/rasts2025", full.names = TRUE)

# this might not work on the
# for (i in r25) {
#   print(i)
#   r1 <- terra::rast(i)
#   # pull min and max
#   vals <- terra::minmax(r1, compute = TRUE)[, 1]
#   min <- is.nan(vals[1])
#   max <- is.nan(vals[2])
#   if (min & max) {
#     file.remove(i)
#     # print("yes")
#   }
# }

# list all processed files and remove any that have no data values

aois <- list.files(path = "data/derived/aois", full.names = TRUE)
eastAOIS <- aois[grep("aoiEast", aois)]
westAOIS <- aois[grep("aoiWest", aois)]

# paths to rast objects
r17 <- list.files("data/derived/rasts2017", full.names = TRUE)
r25 <- list.files("data/derived/rasts2025", full.names = TRUE)

#east side processing
for (i in c(TRUE, FALSE)) {
  generateCOT(area = "east", wgs = i, r17 = r17, r25 = r25)
}
# west side processing
for (i in c(TRUE, FALSE)) {
  generateCOT(area = "west", wgs = i, r17 = r17, r25 = r25)
}
