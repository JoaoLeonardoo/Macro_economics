# ===================================== #
# === QUERY FUNCTION - IPEADATA API === #
# ===================================== #

# --- Script by Paulo Icaro --- #


# ============= #
# === Query === #
# ============= #
ipeadata_query = function(ipeadata_series_code, ipeadata_series_name, time_interval, source_github = TRUE){
  
  # ---------------------------------- #
  # --- Source Auxiliary Functions --- #
  # ---------------------------------- #
  if(source_github == TRUE){
    tryCatch(expr = suppressWarnings(source('https://raw.githubusercontent.com/paulo-icaro/Ipeadata_API/refs/heads/main/Ipeadata_API.R')),
             error = function(e){message('Não foi possível acessar a função Ipeadata_API')})
    
    Sys.sleep(1.5)
    
    tryCatch(expr = suppressWarnings(source('https://raw.githubusercontent.com/paulo-icaro/Ipeadata_API/refs/heads/main/Ipeadata_URL.R')),
      error = function(e){message('Não foi possível acessar a função Ipeadata_URL')})
    
    Sys.sleep(1.5)
    
    } else {
      message('Caso não tenha feito ainda, importe as funções Ipeadata_API e Ipeadata_URL de um diretório local e execute este script novamente.\n')
    }
  
  Sys.sleep(1.5)
  
  
  # ----------------------- #
  # --- Data Extraction --- #
  # ----------------------- #
  for(i in seq_along(ipeadata_series_code)){

    message(paste0('Extraindo ', '"',  ipeadata_series_name[i], '"'))
    
    tryCatch(expr = {
      
      # --- Extraction --- #
      ipeadata_dataset_raw = ipeadata_api(url = ipeadata_url(series_cod = ipeadata_series_code[i]))
      ipeadata_dataset_raw = ipeadata_dataset_raw[c(2,3)] %>% filter(substr(VALDATA, start = 1, stop = 4) %in% c(time_interval))
      
      # --- Grouping Columns --- #
      if(i == 1){ipeadata_dataset = ipeadata_dataset_raw}
      else{ipeadata_dataset = left_join(x = ipeadata_dataset, y = ipeadata_dataset_raw, by = join_by('VALDATA' == 'VALDATA'))}
      
      # --- Headers --- #
      if(i == length(ipeadata_series_name)){colnames(ipeadata_dataset) = c('data', ipeadata_series_name)}
      },
      
      error = function(e){stop('Uma ou mais funções não estão disponíveis ou não há conexão de internet. Verifique sua conexão ou importe as funções de um diretório local.', call. = FALSE)}
      )
  }
  
  # -------------- #    
  # --- Output --- #
  # -------------- #
  return(ipeadata_dataset)
}
