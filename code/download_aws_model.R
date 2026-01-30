library(aws.s3)

dir <- "data/a_raw_data/"

output_folder <- "species"
fs::dir_create(fs::path(dir, output_folder))

bucket <- "mpaeu-dist"
s3_folder <- "results/species"

aws_api_key <- Sys.getenv("AWS_ACCESS_KEY_ID")
aws_secret_key <- Sys.getenv("AWS_SECRET_ACCESS_KEY")

# Create a function to download
download_objs <- function(s3_objects, local_folder) {
  i <- 0
  total <- length(s3_objects)
  for (obj in s3_objects) {
    i <- i + 1
    cat("Downloading", i, "out of", total, "\n")
    s3_key <- obj$Key
    local_file <- fs::path(local_folder, s3_key)
    
    if (!endsWith(s3_key, "/")) {
      save_object(
        object = s3_key,
        bucket = bucket,
        file = local_file,
        region = "",
        use_https = TRUE 
      )
      message(paste("Downloaded:", s3_key, "to", local_file))
    }
  }
  return(invisible(NULL))
}

# CODE 1: faster, look only at the target species
species <- c(137128) # List the AphiaIDs of the species you want to download

for (sp in species) {
  
  s3_objects <- aws.s3::get_bucket(
    bucket = bucket,
    key = aws_api_key,
    secret = aws_secret_key,
    prefix = paste0(s3_folder, "/taxonid=", sp),
    use_https = TRUE,
    max = Inf
  )
  
  download_objs(s3_objects, fs::path(output_folder, paste0("taxonid=", sp)))
  
}
