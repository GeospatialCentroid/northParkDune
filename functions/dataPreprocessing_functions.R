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
  f1 <- terra::vect(files[1])
  f2 <- terra::vect(files[2])
  # return the vector files
  # return(list(east = f1, west = f2))
  # export as gpkg
  terra::writeVector(
    f1,
    "data/derived/aois/aoiEast_wgs84.gpkg",
    overwrite = TRUE
  )
  terra::writeVector(
    f2,
    "data/derived/aois/aoiWest_wgs84.gpkg",
    overwrite = TRUE
  )
  # project to utm zone 13
  f3 <- f1 |> terra::project("epsg:26913")
  f4 <- f2 |> terra::project("epsg:26913")
  # export the features
  terra::writeVector(
    f3,
    "data/derived/aois/aoiEast_utm13.gpkg",
    overwrite = TRUE
  )
  terra::writeVector(
    f2,
    "data/derived/aois/aoiWest_utm13.gpkg",
    overwrite = TRUE
  )
  return(list(eastWGS = f1, westWGS = f2, eastUTM = f3, westUTM = f4))
}

# 2017 data processing  --------------------------------------------------
processRast <- function(areaName, rasts, aoi_poly, wgs, output_path) {
  # Filter files for this side
  files <- rasts[grep(areaName, rasts)]

  if (length(files) == 0) {
    warning(paste("No files found for", areaName))
    return(NULL)
  }
  if (wgs == TRUE) {
    crs <- "epsg:4326"
  } else {
    crs <- "epsg:26913"
  }
  # A. Create a Virtual Raster (Instant, low memory)
  # This mosaics them virtually without processing
  r_vrt <- terra::vrt(files)

  # B. Project the VECTOR to match the RASTER (Fast)
  # It is much faster to project 1 polygon than 1 billion pixels
  aoi_native <- terra::project(aoi_poly, terra::crs(r_vrt))

  # C. Crop and Mask in Native Space (Reduces data volume massively)
  # We do this BEFORE the heavy projection
  r_cropped <- terra::crop(r_vrt, aoi_native)
  r_masked <- terra::mask(r_cropped, aoi_native)

  # We pass 'filename' here so it streams directly to disk
  terra::project(
    r_masked,
    crs,
    method = "bilinear",
    filename = output_path,
    overwrite = TRUE,
    gdal = c("COMPRESS=LZW", "TILED=YES") # Optional: Compress output
  )
}

#

process2017Rasts <- function(wgs, overwrite = FALSE) {
  rasts <- list.files(
    path = "data/raw/2017",
    pattern = ".tif",
    full.names = TRUE
  )
  # read in AOIS
  aois <- processAOI()
  if (wgs == TRUE) {
    eastExport <- "data/derived/rasts2017/eastside_2017_wgs84.tif"
    aoi <- aois$eastWGS
  } else {
    eastExport <- "data/derived/rasts2017/eastside_2017_utm13.tif"
    aoi <- aois$eastUTM
  }

  # --- Processing East ---
  if (!file.exists(eastExport) || overwrite) {
    message("Processing Eastside...")
    processRast(
      areaName = "eastside",
      rasts = rasts,
      aoi_poly = aoi,
      wgs = wgs,
      output_path = eastExport
    )
  } else {
    print("Eastside 2017 raster already processed")
  }

  # --- Processing West ---
  if (wgs == TRUE) {
    westExport <- "data/derived/rasts2017/westside_2017_wgs84.tif"
    aoi <- aois$westWGS
  } else {
    westExport <- "data/derived/rasts2017/westside_2017_utm13.tif"
    aoi <- aois$westUTM
  }
  if (!file.exists(westExport) || overwrite) {
    message("Processing Westside...")
    processRast(
      areaName = "westside",
      rasts = rasts,
      aoi_poly = aoi,
      wgs = wgs,
      output_path = westExport
    )
  } else {
    print("Westside 2017 raster already processed")
  }

  gc()
}
# so the dems are in wgs84 the dsm are in nad 83, Need to include copies of both in the 2017 data
# then be selected about the input lists that are passed to the 2025 processing function based on the type

# 2025 data processing  --------------------------------------------------

process2025Rast <- function(
  rastPaths,
  areaName,
  wgs,
  overwrite = FALSE
) {
  # construct the export path
  file <- basename(rastPaths)
  folder <- basename(dirname(rastPaths))
  export <- paste0("data/derived/rasts2025/", folder, "_", areaName, "_", file)
  # read in 2017 rast paths
  rast2017 <- list.files(
    "data/derived/rasts2017",
    pattern = ".tif",
    full.names = TRUE
  )
  # files to area
  area2017 <- rast2017[grepl(pattern = areaName, rast2017)]
  # condition for wgs
  if (wgs == TRUE) {
    templatePath <- area2017[grepl(pattern = "wgs84", area2017)]
  } else {
    templatePath <- area2017[grepl(pattern = "utm13", area2017)]
  }

  # check if the file exists
  if (!file.exists(export)) {
    # grab the feature based on areaName
    template_rast <- terra::vrt(templatePath)
    # read in feature and resample
    tryCatch(
      {
        r_src <- rast(rastPaths)

        # 1. Create extent polygons
        poly_src <- terra::as.polygons(ext(r_src))
        poly_template <- terra::as.polygons(ext(template_rast))

        # resample to course resolution
        overlap <- intersect(poly_src, poly_template)[[1]]
        if (nrow(overlap) > 0) {
          # resample
          terra::resample(
            x = r_src,
            y = template_rast,
            method = "bilinear",
            filename = export,
            overwrite = TRUE,
            gdal = c("COMPRESS=LZW", "TILED=YES")
          )
        } else {
          warning(paste(
            "No overlap between",
            rastPaths,
            "and template raster for",
            areaName
          ))
        }
      },
      error = function(e) {
        warning(paste("Failed:", file, "-", e$message))
      }
    )
  } else {
    message(paste("Skipping:", file))
  }
  gc()
}
