# ========================================= #
# === MACROECONOMIC VARIABLES - DATASET === #
# ========================================= #

# --- Script by Diego Lima and Paulo Icaro --- #


# ====================== #
# === 1. Series Info === #
# ====================== #

# ------------------------- #
# --- Monthly Databases --- #
# ------------------------- #

# PIB Nominal (R$ Milhões) 
# Exportações FOB (R$ Milhões)
# Importações FOB (R$ Milhões)
# Taxa de Câmbio Comercial (R$/US$) 
# Índice de Preços (IPCA) 
# Taxa de Juros Nominal (SELIC)
# Utilização da Capacidade Instalada (Indústria)
# Superávit Primáriio do Governo Consolidado (R$ Milhões)

# -------------------------- #
# --- Quartely Databases --- #
# -------------------------- #




# ======================================= #
# === 1. Source Scripts and Libraries === #
# ======================================= #
source("Bacen_Query.R")
source("Ipeadata_Query.R")
source("Sidra_Query.R")
source("Variables_Frequency_Transforming.R")




# ========================== #
# === 2. Data Extraction === #
# ========================== #


# ------------------- #
# --- 2.1 Monthly --- #
# ------------------- #

# --- Previous Info --- #
cod_ipeadata_monthly_series = c('BM12_PIB12', 'FUNCEX12_XVT12', 'SECEX12_MVTOT12', 'BM12_ERV12', 'PRECOS12_IPCA12', 'PAN12_TJOVER12')
name_ipeadata_monthly_series = c('pib', 'export', 'import', 'tx_cambio_venda', 'ipca', 'tx_jur')

cod_bacen_monthly_series = c('28561', '4649', '28763', '4449', '11428', '11752')
name_bacen_monthly_series = c('uci_dessaz', 'res_prim', 'empregos', 'ipca_adm', 'inf_livre', 'tx_cambio_real')

sidra_query_list = vector(mode = 'list')
sidra_query_list[['ipca_%']] = list(table = '1737', time_interval = '201001-202512', variables = '2263', territorial_level = 'n1/all', headers = FALSE)

# --- Extraction --- #
ipeadata_monthly_dataset = ipeadata_query(cod_ipeadata_monthly_series, name_ipeadata_monthly_series, as.character(2010:2025))
ipeadata_monthly_dataset = ipeadata_monthly_dataset %>% mutate('ipca_%' = (ipca/lag(ipca) - 1)*100)
bacen_monthly_dataset = bacen_query(cod_bacen_monthly_series, name_bacen_monthly_series, '01/01/2010', '31/12/2025')
bacen_monthly_dataset[c(-1)] = lapply(X = bacen_monthly_dataset[c(-1)], FUN = as.numeric)
sidra_monthly_dataset = sidra_query(sidra_query_list, TRUE)

# --- Date Adjustment --- #
ipeadata_monthly_dataset = ipeadata_monthly_dataset %>% mutate(data = as.Date(data))
bacen_monthly_dataset = bacen_monthly_dataset %>% mutate(data = as.Date(data, tryFormats = c('%d/%m/%Y')))
sidra_monthly_dataset = sidra_monthly_dataset %>% mutate(data = as.Date(paste0(substr(data, 1, 4), '-', substr(data, 5, 6), '-01')))


# -------------------- #
# --- 2.2 Quartely --- #
# -------------------- #

# --- Previous Info --- #
cod_ipeadata_quartely_series = c('SCN104_CFPPN104', 'SCN104_CFGGN104', 'SCN104_FBKFN104')
name_ipeadata_quartely_series = c('cons_familias', 'cons_governo', 'fbcf')

cod_bacen_quartely_series = c('1344')
name_bacen_quartely_series = c('uci')

sidra_query_list = vector(mode = 'list')
sidra_query_list[['pib']] = list(table = '2072', time_interval = '201001-202504', variables = '933', territorial_level = 'n1/all', headers = FALSE)
sidra_query_list[['sal_medio']] = list(table = '6470', time_interval = '201001-202504', variables = '5934', territorial_level = 'n1/all', headers = FALSE)


# --- Extraction --- #
ipeadata_quartely_dataset = ipeadata_query(cod_ipeadata_quartely_series, name_ipeadata_quartely_series, as.character(2010:2025))
sidra_quartely_dataset = sidra_query(sidra_query_list, TRUE)
#bacen_quartely_dataset = bacen_query(cod_bacen_quartely_series, name_bacen_quartely_series, '01/01/2010', '31/12/2025')


# --- Date Adjustment --- #
ipeadata_quartely_dataset = ipeadata_quartely_dataset %>% mutate(data = as.Date(data))
sidra_quartely_dataset = sidra_quartely_dataset %>% mutate(data = paste0(substr(data, 1, 4), '_Q', substr(data, 6, 6)))
#bacen_quartely_dataset = bacen_quartely_dataset %>% mutate(data = as.Date(data, tryFormats = c('%d/%m/%Y')))


# ------------------ #
# --- 2.3 Yearly --- #
# ------------------ #

# --- Previous Info --- #
cod_bacen_yearly_series =  c('13521')
name_bacen_yearly_series = c('meta_inf')

# --- Extraction --- #
bacen_yearly_dataset = bacen_query(cod_bacen_yearly_series, name_bacen_yearly_series, '01/01/2010', '31/12/2025')





# ============================================== #
# === 3. Data Frequency Cumulative Transform === #
# ============================================== #

# --- Monthly Ipeadata Database --- #
db_transform_ipeadata_quartely_sum = cumulative_transform('sum', 'quartely', ipeadata_monthly_dataset[c(1:4)], change_date = TRUE)
db_transform_ipeadata_quartely_cumrate = cumulative_transform('cumulative_rate', 'quartely', ipeadata_monthly_dataset[c(1,8)], change_date = TRUE)
db_transform_ipeadata_quartely_mean = cumulative_transform('mean', 'quartely', ipeadata_monthly_dataset[c(1,5)], change_date = TRUE)
db_transform_ipeadata_quartely_none = cumulative_transform('none', 'quartely', ipeadata_quartely_dataset, change_date = TRUE)


# --- Monthly Bacen Database --- #
db_transform_bacen_quartely_end = cumulative_transform('final_period', 'quartely', bacen_monthly_dataset[c(1,4)], change_date = TRUE)
db_transform_bacen_quartely_cumrate = cumulative_transform('cumulative_rate', 'quartely', bacen_monthly_dataset[c(1,5,6)], change_date = TRUE)
db_transform_bacen_quartely_mean = cumulative_transform('mean', 'quartely', bacen_monthly_dataset[c(1,7)], change_date = TRUE)

# --- Monthly Sidra Database --- #
db_transform_sidra_quartely_end = cumulative_transform('final_period', 'quartely', sidra_monthly_dataset[c(1,2)], change_date = TRUE)





# ==================================== #
# === 4. Combining Quartely Series === #
# ==================================== #

# --- Ipeadata --- #
db_transform_ipeadata_quartely = left_join(x = db_transform_ipeadata_quartely_sum, y = db_transform_ipeadata_quartely_cumrate, by = 'data')
db_transform_ipeadata_quartely = left_join(x = db_transform_ipeadata_quartely, y = db_transform_ipeadata_quartely_mean, by = 'data')
db_transform_ipeadata_quartely = left_join(x = db_transform_ipeadata_quartely, y = db_transform_ipeadata_quartely_none, by = 'data')


# --- Bacen --- #
db_transform_bacen_quartely = left_join(x = db_transform_bacen_quartely_end, y = db_transform_bacen_quartely_cumrate, by = 'data')
db_transform_bacen_quartely = left_join(x = db_transform_bacen_quartely, y = db_transform_bacen_quartely_mean, by = 'data')

# --- Sidra --- #
db_transform_sidra_quartely = left_join(x = db_transform_sidra_quartely_end, y = sidra_quartely_dataset, by = 'data')

# --- Final Dataset --- #
final_dataset = left_join(x = db_transform_ipeadata_quartely, y = db_transform_bacen_quartely, by = 'data')
final_dataset = left_join(x = final_dataset, y = db_transform_sidra_quartely, by = 'data')





# =================== #
# === 5. Cleasing === #
# =================== #
patterns = c('^cod', '^name', '^ipeadata', '^bacen', '^db_transform', '^sidra')
for(i in seq_along(patterns)){
  rm(list = ls(pattern = patterns[i]))
}
rm(patterns, i, cumulative_transform)
