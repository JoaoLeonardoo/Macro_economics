# ================================== #
# === QUERY FUNCTION - BACEN API === #
# ================================== #

# --- Script by Paulo Icaro ---#


# ============= #
# === Query === #
# ============= #
bacen_query = function(bacen_series_code, bacen_series_name, start_date, end_date, source_github = TRUE){
  
  # ---------------------------------- #
  # --- Source Auxiliary Functions --- #
  # ---------------------------------- #
  if(source_github == TRUE){
    tryCatch(expr = suppressWarnings(source('https://raw.githubusercontent.com/paulo-icaro/Bacen_API/main/Bacen_API.R')),
             error= function(e){message('Não foi possível acessar a função Bacen_API')})
    Sys.sleep(1.5)
    
    tryCatch(expr = suppressWarnings(source('https://raw.githubusercontent.com/paulo-icaro/Bacen_API/main/Bacen_URL.R')),
             error = function(e){message('Não foi possível acessar a função Bacen_URL')})
    Sys.sleep(1.5)
  }
  
  Sys.sleep(1.5)


    
  # ----------------------- #
  # --- Data Extraction --- #
  # ----------------------- #
  for(i in seq_along(bacen_series_code)){
  
    message(paste0('Extraindo ', '"', bacen_series_name[i], '"'))
    
    tryCatch(expr = {
      
      # --- Extraction --- #
      bacen_dataset_raw = bacen_api(url = bacen_url(bacen_series_code[i], start_date, end_date))
  
      # --- Grouping Columns --- #
      if(i == 1){bacen_dataset = bacen_dataset_raw}
      else{bacen_dataset = left_join(x = bacen_dataset, y = bacen_dataset_raw, by = join_by('data' == 'data'))}
    
      # --- Naming Headers --- #
      if(i == length(bacen_series_code)){colnames(bacen_dataset) = c('data', bacen_series_name)}
      },
      
      error = function(e){stop('Uma ou mais funções não estão disponíveis ou não há conexão com internet. Verifique sua conexão ou importe as funções de um diretório local.', call. = FALSE)}
    )}

  
  # -------------------------- #
  # --- Return Data Output --- #
  # -------------------------- #
  return(bacen_dataset)
}