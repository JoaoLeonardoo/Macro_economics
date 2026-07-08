# ============================================ #
# === DATA COLLECTION FUNCTION - SIDRA API === #
# ============================================ #

# --- Script by Paulo Icaro --- #

# ------------------------------ #
# --- Packages and Libraries --- #
# ------------------------------ #
library(httr)         # R API connection function (Base Version)
library(httr2)        # R API connection function (Modern Version)
library(jsonlite)     # Library for converting JSON data to a readable format
library(dplyr)        # Library for data manipulation


# --------------------------- #
# --- API Access Function --- #
# --------------------------- #
sidra_api = function(url, httr = TRUE){
  flag = 0
  
  # --- API Connection Using httr --- #
  if(httr == TRUE){
    
    # --- API Connection --- #
    api_connection = tryCatch(expr = GET(url = url, add_headers(Accept = "application/json")), 
                              error = function(e){return(NULL)})
    
    # --- Connection Flags --- #
    if(api_connection$status_code != 200 || is.null(api_connection)){
      while(flag < 3 & (api_connection$status_code != 200 || is.null(api_connection))){
        flag = flag + 1
        api_connection = tryCatch(expr = GET(url = url), 
                                  error = function(e){message("Falha na conexão. Tentando novamente ...\n")})
        Sys.sleep(max(1, flag))           # Progressive delay
        }
      
      # --- Fail Case --- #
      if(flag == 3 && is.null(api_connection)){
        message('Falha ao conectar com a API. A URL pode ter sido especificada incorretamente ou a conexão com a API falhou.')
      } else { 
        message('A API pode estar indisponível no momento. Tente novamente mais tarde.')}
    }
    
    # --- Successfull Case --- #
    else{message('Conexão bem sucedida !\n')}
    Sys.sleep(1)

    # --- Converting Data to a Readable Format --- #
    api_connection = rawToChar(api_connection$content)             
    api_connection = fromJSON(api_connection, flatten = TRUE)
    
    # --- Output --- #
    return(api_connection)
  }
  
  
  # --- API Connection Using httr2 --- #
  else if (httr == FALSE) {
    
    # --- API Connection --- #
    api_connection = tryCatch(expr = request(base_url = url) %>% req_headers(Accept = 'application/json') %>% req_perform(),
                              error = function(e){return(NULL)})
    
    # --- Connection Flags --- #
    if(api_connection$status_code != 200 || is.null(api_connection)){
      while(flag < 3 & (api_connection$status_code != 200 || is.null(api_connection))){
        flag = flag + 1
        api_connection = tryCatch(expr = request(base_url = url) %>% req_perform(), 
                                  error = function(e){message("Falha na conexão. Tentando novamente ...\n")})
        Sys.sleep(max(1, flag))           # Progressive delay
      }
      
      # --- Fail Case --- #
      if(flag == 3 && is.null(api_connection)){
        message('Falha ao conectar com a API. A URL pode ter sido especificada incorretamente ou a conexão com a API falhou.')
      } else { 
        message('A API pode estar indisponível no momento. Tente novamente mais tarde.')}
    }
    
    # --- Successfull Case --- #
    else{message('Conexão bem sucedida !\n')}
    Sys.sleep(1)

    # --- Converting Data to a Readable Format --- #
    api_connection = rawToChar(api_connection$body)
    api_connection = fromJSON(api_connection, flatten = TRUE)
    
    # --- Output --- #
    return(api_connection)
  }
  
  # --- Not specified httr case --- #
  else{message('Argumento httr inválido ! Use TRUE para httr ou FALSE para httr2.')}
}