# ==============================
# SPHERES – Daily Data Pipeline
# ==============================

message("Starting SPHERES daily pipeline...")

# Always use project root
root <- normalizePath(".")
setwd(root)

# ---- Setup ----
source("code/01_setup_prerequisites.R")

# ---- Ingestion ----
source("code/03_ingestion.R")   # must create: enc_raw

stopifnot(exists("enc_raw"))

# ---- Cleaning ----
source("code/04_cleaning.R")    # must create: enc

stopifnot(exists("enc"))

# ---- Metadata ----
attr(enc, "pipeline_run_time") <- Sys.time()
attr(enc, "pipeline_run_date") <- Sys.Date()

# ---- Persist ----
saveRDS(enc, "enc_cleaned.rds")

message("Pipeline completed successfully at ", Sys.time())