#
# This is the server logic of a Shiny web application. 
# monkey guessnext
#
#

library(shiny)

library(tidyverse)

# read in the words data from the blogs and news
f_dir <- "https://raw.githubusercontent.com/jcdoesds/monkeysnextword/main/monkeysnextwordapp/data/"
top_words <- read_csv(paste0(f_dir, "top_words.csv")) # three words with n
# these are all structured moosh out n
words2 <- read_csv(paste0(f_dir, "words2.csv"))
words3 <- read_csv(paste0(f_dir, "words3.csv"))
words4 <- read_csv(paste0(f_dir, "words4.csv"))
words5 <- read_csv(paste0(f_dir, "words5.csv"))
words6 <- read_csv(paste0(f_dir, "words6.csv"))

num_words_input <- 0
num_words_used <- 0
num_matches <- 0

cleanText <- function(this_text) {
  this_text <- tolower(this_text) # make all lower case
  # we will be removing punctuation, but maybe handle contractions first?
  this_text <- gsub("'s", "", this_text) #not sure how to treat 's
  this_text <- gsub("won't", "will not", this_text)
  this_text <- gsub("can't", "can not", this_text)
  this_text <- gsub("n't", " not", this_text) #special cases handled first
  this_text <- gsub("'ll", " will", this_text)
  this_text <- gsub("'re", " are", this_text)
  this_text <- gsub("'ve", " have", this_text)
  this_text <- gsub("'m", " am", this_text)
  this_text <- gsub("'d", " would", this_text)
  this_text <- gsub("http[^[:space:]]*", "", this_text) # get rid of urls
  this_text <- gsub("@[^\\s]+", "", this_text) # handle twitter names
  this_text <- gsub("[^[:alpha:][:space:]]*", "", this_text) # get rid of special char
  this_text <- gsub("[[:punct:]]", "", this_text) # get rid of all other punctuation
  return(this_text)
}

returnWordsWithOdds <- function(df, tomatch) {
  # take the df, see if moosh has a match
  # moosh is a combination of all but the last word, which is out
  
  # will return a df that is empty or has up to ten
  # words with odds
  
  df <- df %>% filter(moosh == tomatch) 
  
 num_matches <<- nrow(df)
  
  df %>%
    mutate(odds = n/sum(n)) %>% 
    top_n(10,n) %>%
    select(out, odds)
  
}

getNextLikelyWords <- function(input_words, grams = 4){
  num <- length(input_words)
  snum <- num - grams + 2 # ensures only enough words
  ## PREPARE THE GLOBALS
  num_words_input <<- num
  num_words_used <<- grams - 1
  ## END OF GLOBALS
  tomatch <- str_flatten(input_words[snum:num], "_")# smoosh together the grams - 1 last words of input
  # each df is word1-wordn, n, proportion
  # based on number of grams, pick data
  # if match, filter to matches, calc odds
  matchdf <- get(paste0("words",grams)) # words2, words3, wordsn
  next_words <- returnWordsWithOdds(matchdf, tomatch)
  #print("this time matched")
  #print(next_words)
  if(nrow(next_words) == 0 & grams > 2){
    # we don't have any hits, try again with fewer grams
    getNextLikelyWords(input_words, grams = grams - 1)
  } else {
    # we have some hit
    return(next_words)
  }
}

getNextLikelyFromInput <- function(input){
  if(is.na(input) || input == "" || input == " "){
    return(top_words) # get out
  } else {
    input <- cleanText(input)  # THIS IS WHERE WE CLEAN IT TO MATCH!!!
    # Find word count, separate words, lower case
    input_count <- str_count(input, boundary("word"))
    input_words <- unlist(str_split(input, boundary("word")))
    input_words <- tolower(input_words)

    
    result <- getNextLikelyWords(input_words, min(input_count + 1, 6)) # max 6
    if(is.null(result) | length(result) == 0 | nrow(result) == 0) {
      result <- top_words
      num_words_used <<- 0 # it did not match on any of their words
      #print("no result: using top words")
    } else{
      if(nrow(result) < 3){
        #print(nrow(result))
        #print("not enough result: adding top words")
        # use filter to make sure only give a result one time
        result <- bind_rows(result, filter(top_words, !out %in% result$out)) %>%
          ungroup() %>%
          mutate(odds = odds/sum(odds)) %>% 
          top_n(10,odds)
        
        #print(result)
      }
    }
    return(result)
  }
  
}


# Define server logic required to return words
shinyServer(function(input, output) {
  
  words_react <- reactive({
    if(is.null(input$user_entry)){
      getNextLikelyFromInput("")
    } else {
      getNextLikelyFromInput(input$user_entry)
    }
  })
  
   output$likely_words <- renderText({
     paste(top_words$word)
   })
   
   output$likely1 <- renderText({
     w <- words_react()
     if(grepl("monkey", input$user_entry)){
       "\u2764"
     } else { # only go here if they didn't say monkey}
     if(nrow(w) > 0){
       if(num_matches == 0){"???"} else { w$out[1] }
     }
     else ("")
     }
   })
   
   output$likely2 <- renderText({
     w <- words_react()
     if(grepl("monkey", input$user_entry)){
       "\u2764 \u2764"
     } else { # only go here if they didn't say monkey}
     if(nrow(w) > 1){
       if(num_matches == 0){"???"} else { w$out[2] }
     }
     else ("")
     }
   })
   output$likely3 <- renderText({
     w <- words_react()
     if(grepl("monkey", input$user_entry)){
       "\u2764 \u2764 \u2764"
     } else { # only go here if they didn't say monkey}
       if(nrow(w) > 2){
         if(num_matches == 0){"???"} else { w$out[3] }
       }
       else ("")
     }
   })
   
   output$easter_egg <- renderText({
     w <- words_react()
     if(grepl("monkey", input$user_entry)){
       "\u2764   You typed the magic word, 'M-O-N-K-E-Y' and made the monkeys so happy!   \u2764"
     } else { # only go here if they didn't say monkey}
       ""
     }
   })
   
   output$num_matches <- renderText({
     w <- words_react()
     if(num_matches == 0){
       ""
     } else { 
       o <- paste("There were", format(num_matches,big.mark=",", trim=TRUE), "matches.")   
       if(num_matches < 3){
         o <- paste(o, "Since there were fewer than three matches to your typing, 
                    the monkeys have additionally given a few examples of 
                    the most common single words. These words may not make much
                    sense in your context, but hey, they are only monkeys.")
       }
       o
     }
   })
   
   output$num_words_input <- renderText({
     w <- words_react()
     if(num_words_input == 0){
       ""
     } else { 
       paste("Monkeys see that you input", 
             format(num_words_input,big.mark=",", trim=TRUE), "words.")   
     }
   })
   
   output$num_words_used <- renderText({
     w <- words_react()
     if(num_words_input == 0) {
       ""
     } else {
       if(num_matches == 0){
         "They did not find any matches, and are only showing you the most likely words."
       } else { 
         paste("They used",
               format(num_words_used,big.mark=",", trim=TRUE),
               "of them to determine your next likely words.")
       }}
   })
   
   

   
   output$likely_graph <- renderPlot({
     w <- words_react()
     if(num_words_input == 0) {
       # we don't want a graph here
     } else {
     w$out <- forcats::fct_inorder(w$out) %>% forcats::fct_rev() #keep colors right
     # get only the clors we need 
     # use the min 10 function to ensure that don't have too many if issue w 
     mcolors <- tail(c(rep("grey50",7),"#ea526f","#ff8a5b","#f0F2A6"), min(10,nrow(w)))
  
     ggplot(head(w,10), aes(x = out, y = odds, fill = out, color = out)) +
       geom_col()+
       geom_text(aes(label = sprintf("%1.1f%%", 100*odds)), 
                 hjust = 0, 
                 nudge_y = 0.001, fontface = "bold",
                 size = rel(5)) +
       scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                          limits = c(0,w$odds[1]*1.25)) +
       scale_color_manual(values = mcolors) +
       scale_fill_manual(values = mcolors) +
       labs(x = "", y="", title = "Odds It Is Your Word") +
       coord_flip() +
       theme_minimal() +
       theme(
         legend.position = "none",
         plot.title = element_text(size = rel(2), color = "white"),
         axis.text.y= element_text(size=rel(3)),
         axis.text.x=element_blank(),
         axis.ticks=element_blank(),
         panel.background = element_rect(fill = "transparent",
                                         colour = NA_character_), # necessary to avoid drawing panel outline
         panel.grid.major = element_blank(), # get rid of major grid
         panel.grid.minor = element_blank(), # get rid of minor grid
         plot.background = element_rect(fill = "transparent",
                                        colour = NA_character_), # necessary to avoid drawing plot outline
         legend.background = element_rect(fill = "transparent"),
         legend.box.background = element_rect(fill = "transparent"),
         legend.key = element_rect(fill = "transparent")
       )
     } # end of if something statement
   }, bg="transparent")
   
   output$your_words <- renderText({
     paste("You said",input$user_entry)
   })

    

})
