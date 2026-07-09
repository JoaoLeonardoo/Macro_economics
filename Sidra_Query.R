# ================================== #
# === QUERY FUNCTION - SIDRA API === #
# ================================== #

# --- Script by Paulo Icaro --- #

source("Sidra_API.R")
source("Sidra_URL.R")

library(dplyr)

sidra_query = function(query_list){
  
  for(i in seq_along(query_list)){
    message(paste0('Extraindo ', '"',  names(query_list[i]), '"\n'))
    
    tryCatch(expr = {
      
      sidra_dataset_raw = sidra_api(
        url = sidra_url(
          table = query_list[[i]][['table']],
          time_interval = query_list[[i]][['time_interval']],
          variables = query_list[[i]][['variables']],
          territorial_perspective = query_list[[i]][['territorial_perspective']],
          territorial_level = query_list[[i]][['territorial_level']],
          kind = query_list[[i]][['kind']],
          headers = query_list[[i]][['headers']],
          fields = query_list[[i]][['fields']],
          decimals = query_list[[i]][['decimals']]
        ),
        httr = FALSE
      )
      sidra_dataset_raw = sidra_dataset_raw[c(6,5)]
      
      if(i == 1){
        sidra_dataset = sidra_dataset_raw
      } else {
        sidra_dataset = left_join(x = sidra_dataset, y = sidra_dataset_raw, by = join_by('D1C' == 'D1C'))
      }
      if(i == length(query_list)){
        colnames(sidra_dataset) = c('data', names(query_list))
      }
    },
    error = function(e){
      stop('Erro na extração: ', e$message, call. = FALSE)
    })
  }
  return(sidra_dataset)
}
