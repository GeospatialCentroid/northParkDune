# generate a series of cloud optimaize geo tiffs
generateCOGs <- function(paths) {
  # set the terra export options
  cog_options <- c(
    "COMPRESS=DEFLATE",
    "TFW=YES", # Include world file
    "OVERVIEW_COUNT=5" # Example: create 5 levels of overviews
  )
  message(
    "starting the transformation of the files to cloud optimized geotiffs"
  )
  for (i in seq_along(paths)) {
    path <- paths[i]
    message(paste("Processing file", i, "of", length(paths), ":", path))
    # export location
    name <- basename(path)
    export <- paste0("data/products/cog/", name)
    if (!file.exists(export)) {
      tryCatch(
        {
          raster_data <- terra::rast(path)
          # 5b. Export the raster as a COG using the "COG" driver
          terra::writeRaster(
            x = raster_data,
            filename = export,
            filetype = "COG", # Specify the Cloud Optimized GeoTIFF driver
            gdal = cog_options, # Apply the COG creation options
            overwrite = TRUE # Allows overwriting if you rerun the script
          )

          cat(paste0(
            "SUCCESS: Exported as COG -> ",
            basename(path),
            "\n"
          ))
        },
        error = function(e) {
          cat(paste0(
            "ERROR processing ",
            basename(input_file),
            ": ",
            conditionMessage(e),
            "\n"
          ))
        }
      )
    } else {
      cat(paste0("Skipping: ", name, " (COG already exists)\n"))
      next
    }
  }
}



genericCOG <- function(importPath,exportPath){
  cog_options <- c(
    "COMPRESS=DEFLATE",
    "TFW=YES", # Include world file
    "OVERVIEW_COUNT=5" # Example: create 5 levels of overviews
  )
  if (!file.exists(exportPath)) {
    tryCatch(
      {
        raster_data <- terra::rast(importPath)
        # 5b. Export the raster as a COG using the "COG" driver
        terra::writeRaster(
          x = raster_data,
          filename = exportPath,
          filetype = "COG", # Specify the Cloud Optimized GeoTIFF driver
          gdal = cog_options, # Apply the COG creation options
          overwrite = TRUE # Allows overwriting if you rerun the script
        )
        
        cat(paste0(
          "SUCCESS: Exported as COG -> ",
          basename(importPath),
          "\n"
        ))
      },
      error = function(e) {
        cat(paste0(
          "ERROR processing ",
          basename(importPath),
          ": ",
          conditionMessage(e),
          "\n"
        ))
      }
    )
  } else {
    cat(paste0("Skipping: ", importPath, " (COG already exists)\n"))
    next
  }
}


