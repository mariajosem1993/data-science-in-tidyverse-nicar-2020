#'---
#'title: "Transforming Data, Part B - NICAR 2019"
#'author: "Aaron Kessler"
#'date: "(March 9, 2019 - NICAR Conference, Newport Beach, CA)"
#'output: github_document
#'---


#'load the packages we'll need
library(tidyverse) # we'll use the stringr package from tidyverse
library(lubridate)
library(janitor)

  
#'load in previous data of prez candidate campaign trips - we'll get back to this in a minute
events <- readRDS("events_saved.rds")

#'### String Functions - Using the `stringr` package

#' Each function starts with `str_`
#'
#'* `str_length()`  figure out length of string 
#'* `str_c()`  combine strings 
#'* `str_sub()`     substitute string 
#'* `str_detect()`     detect string in string 
#'* `str_match()`     does string match 
#'* `str_count()`     count strings 
#'* `str_split()`    split strings 
#'* `str_to_upper()`    convert string to upper case 
#'* `str_to_lower()`    convert string to lower case 
#'* `str_to_title()`    convert the first letter of each word to upper case 
#'* `str_trim()`    eliminate trailing white space 

 
#'## Let's load this data in
messy <- tibble(name=c("Bill Smith", "jane doe", "John Forest-William"),
      email=c("bsmith@themail.com", "jdoe@themail.com", "jfwilliams$geemail.com"),
      income=c("$90,000", "$140,000", "E8500"),
      phone=c("(203) 847-334", "207-999-1122", "2128487345"),
      activites=c("fishing, sailing, planting flowers", "reading, raising flowers, biking", "hiking, fishing"))

messy

#' What problems do you see?  
#' *Tasks*
#' 
#' 1. Split name into First name and Last name
#' 2. Convert names to title case
#' 3. Create a new variable identifying bad email addresses
#' 4. Convert income to a new number in US dollars
#' 5. Create a new variable containing area code
#' 6. Creating a new variable counting how many activities each person is engaged in
#' 7. Break activities into a set of useful dummy codes  
#'     

#'**String length**  
#' `str_length(string)` counts the number of characters in each element of a string or character vector.

x <- c("Bill", "Bob", "William")
str_length(x)


#' **Combine strings**  
#' `str_c(strings, sep="")`  
#' It's like the equivalent of =concatenate in Excel.  
#' But there are a couple of quirks

data <- tibble(place=c("HQ", "HQ", "HQ"),
              id=c("A", "B", "C"),
              number=c("001", "002", "003"))

data

#' We can add a string to each value in the *number* column this way:
data %>% 
  mutate(combined=str_c("Num: ", number))

#' You can pass the variable `collapse` to `str_c()` if you're turning an array of strings into one.
data %>% 
    group_by(place) %>% 
    summarize(ids_combined=str_c(number, collapse="-"))


#' **subset strings**  
#' `str_sub(strings, start, end)` extracts and replaces substrings
x <- "Dr. James"

str_sub(x, 1, 3)

str_sub(x, 1, 3) <- "Mr."
x

#' Negative numbers count from the right.
x <- "baby"
str_sub(x, -3, -1)

str_sub(x, -1, -1) <- "ies"
x


#' **change case**  
#' 
#'* `str_to_upper(strings)` is upper case
#'* `str_to_lower(strings)` is lower case
#'* `str_to_title(strings)` is title case
x <- c("john smith", "Mary Todd", "BILL HOLLIS")

str_to_upper(x)
str_to_lower(x)
str_to_title(x)


#'**trim strings**  
#' `str_trim(strings)` remove white space at the beginning and end of string
x <- c(" Assault", "Burglary ", " Kidnapping ")

str_trim(x)


#'**detect matches**   
#' `str_detect(strings, pattern)` returns T/F
x <- c("Bill", "Bob", "David.Williams")
x

str_detect(x, "il")


#'**count matches**  
#' `str_count(strings, pattern)` count number of matches in a string
x <- c("Assault/Robbery/Kidnapping")
x

str_count(x, "/")

#' How many offenses
str_count(x, "/") + 1


#'**extract matches** using regular expressions
x <- c("bsmith@microsoft.com", "jdoe@google.com", "jfwilliams@google.com")

str_extract(x, "@.+\\.com$")


#'**split strings**  
#' `str_split(string, pattern)` split a string into pieces
x <- c("john smith", "mary todd", "bill holis")

str_split(x, " ", simplify=TRUE)

first <- str_split(x, " ", simplify=TRUE)[,1]
last  <- str_split(x, " ", simplify=TRUE)[,2]


#'**replace a pattern**  
#' `str_replace(strings, pattern, replacement)`   
#' replace a pattern in a string with another string
x <- c("john smith", "mary todd", "bill holis")

str_replace(x, "[aeiou]", "-")

str_replace_all(x, "[aeiou]", "-")


#'### Back to our campaign data 

events

#' now let's use string functions to standardize a few event types
events %>%
  select(event_type) %>% 
  mutate(new_type = case_when(
    str_detect(event_type, "speech") ~ "speech")
  ) 


#' could there be a problem here?  
#' multiples?
events %>%
  select(event_type) %>% 
  mutate(new_type = case_when(
    str_detect(event_type, ",") ~ "multiple",
    str_detect(event_type, "speech") ~ "speech",
    str_detect(event_type, "event") ~ "unspecified event",
    str_detect(event_type, "forum") ~ "town hall",
    str_detect(event_type, "town hall") ~ "town hall"
    )
  ) 

#' Notice that in the example above, the search for comma comes first, not last
#'    

#' We can also use our string functions for filtering  
#' Let's see what that might look like

events %>% 
  filter(str_detect(event_type, "event"))

#'  
#' That's *kinda* helpful, but is there a column this could be even more useful for?  
#'   
#' Examine the descriptions

events %>% 
  select(cand_restname, description) 

#' What we we want to find descriptions mentioning students

events %>% 
  select(cand_restname, description) %>% 
  filter(str_detect(description, "student"))

#' How about anything referencing the NAACP

events %>% 
  select(cand_restname, description) %>% 
  filter(str_detect(description, "NAACP"))

#' Remember: R is *case-sensitive*.   
#' Could an acronym like that possibly cause us trouble?  
#'   
#' If so, how might we solve the issue of case sensitivity?
#'   

events %>% 
  select(cand_restname, description) %>% 
  filter(str_detect(str_to_lower(description), "naacp"))

#' This method is a good strategy to use almost anytime you're searching in this way  
#'   
#' Even when you don't think you'll need it, you never know.  
#'   
#' Let's look at an example

events %>% 
  filter(str_detect(description, "border"))

#' No results. Or are there?

events %>% 
  filter(str_detect(str_to_lower(description), "border"))

#' You can also do the reverse for the case, with the same goal. 

events %>% 
  filter(str_detect(str_to_upper(description), "BORDER"))



#'### Joining Tables 

#' One of the most powerful things about relational data being able to join tables together.  
#'   
#' Let's take a look at how to do that with dpylr and the tidyverse.  
#'   
#' First, let's bring in some new data:

key_house_results <- readRDS("key_house_results.rds") 
key_house_historical <- readRDS("key_house_historical.rds") 

#' What do we have here? Let's take a look and discuss.
#'   
#'   
key_house_results

key_house_historical

#` This is a common thing to see - ables designed to be joined together based on a common key.
#'  
#' In this case, we have the house district itself as the common key between the two tables.
#'   
#' We'll use dplyr's `inner_join()` function to match the tables based on that column.  
#' Let's see how that works

inner_join(key_house_results, key_house_historical)

#' Wait, that's it? We haven't even told it what to join on.  
#' That's because if the two tables share columns with the same name, it defaults to use them for the join.  
#'   
#' If you need to specific which columns in each table to match together, you do it like this:

# inner_join(table1, table2, by = c("table1_columnname" = "table2_columnname"))

#' We can also use the pipe to write out a join. It depends on your preference.

key_house_results %>% 
  inner_join(key_house_historical)

#' Now with an explicit mentioning of the column to join

key_house_results %>% 
  inner_join(key_house_historical, by = "house_dist")

#' Remember, if we want to save the results, we need to create a new object

joined <- key_house_results %>% 
  inner_join(key_house_historical, by = "house_dist")

#' Let's explore our new joined table using what we've learned so far

glimpse(joined)

#' What kinds of questions can we ask, using our dplyr functions? Lots of choices!
#'   
#' Let's start out by getting some aggregate counts  
#' How many key races were there?

joined %>% 
  count(keyrace_rating)

#' How many did each party win?

joined %>% 
  count(keyrace_rating, winner)

#' How many of those wins were flips?
joined %>% 
  filter(!is.na(keyrace_rating)) %>% 
  count(winner, flips)

#' Wait a sec, what was that with the `!is.na()`?  
#' You can reverse certain functions like `is.na()` - returning only NA rows - by adding a `!` before it.  
#' Just like with `!=`  
#'   
#' Now let's examine just the flipped districts

flipped <- joined %>% 
  filter(flips == "Y") 

flipped

#' *Note: this data is for training purposes only. A few actual results affecting flips aren't reflected here.*  
#' Now we can start asking some questions about the nature of the flipped districts:

flipped %>% 
  count(winner)

#' Quite a lopsided result in favor of the Dems.  
#' How many flipped districts were above vs. below the national average pct of college grads

flipped %>% 
  count(winner, pct_college_abovebelow_natl)

#' How many flipped districts were above vs. below the the national median income figure

flipped %>% 
  count(winner, median_income_abovebelow_natl)

#' Interesting!  
#'   
#'   
#' Let's do some calculating.  
#' What was the *average margin of victory* for Dems in flipped districts?

flipped %>% 
  group_by(winner) %>% 
  summarise(mean(margin))

#' Maybe there are some other variables of which we might want to see averages

flipped %>% 
  group_by(winner) %>% 
  summarise(mean(pct_college))

#' Could we do both of them at the same time? We can, like this:

flipped %>% 
  group_by(winner) %>% 
  summarise(mean(margin), mean(pct_college))

#' Hmm, this isn't bad but what if we had five columns, or ten?  
#' Is there an easier way?  
#'   
#' Yes, let's talk about *scoped functions*.
#'  
#'    

#' ### Scoped dplyr functions
#'   
#' The idea behind scoped functions: variations on the dplyr commands we've used, but designed to apply to multiple variables.
#'   
#' They generally end with `'_all`, `_at`, and `_if` ... e.g. `summarise_if()`  
#'   
#' Let's take a look back at our election data. We could do something like this:

flipped %>% 
  group_by(winner) %>% 
  summarise(mean(margin), 
            mean(pct_college),
            mean(median_income))

#' Or, we could use a scoped function. Here, we'll use `summarise_at()` - designed for when you know specific columns you want. 

flipped %>% 
  group_by(winner) %>% 
  summarise_at(vars(margin, pct_college, median_income), mean)

#' Sweet, right? That was a lot easier.  
#' Notice the use of `vars()` above - this is needed when specifying multiple variables.  
#' The columns/variables you want go in `vars()`, followed by the function to apply to them.  
#'   
#' We can even apply *more than one* function at a time:

flipped %>% 
  group_by(winner) %>% 
  summarise_at(vars(margin, pct_college, median_income), c(avg = mean, med = median))

#' We can also group by more than one variable, like below where we look at the entire set of races not just flips.

joined %>% 
  group_by(flips, winner) %>% 
  summarise_at(vars(margin, pct_college, median_income), mean)

#' Notice something a little odd with the results? We're getting some NAs.  
#' Since `mean()` breaks when there are NA values, we need to fix that.

joined %>% 
  group_by(flips, winner) %>% 
  summarise_at(vars(margin, pct_college, median_income), mean, na.rm = TRUE)

#' We can even create our own custom functions (won't get into that in this session, though).  
#'   
#' Now what if we wanted to apply our mean to every column in the data? 

flipped %>% 
  group_by(winner) %>% 
  summarise_all(mean)

#' We got a lot of warnings there. What happened?  
#' You can't calculate a mean on a text column, only a numeric one.  
#'   
#'   
#' Enter `summarise_if()`.

flipped %>% 
  group_by(winner) %>% 
  summarise_if(is.numeric, mean)

#' Now we're talking.  
#'   
#' Though if we look closely, there are some columns we may decide aren't we want.  
#' Let's say we don't want to averages of vote percentages for our analysis.  
#' We could see if there's a pattern to their names? There is, so we can use a `select()`` helper function.

flipped %>% 
  select(-ends_with("vote_pct")) %>% 
  group_by(winner) %>% 
  summarise_if(is.numeric, mean)

#' Perfect. 
#'   
#' We're not going to get into all the select helper functions, but they are very useful,  
#' You can read more about them at https://www.rdocumentation.org/packages/dplyr/versions/0.7.2/topics/select_helpers
#'   

#' Such scoped versions also exist for other dplyr functions.  
#' Let's take a quick look at `mutate_at()`.
# mutate_at(vars(x, y, z), .funs, ...)
#' Perhaps we want to format the percentages as text because a web app using the data is having trouble displaying numerics (this generally can be handled by app code but let's say it can't for whatever reason).  
#' 



joined %>% 
  select(dem_vote_pct, 
         gop_vote_pct,
         pct_college,
         trump_vote_pct,
         clinton_vote_pct) %>% 
  mutate_at(vars(dem_vote_pct, 
                 gop_vote_pct,
                 pct_college,
                 trump_vote_pct,
                 clinton_vote_pct), 
            as.character)

#' You can also create new columns just as you do with mutate

joined %>% 
  select(dem_vote_pct, 
         gop_vote_pct) %>% 
  mutate_at(vars(dem_vote_char = dem_vote_pct, 
                 gop_vote_char = gop_vote_pct), 
            as.character)

#' To mutate certain columns based on criteria, we use `mutate_if()`

joined %>% 
  mutate_if(is.character, str_to_lower)

joined %>% 
  mutate_if(is.character, str_to_title)



#' Finally, hot of the presses: just released in the **new version** of dplyr, 0.8. Scoped version of `group_by()`!
#'   
#' More details at https://dplyr.tidyverse.org/reference/group_by_all.html  
#'   
#' We're not going to go into it for this session - mainly because I haven't even explored it myself yet. But look forward to!




