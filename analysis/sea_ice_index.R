library(tidyverse)
library(readxl)
library(here)
library(glue)
library(tidyr)


# newest data -------------------------------------------------------------
url = "https://masie_web.apps.nsidc.org/pub//DATASETS/NOAA/G02135/seaice_analysis/Sea_Ice_Index_Daily_Extent_G02135_v3.0.xlsx"



# date --------------------------------------------------------------------
date = Sys.Date() %>% str_replace_all("-", "")

# base dir ----------------------------------------------------------------
op_dir = here("output/sea_ice_index")
if(!dir.exists(op_dir)){
  dir.create(op_dir, recursive = T)
}

# download data -----------------------------------------------------------
raw_data_path = here(op_dir, glue("{date}_raw_sea_ice.xlsx"))
download.file(url, raw_data_path)


# output data -------------------------------------------------------------
op = here("output/sea_ice_index/sea_ice_index.csv")


# new data ----------------------------------------------------------------
raw_data = read_xlsx(raw_data_path)


# clean -------------------------------------------------------------------
raw_data %>%
  dplyr::rename(month = 1,
                day = 2) %>%
  tidyr::fill(month) %>%
  mutate(month_numeric = match(month, month.name) ,
         .before = month) %>%
  mutate(display_date = as.Date(glue("2000-{month_numeric}-{day}")),
         .after = month)  %>%
  select(where(function(x) {
    sumna = sum(is.na(x))
    onlyNA = sumna != length(x)
    return(onlyNA)
  })) %>%
  select(-month_numeric, -month, -day) -> data_final


# write out ---------------------------------------------------------------
write_csv(data_final, op)


