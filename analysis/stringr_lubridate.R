# Mark 
# load libraries 
library(tidyverse)
library(stringr) # for string manipulations
library(readr) # fast and friendly way to read rectangular data
library(lubridate) # parse and manipulate dates
library(ggthemes)

# use readr function to load the 2015 list of Collins Scrabble Words 
read_delim('https://data-science-master.github.io/lectures/data/words.txt', delim = "|") -> collins_scrabble

# Show six longest words that have the most "X"'s in them?
collins_scrabble %>%
  mutate(length_of_word = str_length(word)) %>%  # make new column for length_of_word
  mutate(count_X = str_count(word, "X")) %>% # make new column for counting "X"
  arrange(desc(count_X), desc(length_of_word)) %>%  # order
  head(6) %>%  # show 6 longest words 
  select(word)

# How many words have an identical first and second half of the word? If a word has an odd number of letters, exclude the middle character.  
# MURMUR counts because MUR is both the first and second half.
# JIGAJIG counts because the middle A is excluded so JIG is both the first and second half. 
collins_scrabble %>%
  mutate(length_of_word = str_length(word)) %>%  #make new column for length_of_word
  mutate(is_even = if_else(str_length(word) %% 2 == 0,  "yes", "no")) %>% 
  mutate(first_half = if_else(is_even == "yes", 
                              str_sub(word, 1, length_of_word/2), str_sub(word, 1, floor(length_of_word/2)))) %>%
  mutate(second_half = if_else(is_even == "no", 
                               str_sub(word, (length_of_word/2)+1, length_of_word), str_sub(word, ceiling(length_of_word/2 +1), length_of_word))) %>%  
  filter(first_half == second_half) -> identical_first_second 

identical_first_second %>% 
  tally() # count observations 

# Use the above results to find the longest word with an identical first and second half of the word?
identical_first_second %>% 
  arrange(desc(length_of_word)) %>%  
  head(1) %>% 
  select(word)

# Civil War Battles data is about information on American Civil War battles: taken from [Wikipedia](https://en.wikipedia.org/wiki/List_of_American_Civil_War_battles).  
civil_war_data <- read_csv("../data/civil_war_theater.csv")

# Take the dates from all the different formats and create a consistent set of start date and end date variables in the data frame. 
# Calculating how many years, and months are in each battle.

# Add a variable to the data frame with the number of years for each battle.  

civil_war_data %>%  
  mutate(year = str_extract_all(Date, str_c(1861:1865, collapse = "|"))) %>%  
  mutate(year_count = str_count(Date, str_c(1861:1865, collapse = "|"))) -> civil_war_data


# Add a variable to the data frame with the number of months for each battle.  
civil_war_data %>%  
  mutate(month_names = str_extract_all(Date, str_c(month.name, collapse = "|") )) %>%  
  mutate(month_count = str_count(Date, str_c(month.name, collapse = "|") )) -> civil_war_data

# Add a variable to the data frame that is `TRUE` if `Date` spans multiple days and is `FALSE` otherwise. Spanning multiple months and/or years also counts as `TRUE`.
civil_war_data %>%  
  mutate(hyphen = str_detect(Date, "-")) %>%  
  mutate(multiple_days = if_else(hyphen == "TRUE",  "TRUE", "FALSE")) -> civil_war_data

# Make four new data frames by filtering the data based on the length of the battles:  

# a data frame with the data for only those battles spanning just one day, 
civil_war_data %>%
  filter(multiple_days == "FALSE") -> one_day

# a data frame with the data for only those battles spanning multiple days in just one month, 
civil_war_data %>%  
  filter(month_count == 1) %>%  
  filter(multiple_days == "TRUE") -> multiple_days_in_1_mon
   
# a data frame with the data for only those battles spanning multiple months but not multiple years, and,
civil_war_data %>%  
  filter(year_count == 1) %>%  
  filter(month_count != 1) -> multiple_months

# a data frame with the data for only those battles spanning multiple years.
civil_war_data %>% 
  filter(year_count!= 1) -> multiple_years

# For each of the four new data frames,  
# 1
one_day %>% 
  mutate(Start = Date) %>%  
  mutate(End = Date) %>%  
  mutate(Start = mdy(Start)) %>% 
  mutate(End = mdy(End)) -> one_day_updated

# 2
separate(data = multiple_days_in_1_mon, col = Date, sep = "-", into = c("Start", "End")) %>%  
  unite(Start, c("Start", "year")) %>%  
  unite(End, c("End", "month_names")) %>%  
  mutate(Start = mdy(Start)) %>%  
  mutate(End = dym(End)) -> multiple_days_1month_new

# 3 
separate(data = multiple_months, col = Date, sep = "-", into = c("Start", "End")) %>%  
  unite(Start, c("Start", "year")) %>% 
  mutate(Start = mdy(Start)) %>% 
  mutate(End = mdy(End)) -> months_not_years_new

# 4
separate(data = multiple_years, col = Date, sep = "-", into=c("Start", "End")) %>% 
  mutate(Start = mdy(Start)) %>% 
  mutate(End = mdy(End)) -> multiple_years_updated

# Create a new data frame with all the battles and the Start and Enddates by binding the rows of the four data frames as updated in part 6 

bind_rows(one_day_updated, multiple_days_1month_new,months_not_years_new, multiple_years_updated) -> civil_war


# Calculate the number of days each battle spanned.  
# What's the longest battle of the war? & How long did it last?

# 1 way 
civil_war$days_spanned <- civil_war$End - civil_war$Start
civil_war %>%  
  arrange(desc(days_spanned)) %>%  
  head(1) %>%  
  select(Battle, days_spanned)-> the_longest_battle_0
the_longest_battle_0

# 2 way 
civil_war %>%
  mutate(days = difftime(civil_war$Start, civil_war$End, units = "days")) %>%
  arrange(-desc(days)) -> civil_war_with_days
civil_war_with_days$days <- abs(civil_war_with_days$days)

civil_war_with_days %>%
  head(1) %>%
  select(Battle, days) -> the_longest_battle
the_longest_battle

# Is there an association between the CWSAC significance of a battle and its duration?  
# Test for a linear relationship using lm() and interpret the results in one sentence based on the p-value and adjusted R-squared.
# Create an appropriate plot. 

ggplot(data = civil_war, aes(y = days_spanned , x =factor(CWSAC)))+
  geom_boxplot()+ 
  xlab("CWSAC")+
  ylab("Days")+
  theme_bw()

civil_war$day_numeric = as.numeric(civil_war$days_spanned)/(24*60*60)
fit <- lm(day_numeric ~ factor(CWSAC), data = civil_war)
summary(fit)

# Interpret the results: p-value is 2.026e-05, so p-value is very close to 0 indicating that the results are significant, and Adjusted R-squared is  0.0548, indicates that this fit is weak linear fit for the model, so maybe I have to change or add more variables. 

# Did the theaters of war shift during the American Civil War?
civil_war %>%   
  mutate(State = replace(State, State == "West Virginia (Virginia at the time)", "West Virginia")) %>%  
  mutate(State = replace(State, State == "Oklahoma (Indian Territory at the time)", "Oklahoma")) %>%  
  mutate(State = replace(State, State == "Colorado (Colorado Territory at the time)", "Colorado")) %>%  
  mutate(State = replace(State, State == "North Dakota", "North Dakota (Dakota Territory  at the time)")) %>%  
  group_by(State, Theater) %>%  
  summarise(Freq=n()) %>%  
  arrange(desc(Freq))  %>%  
  tail(9) %>%  
  ungroup()  -> filtered_out
filtered_out

civil_war %>%  
  filter(State != "Pennsylvania" ) %>%  
  filter(State != "Colorado"  ) %>%  
  filter(State != "New Mexico (New Mexico Territory at the time)" ) %>%  
  filter(State != "North Dakota (Dakota Territory at the time)" ) %>%  
  filter(State != "Ohio" ,)  %>%  
  filter(State != "District of Columbia"  ) %>%  
  filter(Battle != "Bear River Massacre") %>%  
  filter(Battle != "Battle of Valverde") %>%  
  filter(Battle != "Battle of Glorieta Pass") %>% 
  filter(State != "Indiana" ) -> civil_war_1

ggplot(civil_war_1, aes(x=State, y=Start, fill = Theater))+
  geom_boxplot()+ 
  coord_flip()