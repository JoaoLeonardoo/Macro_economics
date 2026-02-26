# =================================== #
# === URL FUNCTION - IPEADATA API === #
# =================================== #

# --- Script by Paulo Icaro --- #


# ------------------------------ #
# --- URL Generator Function --- #
# ------------------------------ #
ipeadata_url = function(series_cod){
  base_url = "http://ipeadata.gov.br/api/odata4/ValoresSerie(SERCODIGO='"
  ipeadata_url = paste0(base_url, series_cod, "')")
  return(ipeadata_url)
}