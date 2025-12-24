# Setting up packages

## List of required packages (add new required packages here)
packages <- c(
  "tidyverse", "janitor", "DT", "ggpubr", "psych", 
  "irr", "broom", "ggcorrplot", "readxl", "networkD3", 
  "htmlwidgets", "ggalluvial", "lubridate", "gt", 
  "skimr", "zoo", "here", "bigrquery", "glue", "fuzzyjoin", "plotly"
)

# Install missing packages
installed <- rownames(installed.packages())
to_install <- setdiff(packages, installed)
if (length(to_install) > 0) {
  install.packages(to_install, dependencies = TRUE)
}

# Load packages quietly without printing lapply output
suppressPackageStartupMessages({
  invisible(lapply(packages, library, character.only = TRUE))
})

# Set knitr defaults
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.width = 8,
  fig.height = 5
)