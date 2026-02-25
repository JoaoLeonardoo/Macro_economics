source('API_Dataset.R')   # Isso carrega monthly_macro_series, etc.

# Se quiser apenas a série IPCA
ipca_data <- monthly_macro_series %>% select(data, ipca)

# Salvar como JSON
library(jsonlite)
write_json(ipca_data, path = "data/ipca.json", pretty = TRUE)