# ================================== #
# === QUERY FUNCTION - BACEN API === #
# ================================== #

# --- Script by Paulo Icaro ---#

# Carrega funções auxiliares localmente
library(dplyr)
source("Bacen_API.R")
source("Bacen_URL.R")

bacen_query = function(bacen_series_code, bacen_series_name, start_date, end_date){
  
  for(i in seq_along(bacen_series_code)){
  
    message(paste0('Extraindo ', '"', bacen_series_name[i], '"'))
    
    tryCatch(expr = {
      
      # --- Extraction --- #
      bacen_dataset_raw = bacen_api(url = bacen_url(bacen_series_code[i], start_date, end_date))
  
      # --- Grouping Columns --- #
      if(i == 1){
        bacen_dataset = bacen_dataset_raw
      } else {
        bacen_dataset = left_join(x = bacen_dataset, y = bacen_dataset_raw, by = join_by('data' == 'data'))
      }
    
      # --- Naming Headers --- #
      if(i == length(bacen_series_code)){
        colnames(bacen_dataset) = c('data', bacen_series_name)
      }
    },
    error = function(e){
      stop('Erro na extração: ', e$message, call. = FALSE)
    })
  }
  
  return(bacen_dataset)
}
