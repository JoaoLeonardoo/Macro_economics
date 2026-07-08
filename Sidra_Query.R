# ================================== #
# === QUERY FUNCTION - SIDRA API === #
# ================================== #

# --- Script by Paulo Icaro --- #

# ============= #
# === Query === #
# ============= #
sidra_query = function(query_list, source_github = TRUE){
  
  # ---------------------------------- #
  # --- Source Auxiliary Functions --- #
  # ---------------------------------- #
  if(source_github == TRUE){
    tryCatch(expr = suppressWarnings(source('https://raw.githubusercontent.com/paulo-icaro/Sidra_API/refs/heads/main/Sidra_API.R')),
             error = function(e){message('Não foi possível acessar a função Sidra_API via github')})
    Sys.sleep(1.5)
    
    tryCatch(expr = suppressWarnings(source('https://raw.githubusercontent.com/paulo-icaro/Sidra_API/refs/heads/main/Sidra_URL.R')),
      error = function(e){message('Não foi possível acessar a função Sidra_URL via github')})
    Sys.sleep(1.5)
    
  } else if(source_github == FALSE){
    tryCatch(expr = suppressWarnings(source('Sidra_API.R')),
             error = function(e){message('Não foi possível acessar a função Sidra_API localmente')})
    Sys.sleep(1.5)
    
    tryCatch(expr = suppressWarnings(source('Sidra_URL.R')),
      error = function(e){message('Não foi possível acessar a função Sidra_URL localmente')})
    Sys.sleep(1.5)
  
  } else{
    message('Caso o erro persista, importe as funções Ipeadata_API e Ipeadata_URL de um diretório local e execute este script novamente.\n')
  }
  
  Sys.sleep(1.5)
  
  
  # ----------------------- #
  # --- Data Extraction --- #
  # ----------------------- #
  for(i in seq_along(query_list)){
    message(paste0('Extraindo ', '"',  names(query_list[i]), '"\n'))
    
    tryCatch(expr = {
      
      # --- Extraction --- #
      sidra_dataset_raw = sidra_api(url = sidra_url(table = query_list[[i]][['table']], time_interval = query_list[[i]][['time_interval']], variables = query_list[[i]][['variables']], territorial_perspective = query_list[[i]][['territorial_perspective']], territorial_level = query_list[[i]][['territorial_level']], kind = query_list[[i]][['kind']], headers = query_list[[i]][['headers']], fields = query_list[[i]][['fields']], decimals = query_list[[i]][['decimals']]), httr =  FALSE)
      sidra_dataset_raw = sidra_dataset_raw[c(6,5)]
      
      # --- Grouping Columns --- #
      if(i == 1){sidra_dataset = sidra_dataset_raw}
      else{sidra_dataset = left_join(x = sidra_dataset, y = sidra_dataset_raw, by = join_by('D1C' == 'D1C'))}
      
      # --- Headers --- #
      if(i == length(query_list)){colnames(sidra_dataset) = c('data', names(query_list))}
      },
      
      error = function(e){stop('Uma ou mais variáveis não estão disponíveis ou a conexão com a API está falhando. Verifique se o código da série e outros parâmetros foram devidamente especificados. Verifique também sua conexão.', call. = FALSE)}
    )
  }
  
  # -------------- #
  # --- Output --- #
  # -------------- #
  return(sidra_dataset)
}