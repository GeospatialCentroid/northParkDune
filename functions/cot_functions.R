generateCOT <- function(area, wgs, r17, r25) {
  # subset the raster paths by the area term
  if (area == "east") {
    r17 <- r17[grep("eastside", r17)]
    r25 <- r25[grep("eastside", r25)]
  } else if (area == "west") {
    r17 <- r17[grep("westside", r17)]
    r25 <- r25[grep("westside", r25)]
  }
  # condition for the crs
  if (wgs == TRUE) {
    r17 <- r17[grep("_wgs84", r17)]
    r25 <- r25[grep("_dem", r25)]
  } else {
    r17 <- r17[grep("_utm13", r17)]
    r25 <- r25[grep("_dsm", r25)]
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


