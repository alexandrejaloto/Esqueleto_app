# chamar pacotes ----------------------------------------------------------
pacotes <- c (
  'data.table'
)

lapply(
  pacotes,
  library,
  character.only = TRUE
)

rm(pacotes)


# importar dicionário de itens --------------------------------------------

df <- fread(
  'df/df.csv',
  sep = ';',
  data.table = FALSE
)

save.image('preparando.RData')
