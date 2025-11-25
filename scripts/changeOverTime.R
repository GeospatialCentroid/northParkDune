pacman::p_load(dplyr, terra, readr, purrr, furrr)


# clean up
## some rasters have no data values, remove these
r25 <- list.files("data/derived/rasts2025", full.names = TRUE)

for (i in r25) {
  print(i)
  r1 <- terra::rast(i)
  # pull min and max
  vals <- terra::minmax(r1)[, 1]
  min <- is.nan(vals[1])
  max <- is.nan(vals[2])
  if (min & max) {
    file.remove(i)
    # print("yes")
  }
}

# list all processed files and remove any that have no data values

aois <- list.files(path = "data/derived/aois", full.names = TRUE)
eastAOIS <- aois[grep("aoiEast", aois)]
westAOIS <- aois[grep("aoiWest", aois)]

# paths to rast objects
r17 <- list.files("data/derived/rasts2017", full.names = TRUE)
r25 <- list.files("data/derived/rasts2025", full.names = TRUE)


area <- "east"
aois <- eastAOIS

generateCOT <- function(area, r17, r25) {
  # subset the raster paths by the area term
  if (area == "east") {
    r17 <- r17[grep("eastside", r17)]
    r25 <- r25[grep("eastside", r25)]
  } else if (area == "west") {
    r17 <- r17[grep("westside", r17)]
    r25 <- r25[grep("westside", r25)]
  }
  r1 <- terra::rast(r17)

  for (i in r25) {
    export <- paste0("data/derived/cot/", basename(i))
    if (!file.exists(export)) {
      r2 <- terra::rast(i)
      # difference the rasters
      diff <- r2 - r1
      terra::writeRaster(diff, filename = export, overwrite = TRUE)
      gc
    }
  }
}

#east side processing
generateCOT(area = "east", r17 = r17, r25 = r25)

#west side processing
generateCOT(area = "east", r17 = r17, r25 = r25)
