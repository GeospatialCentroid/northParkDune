#' Process Area of Interest (AOI) Files
#'
#' This function processes KMZ files representing areas of interest (AOIs).
#' It reads the first two KMZ files from the `data/raw` directory, converts them
#' into `SpatVector` objects, and returns them as a list. Additionally, it exports
#' the AOIs as GeoPackage (GPKG) files to the `data/derived/aois` directory.
processAOI <- function() {
  files <- list.files(
    "data/raw",
    pattern = ".kmz",
    full.names = TRUE
  )
  # read in the first two files as vector files
  f1 <- terra::vect(files[1]) |>
    terra::project("EPSG:26913")
  f2 <- terra::vect(files[2]) |>
    terra::project("EPSG:26913")
  # return the vector files
  return(list(east = f1, west = f2))
  # export as gpkg
  terra::writeVector(f1, "data/derived/aois/aoiEast.gpkg", overwrite = TRUE)
  terra::writeVector(f2, "data/derived/aois/aoiWest.gpkg", overwrite = TRUE)
}


# 2017 data processing  --------------------------------------------------
process2017Rasts <- function(overwrite = FALSE) {
  rasts <- list.files(
    path = "data/raw/2017",
    pattern = ".tif",
    full.names = TRUE
  )
  aois <- processAOI()

  eastExport <- "data/derived/rasts2017/eastside_2017.tif"
  if (!file.exists(eastExport)) {
    # east processing
    east <- aois$east
    # select rast from the east and crop and mask
    eastRasts <- rasts[grep("eastside", rasts)] |>
      terra::rast() |>
      terra::crop(aoi) |>
      terra::mask(aoi)
    # export
    terra::writeRaster(eastRasts, eastExport, overwrite = TRUE)
  } else {
    print("Eastside 2017 raster already processed")
  }
  westExport <- "data/derived/rasts2017/westside_2017.tif"
  if (!file.exists(westExport) | overwrite == TRUE) {
    # east processing
    aoi <- aois$west
    # select rast from the east and crop and mask
    westRasts <- rasts[grep("westside", rasts)] |>
      terra::rast() |>
      terra::crop(aoi) |>
      terra::mask(aoi)
    # export
    terra::writeRaster(westRasts, westExport, overwrite = TRUE)
  } else {
    print("Westside 2017 raster already processed")
  }
}
