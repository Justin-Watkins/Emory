# Project Overview

The goal of this project is to build an accurate model to estimate ticket sales for a future season. Ticket sales data is wide and typically not very long. This structure may lend itself to using specific techniques.  

Estimating sales figures is a fundamental component of consumer pricing. Taking an algorithmic approach to pricing products can be a rote exercise once the mechanics of the industry are well understood. Producing a top-down approach to forecasting sales allows us to create a baseline we can use to construct the more granular bottom-up pricing models. This is where this project will focus. 

There are no rules in terms of what tools or materials you can use. You can use any algorithm or ensemble of algorithms to construct your model. However, you will need to document your process.   

All required data sets are included and outlined in the following sections. These data sets can be enriched further or used in their present form. Be sure to make sure you understand the data before applying a model.

This project has three deliverables. You or your team will be evaluated relative to the other students or teams in terms of how closely your model matches the ticket sales outcomes contained in the _prediction_data_ folder. _Absolute error_ will be used to rank each team in terms of performance.    

# Deliverables Summary

This project consists of three deliverables:

1. Predictions for ticket sales for each event are contained in the _prediction_data_ folder.
2. A Word document explaining your work.
3. The file or spreadsheet you used to construct your model.

The project will be evaluated based on how closely your model approximates the actual outcomes for the event contained in the _prediction_data_ folder. 

## Deliverables Format

__Deliverable 1:__ A .csv file with the event name, the ticket estimate, and your name or group. See below.

- event_name (CHAR)
- tickets (NUMERIC)
- name (CHAR)

__Deliverable 2:__ A Word document with a brief explanation of your approach. Keep this document concise and brief, you are not being evaluated on its contents. This document should include:

- What steps did you take to evaluate and prepare the data before you began to model it? 
- What tools did you use to build your model? Why? Include any external packages if using a language such as Python or R.
- What model did you use to construct your forecast? Why?
- What is the _RMSE [https://en.wikipedia.org/wiki/Root-mean-square_deviation] of your model on test data? Please include a summary output of the model that documents basic model features such as pvalues etc.
- Please give any other context that you find important.
  - Were there any surprises in the data? 
  - Did anything stand out to you after constructing your model? 
  - Did you enrich the data further? 
  - Did you have to make manual adjustments to your outcome? Why?

__Deliverable 3:__ The file or spreadsheet that you used to build and evaluate your model. 

- Any manual adjustments to the output should be documented with an explanation in deliverable 2.

# Materials

The following sections detail the included materials you will use to construct your forecasts. The data is located in the following folders.  

## data_sales

This folder contains ticket sales data for several seasons. All of this data is publicly available from a variety of sources. We disclose tickets sold after each game. There are three columns in each data set:

- __event_name (CHAR):__ A unique identifier for each event. (These can repeat every other year)
- __Date (DATE):__ The date of the game
- __Tickets (NUMERIC):__ The number of tickets sold for each game

This data will need to be joined to each table in the _data_schedule_ folder.

## data_schedule

This folder contains event-level metadata for each game over several seasons. All of this data is publicly available from a variety of sources. This data has been compiled for convenience and could be reconstructed independently by anyone.

- __Season (CHAR):__ The year the game took place.
- __Game_Number (NUMERIC):__ The game sequence number.
- __Date (DATE):__ The date the game occurred.
- __Time_of_year (CHAR):__ Specific meta data pertaining to the event.
- __Day (CHAR):__	The day of the week (Mon-Sun).
- __effective_day (CHAR):__		A modified day of the week (Mon-Sun).
- __O_Team (CHAR):__ The opposing team.
- __Time_Type2 (NUMERIC):__ Did the game happen in the morning, afternoon, or evening?
- __Month (CHAR):__	What month did this game occur?
- __Weekend (LOGICAL):__ Did this game occur on a Fri, Sat, or Sun?	
- __School (LOGICAL):__	Are children in school?
- __start_of_homestand (LOGICAL):__	Was this the first game in a homestand?
- __end_of_homestand (LOGICAL):__ Was this the last game in a homestand?
- __Opening_Day (LOGICAL):__ Was this the first game of the season?	
- __Holiday (LOGICAL):__ Did this game occur on a holiday such as Memorial Day?
- __Fourth_of_july (LOGICAL):__ Did this game occur on July 4th?
- __Final_Game (LOGICAL):__  Did this game occur on the final game of the season?
- __BobbleHead (LOGICAL):__	Was there a bobblehead promotion?
- __replica (LOGICAL):__ Was there a replica ring promotion?
- __Day_In_Homestand (NUMERIC):__	The sequence of games in a homestand.
- __star_wars (LOGICAL):__  Was there a Star Wars promotion?
- __concert (LOGICAL):__  Was there a concert after the game?
- __christian_concert (LOGICAL):__  Was there a Christian concert after the game?
- __playoff_odds (NUMERIC):__ What is the likelihood that the team will appear in the playoffs? 0-100.
- __delete (LOGICAL):__	Remove this game from your data set.
- __afternoon_weekday (LOGICAL):__ Was this an afternoon game on a weekday?
- __afternoon_weekend (LOGICAL):__ Was this an afternoon game on the weekend?
- __Week (NUMERIC):__	The week number of the year.
- __weighted_odds (NUMERIC):__ Weighted playoff odds.
- __first_homestand (LOGICAL):__ Did this game occur during the first homestand of the season?
- __Time_Type (FACTOR):__	Expanded game time classification.

## prediction_data

This folder contains the data sets you will be forecasting. They mimic the data sets contained in _data_schedule_ and _data_schedule_. However, they have been slightly modified. Not every feature is included since they would be impossible to know _a priori_ 

## Joining the data sets

The data sets can be joined on _Date_. The best method will be to use a _left join_. It will look something like this:

```{r join,out.width = "400px",echo=T,eval=F}

left_join(data_sales,data_schedule,by = "Date")

```

# Contact Information

Please feel free to contact me with any questions:

Justin Watkins | justin.watkins@braves.com

Include __EMORY_MSBA_PROJECT__ in the subject line of your email. 
