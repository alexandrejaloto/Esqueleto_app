
# 1. PRÉ APLICAÇÃO --------------------------------------------------------


# chamar pacotes ----------------------------------------------------------

pacotes <- c (
  'shiny',
  'shinyjs',
  'ggplot2'
)

lapply(
  pacotes,
  library,
  character.only = TRUE
)

rm(pacotes)

# caso seja no shinyapps.io, precisa chamar pelo library
# library (shinyjs)
# library (shiny)
# library (ggplot2)


# importar objetos com os itens -------------------------------------------


load('preparando.RData')

df <- rbind(df, 1)

# 2. FUNÇÃO SERVER --------------------------------------------------------

shinyServer(function(input, output, session){

  # informações iniciais ----------------------------------------------------

  # itens aplicados
  aplicados <- reactiveVal(c())

  # respostas dos itens
  resp_itens <- reactiveValues(resp = rep(NA, nrow(df)))

  # tempos de resposta
  tempo_resposta <- reactiveVal(c())

  shinyjs::logjs('Carrega informações iniciais')

  # selecionar item a ser apresentado --------------------------------------------------

  it_select <- reactive({
    length(aplicados())+1
  })

  shinyjs::logjs('Selecionar informações iniciais')

  # atualizar o botão das respostas -----------------------------------------

  shinyjs::logjs(paste0('item', 'it_select'))

  shiny::observe({

    # primeiro, criar lista com quantidade de categorias de resposta
    choices <- list(
      'A' = '1',
      'B' = '2',
      'C' = '3',
      'D' = '4'
    )

    # nomear as categorias. o nome é o enunciado
    names (choices) <- c(
      df$cat1[it_select()],
      df$cat2[it_select()],
      df$cat3[it_select()],
      df$cat4[it_select()]
    )


    shinyjs::logjs('Selecionar as choices pro radiobuttoninput')

    # atualizar as opções de resposta. o segundo argumento é o input
    # das respostas
    shiny::updateRadioButtons(
      session,
      'it',
      '',
      choices = choices,
      selected = character(0)
    )

  })
  shinyjs::logjs('UpdateRadioButtons')

  # renderizar enunciado do item --------------------------------------------

  shinyjs::logjs(nrow(df))

  output$enunc <- shiny::renderText({

    # caso a aplicação não tenha chegado ao final
    if (length(aplicados()) < (nrow(df)-1))
    {
      tela <- df$enunciado[it_select()]

      # caso a aplicação tenha chegado ao final
    } else {
      tela <- c ('Obrigado pela participação')
    }

    tela
  })

  # tempo inicial da resposta do item
  tempo_inicial <- Sys.time()

  shinyjs::logjs(length(aplicados))
  shinyjs::logjs('it_select')
  shinyjs::logjs(it_select)

  shinyjs::logjs('Renderiza enunciado do item')
  # aparecer o botão quando escolher resposta -------------------------------

  observe({
    # verificar se o campo tem um valor
    mandatoryFilled <-
      vapply('it',
             function(x) {
               !is.null(input[[x]]) && input[[x]] != ""
             },
             logical(1))
    mandatoryFilled <- all(mandatoryFilled)

    # habilitar/desabilitar o botão
    shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
  })

  #   # shinyjs::logjs(input$it)
  #   #
  # shiny::observe({
  #   if (input$it == character(0))
  #     {
  #     shinyjs::hide('submit')
  #   } else {
  #     shinyjs::show('submit')
  #   }
  #
  # })
  shinyjs::logjs('Desabilita botão em caso de resposta vazia')


  # botão para submeter resposta --------------------------------------------


  shiny::observeEvent(input$submit, {


    # resposta do item
    resposta <- shiny::isolate ({
      input$it
    })

    shinyjs::logjs('Recebe input do radio')

    # atualizar o padrão de resposta
    resp_itens$resp[it_select()] <- resposta
    shinyjs::logjs('Atualiza padrão de resposta')

    # atualizar os itens aplicados
    aplicados(c(aplicados(), it_select()))
    shinyjs::logjs('Atualiza itens aplicados')

    # atualizar objeto com tempos de resposta
    tempo_resposta(c(tempo_resposta(), Sys.time() - tempo_inicial))
    shinyjs::logjs('Atualiza tempos de respostas')

    shinyjs::logjs(tempo_resposta())
    shinyjs::logjs(df$item)

    # finalizar a aplicação ---------------------------------------------------

    # objeto para finalizar a aplicação
    fim <- length(aplicados()) == (nrow(df)-1)

    # para sumir o botão
    if (fim) {
      # # Salva as respostas
      # con <- mongo(
      #   'colaborador', # mudar aqui
      #   url = Sys.getenv("URL_MONGO")
      # )
      #
      # salvar <- toJSON(
      #   setNames(
      #     as.numeric(resp_itens$resp),
      #     df$item[1:10] # mudar aqui
      #   )
      # )
      # con$insert(salvar)
      # rm(con)
      # gc()

      shinyjs::toggle('submit')

      shinyjs::toggle('it')

      shinyjs::show('grafico_escore')

      shinyjs::show('tab_tempo_resposta')


    }
  })

  # Finaliza a aplicação

  # 3. RELATÓRIO FINAL  ----------------------------------------------------------


  # pltoar gráfico do escore ----------------------------------------------------------

  output$grafico_escore <- shiny::renderPlot({

    # objeto com os escores
    escore <- data.frame(
      escore = c(
        sum (as.numeric(resp_itens$resp[which(df$fator == 'F1')])),
        sum (as.numeric(resp_itens$resp[which(df$fator == 'F2')])),
        sum (as.numeric(resp_itens$resp[which(df$fator == 'F3')])),
        sum (as.numeric(resp_itens$resp[which(df$fator == 'F4')]))
      ),
      fator = paste0('F', 1:4)
    )

    # gráfico em si
    df_grafico <- ggplot(escore, aes(x = fator, y = escore, fill = fator)) +
      geom_bar(stat = 'identity')
    df_grafico

  })

  shinyjs::logjs('Plotar o gráfico')

# plotar tabela com tempo de resposta -------------------------------------

output$tab_tempo_resposta <- shiny::renderTable({

  tab_tempo_resposta <- data.frame(
    Item = df$item[-nrow(df)],
    Tempo = tempo_resposta()
  )

  tab_tempo_resposta
})

  shinyjs::logjs('tab_tempo_resposta')

})
