shinyUI( 
        pageWithSidebar(
        # Application title 
                headerPanel("Cradle Snatcher? Time to find out!"),
                
                
                sidebarPanel(
                        numericInput('age', 
                                     'How old are you?', 30, min = 12, max = 120, step = 1), 
                        submitButton('Submit')
                ), 
                mainPanel(
                        h4('Maximum acceptable age of dating partner'),
                        verbatimTextOutput("accepted_max"), 
                        h4('Minimum acceptable age of dating partner'), 
                        verbatimTextOutput("accepted_min"),
                        h4('Given you entered an age of:'), 
                        verbatimTextOutput("inputAge"),
                        
                        p('Source and further reading: 
                                http://www.psychologytoday.com/blog/meet-catch-and-keep/
                                201405/the-half-your-age-plus-seven-rule-does-it-really-work')
                ) 
        )
)