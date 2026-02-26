# ========================================= #
# === DATA COLLECT FUNCTION - BACEN API === #
# ========================================= #

# --- Script by Paulo Icaro ---#



# ---------------------------- #
# --- Packages e Libraries --- #
# ---------------------------- #
#install.packages(c('httr', 'httr2', 'jsonlite'))
library(httr)                               # API Connection (Base Version): https://httr.r-lib.org/
library(httr2)                              # API Connection (Modern Version): https://httr2.r-lib.org/
library(jsonlite)                           # Convert Json data to an objetc
library(dplyr)                              # Library for data manipulation
library(svDialogs)                          # Library for displaying message boxes



# -------------------------------- #
# --- API - Gathering Function --- #
# -------------------------------- #

bacen_api = function(url, httr = TRUE){
  flag = 0
  
  # --- API Connection - Using httr --- #
  if(httr == TRUE){
    
    # -- API Connection -- # 
    api_connection = tryCatch(expr = GET(url = url),
                              error = function(e){return(NULL)})
    
    
    # --- Missed Connection - Extra Attempts --- #
    if(api_connection$status_code != 200 || is.null(api_connection)){
      while(flag < 3 & (api_connection$status_code != 200 || is.null(api_connection))){
        flag = flag + 1
        api_connection = tryCatch(expr = GET(url = url),
                                  error = function(e){message('Falha na conexão. Tentando novamente ...\n')})
        Sys.sleep(max(1, flag)) # Progressive delay
      }
      
      # --- Fail Case --- #
      if(flag == 3 && is.null(api_connection)){
        message('Falha ao conectar com a API. Verifique sua conexão de internet.')
      } else {
        message('A API pode estar temporariamente indisponível. Tente novamente mais tarde.')
      }
    }
    
    
    # --- Successfull Case --- #
    else{message('Conexão bem sucedida !\n')}
    Sys.sleep(1)
    
    
    # --- Converting Data to a Readable Format --- #
    api_connection = rawToChar(api_connection$content)              # Raw to Json
    api_connection = fromJSON(api_connection, flatten = TRUE)       # Json to Dataframe
    
    
    # --- Output --- #
    return(api_connection)
  }
  
  
  
  # --- API Connection - Using httr2 --- #
  else if (httr == FALSE) {
    
    # -- API Connection -- # 
    api_connection = tryCatch(expr = request(base_url = url) %>% req_perform(),
                              error = function(e){return(NULL)})
    
    
    # --- Missed Connection - Extra Attempts --- #
    if(api_connection$status_code != 200 || is.null(api_connection)){
      while(flag < 3 & (api_connection$status_code != 200 || is.null(api_connection))){
        flag = flag + 1
        api_connection = tryCatch(expr = request(base_url = url) %>% req_perform(),
                                  error = function(e){message('Falha na conexão. Tentando novamente ...\n')})
        Sys.sleep(max(1, flag)) # Progressive delay
      }
      
      # --- Fail Case --- #
      if(flag == 3 && is.null(api_connection)){
        message('Falha ao conectar com a API. Verifique sua conexão de internet.')
      } else {
        message('A API pode estar temporariamente indisponível. Tente novamente mais tarde.')
      }
    }
    
    
    # --- Successfull Case --- #
    else{message('Conexão bem sucedida !\n')}
    Sys.sleep(1)

    
    # --- Converting Data to a Readable Format --- #
    api_connection = rawToChar(api_connection$body)                 # Raw to JSon
    api_connection = fromJSON(api_connection, flatten = TRUE)       # Json to Dataframe
    
    
    # --- Output --- #
    return(api_connection)  
  }
  
  
  # --- Not specfified httr case --- #
  else{message('Argumento httr inválido ! Use TRUE para httr ou FALSE para htrr2.')}

}
