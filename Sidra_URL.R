# ================================ #
# === URL FUNCTION - SIDRA API === #
# ================================ #

# --- Script by Paulo Icaro --- #

# See https://apisidra.ibge.gov.br/home/ajuda for more info on how to create your query



# ------------------------------ #
# --- URL Generator Function --- #
# ------------------------------ #
sidra_url = function(table, time_interval, variables, territorial_perspective, territorial_level, kind, headers, fields, decimals){
  
  # --- Base URL --- #
  base_url = "https://apisidra.ibge.gov.br/values/t/"
  
  # --- Exclusionary Required Arguments Flag --- #
  if(!is.null(territorial_perspective) && !is.null(territorial_level)){
    stop(
      paste0(
      '\nArgumentos Visão Territorial e Nível Territorial não podem ser especificados simultaneamente. Especifique apenas um dos critérios.',
      '\nCaso esteja em dúvidas sobre como montar sua consulta acesse: https://apisidra.ibge.gov.br/home/ajuda'))
    }
  
  
  # --- Arguments --- #
  
  # Time Interval (Required)
  if(!is.null(time_interval)){time_interval = paste0('/p/', time_interval)} else {time_interval = '/p/last'}
  
  # Variables Name (Optional)
  if(!is.null(variables)){variables =  paste0('/v/', variables)} else {variables = '/v/all'}
  
  # Territorial Perspective (Optional)
  if(!is.null(territorial_perspective)){territorial_perspective = paste0('/g/', territorial_perspective)} else {territorial_perspective = NULL}
  
  # Territorial Level (Optional)
  if(is.null(territorial_level)){territorial_level = NULL} else {territorial_level = paste0('/', territorial_level)}
  
  # Header (Optional)
  if(is.null(headers)||headers == FALSE){headers = '/h/n'} else if(headers == TRUE){headers = paste0('/h/y', header)} else {message('Opção inválida para o argumento header. Insira TRUE, FALSE ou NULL.\n')}
  
  # Field (Optional)
  if(is.null(fields)){fields = NULL} else {fields = paste0('/', fields)}
  
  # Decimal Places (Optional)
  if(is.null(decimals)){decimals = NULL} else if (!decimals %in% list('s', 'm') || !decimals %in% seq_along(0:9)){decimals = paste0('/d/', decimals)} else {stop('Quantidade de casas decimais inválidas !')}
  
  
  # --- Generate URL --- #
  sidra_url = paste0(base_url, table, time_interval, variables, territorial_perspective, territorial_level, headers, fields, decimals)
  
  
  # --- Output --- #
  return(sidra_url)
}