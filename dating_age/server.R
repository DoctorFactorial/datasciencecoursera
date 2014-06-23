max_partner <- function(age) (age - 7) * 2
min_partner <- function(age) age / 2 + 7

shinyServer( 
        function(input, output) {
                output$inputAge <- renderPrint({input$age})
                output$accepted_max <- renderPrint({max_partner(input$age)})
                output$accepted_min <- renderPrint({min_partner(input$age)}) 
        }
)

