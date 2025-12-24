# -----------------------------------
# Big R Query Setup
# -----------------------------------
library(bigrquery)
library(glue)
library(tidyverse)
library(readxl)

# ----------------------------------
# LOMBOK BARAT ---------------------
# ----------------------------------

# Authenticate
bq_auth(path = Sys.getenv("BQ_SA_LOMBOK_BARAT"))

# Assign server to dedicated name
project_id_lbr <- "spheres-lombok-barat" # Lombok Barat

# Define SQL Queries
## Encounter data (from BQ)
q_lbr <- glue("SELECT distinct * FROM `spheres-lombok-barat.dashboard.kunjungan_ibu_hamil_new`")

## Birth data (from Kobo)
q_lbr_inc <- glue("SELECT distinct case_id, data_entry_clerk_staff_id, first_name, nik_mother, birth_date, contact_number, hpht, luaran_kehamilan, first_nameb1, birth_dateb1, Kecamatan, Kelurahan,  pilih_nama_puskesmas, tuliskan_nama_rumah_sakit, tuliskan_nama_praktik_mandiri_bidan_pmb, tuliskan_nama_klinik, tanggal_masuk_inc, tanggal_keluar_inc FROM `spheres-lombok-barat.data_kobo_form.e-form_pencatatan_pelayanan_intranatal_care`")

## Healthcare worker data (from BQ)
q_lbr_prac <- glue("SELECT distinct practitioner.practitionerId, practitioner.display prac_display, `code`[SAFE_OFFSET(0)].`coding`[SAFE_OFFSET(0)].code, `code`[SAFE_OFFSET(0)].`coding`[SAFE_OFFSET(0)].display prac_role, `organization`.organizationId, concat('Puskesmas ',initcap(lower(`organization`.display))) puskesmas, `identifier`[SAFE_OFFSET(0)].value id_practitioner, `identifier`[SAFE_OFFSET(0)].use,  FROM `spheres-lombok-barat.spheres_healthcare_datastore_bq_output.PractitionerRole` where practitioner.practitionerId is not null
 ")

# Running the Query
## Encounter query
job_lbr <- bq_project_query(
  x = project_id_lbr,        # project_id string
  query = q_lbr,         # your SQL query
  location = "asia-southeast2"
)

## Kobo INC Query
job_lbr_inc <- bq_project_query(
  x = project_id_lbr,
  query = q_lbr_inc,
  location = "asia-southeast2"
)

## HCW query
job_lbr_prac <- bq_project_query(
  x = project_id_lbr,
  query = q_lbr_prac,
  location = "asia-southeast2"
)

# Creating Key Datasets
## Summoning data from bigquery
enc_lbr <- bq_table_download(job_lbr)
birth_lbr_raw <- bq_table_download(job_lbr_inc)
hcw_lbr <- bq_table_download(job_lbr_prac)

## adding 'kabupaten' variable to mark between sites
enc_lbr <- enc_lbr %>% mutate(kabupaten = "lombok barat")
birth_lbr_raw <- birth_lbr_raw %>% mutate(kabupaten = "lombok barat")
hcw_lbr <- hcw_lbr %>% mutate(kabupaten = "lombok barat")

# ----------------------------------
# PURBALINGGA ----------------------
# ----------------------------------

# Authenticate
bq_auth(path = Sys.getenv("BQ_SA_PURBALINGGA"))

# Assign server to dedicated name
project_id_pbg <- "stellar-orb-451904-d9" # Purbalingga

# Define SQL Queries
## Encounter data (from BQ)
q_pbg <- glue("SELECT distinct * FROM `stellar-orb-451904-d9.dashboard.kunjungan_ibu_hamil_new`
 ")

## Birth data (from Kobo)
q_pbg_inc <- glue("SELECT distinct case_id,data_entry_clerk_staff_id, first_name, nik_mother, birth_date, contact_number, hpht, luaran_kehamilan, first_nameb1, birth_dateb1, Kecamatan, Kelurahan,  pilih_nama_puskesmas, tuliskan_nama_rumah_sakit, tuliskan_nama_praktik_mandiri_bidan_pmb, tuliskan_nama_klinik, tanggal_masuk_inc, tanggal_keluar_inc FROM `stellar-orb-451904-d9.kobo_form.e-form_pencatatan_pelayanan_intranatal_care`")

## Healthcare worker data (from BQ)
q_pbg_prac <- glue("SELECT distinct practitioner.practitionerId, practitioner.display prac_display, `code`[SAFE_OFFSET(0)].`coding`[SAFE_OFFSET(0)].code, `code`[SAFE_OFFSET(0)].`coding`[SAFE_OFFSET(0)].display prac_role, `organization`.organizationId, concat('Puskesmas ',initcap(lower(`organization`.display))) puskesmas, `identifier`[SAFE_OFFSET(0)].value id_practitioner, `identifier`[SAFE_OFFSET(0)].use,  FROM `stellar-orb-451904-d9.spheres_healthcare_datastore_bq_output.PractitionerRole` where practitioner.practitionerId is not null
 ")

# Running the Query
## Encounter query
job_pbg <- bq_project_query(
  x = project_id_pbg,        # project_id string
  query = q_pbg,         # your SQL query
  location = "asia-southeast2"
)

## Kobo INC
job_pbg_inc <- bq_project_query(
  x = project_id_pbg,        # project_id string
  query = q_pbg_inc,         # your SQL query
  location = "asia-southeast2"
)

## HCW
job_pbg_prac <- bq_project_query(
  x = project_id_pbg,
  query = q_pbg_prac,
  location = "asia-southeast2"
)

# Creating Key Datasets

## Summoning data from bigquery
enc_pbg <- bq_table_download(job_pbg)
birth_pbg_raw <- bq_table_download(job_pbg_inc)
hcw_pbg <- bq_table_download(job_pbg_prac)

## adding 'kabupaten' variable to mark between sites
enc_pbg <- enc_pbg %>% mutate(kabupaten = "purbalingga")
birth_pbg_raw <- birth_pbg_raw %>% mutate(kabupaten = "purbalingga")
hcw_pbg <- hcw_pbg %>% mutate(kabupaten = "purbalingga")

# Merging two different Kabupaten datasets
enc_raw <- bind_rows(
  enc_lbr %>% mutate(across(everything(), as.character)),
  enc_pbg %>% mutate(across(everything(), as.character))
)

birth_raw <- bind_rows(
  birth_pbg_raw %>% mutate(across(everything(), as.character)),
  birth_lbr_raw %>% mutate(across(everything(), as.character))
)

hcw_raw <- bind_rows(
  hcw_pbg %>% mutate(across(everything(), as.character)),
  hcw_lbr %>% mutate(across(everything(), as.character))
)

# Summon Dictionary and Codebooks for respective datasets

# Define the Excel file
dict_file <- "SPHERES ANC Data Dictionary.xlsx"

# Read each sheet into a separate data frame
cb_enc   <- read_excel(dict_file, sheet = "enc")
cb_hcw   <- read_excel(dict_file, sheet = "hcw")
cb_birth <- read_excel(dict_file, sheet = "birth")

# district code
district <- read_excel(dict_file, sheet = "district")
# quality of care list
qoc <- read_excel(dict_file, sheet = "qoc")