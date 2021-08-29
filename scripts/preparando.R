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


# gerar o token para salvar no Dropbox ------------------------------------

# gerar o token do Dropbox
token <- drop_auth()
# salvar o token em um arquivo
saveRDS(token, "tokenfile.RDS")

rm(token)


# salvar a imagem ---------------------------------------------------------

save.image('preparando.RData')
