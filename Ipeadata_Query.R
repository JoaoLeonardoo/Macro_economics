# ===================================== #
# === QUERY FUNCTION - IPEADATA API === #
# ===================================== #

# --- Script by Paulo Icaro --- #

library(dplyr)
source("Ipeadata_API.R")
source("Ipeadata_URL.R")

ipeadata_query = function(ipeadata_series_code, ipeadata_series_name, time_interval){
  
  for(i in seq_along(ipeadata_series_code)){

    message(paste0('Extraindo ', '"',  ipeadata_series_name[i], '"'))
    
    tryCatch(expr = {
      
      # --- Extraction --- #
      ipeadata_dataset_raw = ipeadata_api(url = ipeadata_url(series_cod = ipeadata_series_code[i]))
      ipeadata_dataset_raw = ipeadata_dataset_raw[c(2,3)] %>%
        filter(substr(VALDATA, start = 1, stop = 4) %in% c(time_interval))
      
      # --- Grouping Columns --- #
      if(i == 1){
        ipeadata_dataset = ipeadata_dataset_raw
      } else {
        ipeadata_dataset = left_join(x = ipeadata_dataset, y = ipeadata_dataset_raw, by = join_by('VALDATA' == 'VALDATA'))
      }
      
      # --- Headers --- #
      if(i == length(ipeadata_series_name)){
        colnames(ipeadata_dataset) = c('data', ipeadata_series_name)
      }
    },
    error = function(e){
      stop('Erro na extração: ', e$message, call. = FALSE)
    })
  }
  
  return(ipeadata_dataset)
}
