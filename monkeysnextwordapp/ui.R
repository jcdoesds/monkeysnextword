#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

mystyle <- '
  @import url("https://fonts.googleapis.com/css2?family=Rubik+Marker+Hatch&display=swap");
  .myclass { 
  background-color: #25CED1;
  color: white;
  }

  .mytitle{
  text-shadow: 2px 2px #666a86;
  text-align: center;
  padding: 30px;
  font-size: 3em;
  font-family: "Rubik Marker Hatch", sans-serif;
  font-weight: bold;
  }
  .mymain {
  background-color:  #25CED1;
  color: black;
  text-align:center;
  }
  .myintrotext{
  color: #383838;
  text-align: left;
  padding: 0px 30px;
  
  }
  .mydesc{
  color: #383838;
  text-align: left;
  padding: 50px 30px 0px 30px;
  }
  .myfooter { 
  background-color: #666a86;
  color: #E6E6FA;
  }
  .btn {
  background-color: #666a86;
  color: #E6E6FA;
  font-size: 2em;
  padding: 20px;
  }
  .myform {
  
  padding: 20px;
  color:gray;
  text-align:center;
  width: "100%";
  }
 #user_entry.form-control{
 font-size: 2em;
 color:gray;
 padding: 20px;
 width: "100%";
 }
  .monkeytext {
    margin: 250px 0px 5px 0px;  
  }
  
  
  .monkey1{
   background-color: #f0F2A6;
   background-image: url("img/monkey1.png");
   background-size:     cover;                  
    background-repeat:   no-repeat;
    background-position: center center;  
   height:300px;
   text-align:center;
  }
  .monkey2{
   background-color: #ff8a5b;
   background-image: url("img/monkey2.png");
   background-size:     cover;                  
    background-repeat:   no-repeat;
    background-position: center center;  
   color: #E6E6FA;
   height:300px;
   text-align:center;
  }
  .monkey3{
   background-color: #ea526f;
   background-image: url("img/monkey3.png");
   background-size:     cover;                  
    background-repeat:   no-repeat;
    background-position: center center;  
   color: white;
   height:300px;
    text-align:center;
  }
  .monkeysum{
  height:300px;
  }
'


shinyUI(
  fluidPage(tags$head(tags$style(mystyle)),
            class = "myclass",
    
    title = "Monkeys Guess Your Next Word",
    
    fluidRow(column(12, class = "mytitle",
             
        h1("Monkeys Guess The Next Word")
      )
    ),
    
    
    hr(),
    
    fluidRow(column(12, class="mymain col-md-6 col-lg-6",
            fluidRow(h2("Not sure what to type?")),
            fluidRow(class="myintrotext",
                     h4("We found some monkeys that can show you likely next words."),
                     h4("Well, actually, they are trained to show you the most likely words from a list that an algorithm finds based on what you type."),
                     h4("Go a head and try typing something in the box. Then hit 'Guess My Word'")
                     ) ,
            br(),
            fluidRow( class="myform",
              column(6,
              textInput("user_entry","Your Words")
              ),
              column(6, 
              submitButton(text = "Guess My Word")
              )
              ),
            br(),
            fluidRow(column(12, class="mydesc",
               p(textOutput("num_words_input", inline=T),
                 textOutput("num_words_used", inline=T),
                 textOutput("num_matches", inline=T),
                 textOutput("easter_egg", inline=T))
              ))
            ), # end of left side
            column(12, class="mymonkeys col-md-6 col-lg-6",
               fluidRow(
                   column(6, class="monkey1",
                          
                          h1(class = "monkeytext",
                             textOutput("likely1"))
                   ),
                   column(6, class="monkey2",
                          h1(class = "monkeytext",
                             textOutput("likely2"))
                   )
                   ),
               fluidRow(
                 column(6, class="monkey3",
                            h1(class = "monkeytext",
                                  textOutput("likely3"))
                            
                        
                 ),
                 column(6, class="monkeysum",
                       plotOutput("likely_graph", width = "100%", height = "100%")
                 )
               ),
            )
    
      
    ),

    

    
    hr(),
    
    fluidRow(align = "center", class="myfooter",
      h2("About This App"),
      h4("The goal of this app is to guess the next word based on a 
         backoff model tuned using text from blogs and news. To keep the app 
         size small, it is a very simple model. The backoff model starts with 
         consideration for up to 5 input words. If there are more than 5 words
         input, it starts with the last words. If there is no match based on the 
         5 words input, it looks at the next smaller set of words. If there is 
         still no match looking at only the last word, it gives the most common words.
         In testing, the model can be improved slightly with topic and sentiment 
         analysis. So, if the input words include 'animals', it would first look for
         matching words in a subset of the data with the topic 'animals', and if
         the input words were 'negative' or 'positive' in tone, it would further
         look for similar sentiment in the training data."),
      br(),
      h2("App"),
      h4("The app is written in RShiny. 
         Code by jcdoesds in RStudio. 
         Art by jcdoesds in ProCreate for iPad.
         ~ Did you find the Easter Egg ~"),
      br(),
      h2("Data"),
      h4("The data are based on a sample of 30% of all of the lines of data provided 
         in the JHU Data Science Capstone for the blogs and news in english. From the
         sample, lines were cleaned and tokenized into ngrams of up to six words. To make 
         this shiny app load more quickly, the top ten single words in the sample, and
         data frames containing the ngrams were saved as .csv and used here rather than
         build them directly from the source for this app. Data can be found in the github directory"),
      br(),
      h2("Author"),
      h4("jcdoesds loves data science, exploration, analysis, and visualization.")
      )
    
  )
)

