 ## Goal 
To practice the usage of `stringr` and `lubridate` 
## Data
1. `Collins Scrabble Words` https://en.wikipedia.org/wiki/Collins_Scrabble_Words
2. `civil_war_theater.csv` https://en.wikipedia.org/wiki/List_of_American_Civil_War_battles

- `Battle`: The name of the battle.
- `Date`: The date(s) of the battle in different formats depending upon the length of the battle. 
  + If it took place on one day, the format is "month day, year". 
  + If it took place over multiple days, the format is "month day_start-day_end, year". 
  + If it took place over multiple days and months, the format is "month_start day_start - month_end day_end, year". 
  + If it took place over multiple days,months, and years, the format is "month_start day_start, year_start - month_end day_end, year_end".
- `State`: The state where the battle took place. Annotations (e.g.     describing that the state was a territory at the time) are in parentheses.
- `CWSAC`: A rating of the military significance of the battle by the Civil War Sites Advisory Commission. `A` = Decisive, `B` = Major, `C` = Formative, `D` = Limited.
- `Outcome`: Usually `"Confederate victory"`, `"Union victory"`, or `"Inconclusive"`, followed by notes.
- `Theater`: An attempt to to identify which theater of war is most associated with the battle
## What is `stringr`? 
This package is good at correct implementations of common string manipulations. 
## What is `lubridate`? 
Date-time data can be difficult to deal with because of date-times are changing based on the time-zones, leap days, daylight saving times. However, Lubridate package enables to deal with these problems easily.
## Packages that are used
`tidyverse`
`stringr` 
`readr`
`lubridate` 
`ggthemes`

