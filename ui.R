shiny::shinyUI(

  shiny::fluidPage(
    shiny::fluidRow(
      # usar o pacote para ocultar objetos
      shinyjs::useShinyjs(),

      shinyjs::hidden(shiny::plotOutput('grafico_escore', width = '50%')),

      shinyjs::hidden(shiny::tableOutput('tab_tempo_resposta')),

      shiny::textOutput('enunc'),

      shiny::radioButtons(
        'it',
        '',
        LETTERS[1:4],
        selected = character(0)
      ),
      shiny::actionButton('submit', 'Responder', class = 'btn-primary')
    )
  )
)
