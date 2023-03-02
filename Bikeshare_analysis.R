#install packages :"tidyverse", "lubridate","skimr", "dplyr"

library(tidyverse)
library(lubridate)
library(skimr)
library(dplyr)

#Case
Cyclistic is a bike-share company in Chicago which intends to maximize the number of annual memberships
of its users to improve business growth. To achieve this goal, the company aims to convert casual riders
into annual members by creating campaigns to market targeted at casual riders.

#Business Task:
*Analyse the data available to discover how annual members and casual members differ.
*Use the insight obtained to suggest how to convert casual members into annual members.

#Metadata:
Cyclistics historical trip data was obtained from AWS(https://divvy-tripdata.s3.amazonaws.com/index.html).
This is a public dataset that was made available by Motivate International Inc. The user trip data is 
provided monthly in a .CSV format and can be easily accessed by the general public.
For this analysis 11 months worth of data starting from September 2021 to July 2022 will be used.

#Upload the 11 months data 

sep_21 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202109-divvy-tripdata.csv")
oct_21 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202110-divvy-tripdata.csv")
nov_21 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202111-divvy-tripdata.csv")
dec_21 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202112-divvy-tripdata.csv")
jan_22 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202201-divvy-tripdata.csv")
feb_22 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202202-divvy-tripdata.csv")
mar_22 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202203-divvy-tripdata.csv")
apr_22 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202204-divvy-tripdata.csv")
may_22 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202205-divvy-tripdata.csv")
jun_22 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202206-divvy-tripdata.csv")
jul_22 <- read_csv("C:/Users/timot/OneDrive/Documents/R data/Cyclis_CSV/202207-divvy-tripdata.csv")


#Process the data for analysis:


#Check colnames to ensure they match
colnames(sep_21)
colnames(oct_21)
colnames(nov_21)
colnames(dec_21)
colnames(jan_22)
colnames(feb_22)
colnames(mar_22)
colnames(apr_22)
colnames(may_22)
colnames(jun_22)
colnames(jul_22)

#Check datatypes in columns to ensure they match
str(sep_21)
str(oct_21)
str(nov_21)
str(dec_21)
str(jan_22)
str(feb_22)
str(mar_22)
str(apr_22)
str(may_22)
str(jun_22)
str(jul_22)



#Combine the 10 months data 

Cyclistic_df <- bind_rows(sep_21,oct_21,nov_21,dec_21,jan_22,feb_22,mar_22,apr_22,may_22,jun_22,jul_22)

#Verify the data merge
nrow(sep_21)+nrow(oct_21)+nrow(nov_21)+nrow(dec_21)+nrow(jan_22)+nrow(feb_22)+nrow(mar_22)+nrow(apr_22)+nrow(may_22)+nrow(jun_22)+nrow(jul_22)
nrow(Cyclistic_df)

#Explore and Clean the Data
#Create a copy of the dataset before begining the cleaning process
#Add a column 'ride_length' which is the difference between 'ended_at' and 'started_at' in seconds
#Add a column 'day_of_week'

head(Cyclistic_df)
colnames(Cyclistic_df)
str(Cyclistic_df)

table(Cyclistic_df$member_casual)


cyclistic_df2 <- Cyclistic_df

cyclistic_df2$ride_length <- difftime(cyclistic_df2$ended_at,cyclistic_df2$started_at)

cyclistic_df2$day_of_week <- wday(cyclistic_df2$started_at, label = TRUE)

#Check data types of the new columns created
#Convert 'ride_lenth' to numeric for easy calculations.
#Check for missing values in important columns
#Check for negative values in ride_length and remove any if present. 


typeof(cyclistic_df2$ride_length)
typeof(cyclistic_df2$day_of_week)

cyclistic_df2$ride_length <- as.numeric(cyclistic_df2$ride_length)
is.numeric(cyclistic_df2$ride_length)

skim_without_charts(cyclistic_df2)
nrow(cyclistic_df2[cyclistic_df2$ride_length< 0, ])

cyclistic_df3 <- cyclistic_df2[!(cyclistic_df2$ride_length< 0), ]
nrow(cyclistic_df2) - nrow(cyclistic_df3)
colnames(cyclistic_df3)


# Analyze the data

table(cyclistic_df2$day_of_week)
summary(cyclistic_df3$ride_length)

cyclistic_df3 %>%
	group_by(member_casual, day_of_week) %>%
	summarise(number_of_rides = n(), average_ride_length = mean(ride_length))

#Checking the number of rides by rider type per week day

cyclistic_df3 %>%  
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n()
            ,average_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")+ labs(title= "Number of rides by users per weekday")

Insight
# Members generally take more trips during the week
# Casual members take more trips during weekends(saturday and sunday) than registered members


#Checking the average duration of each rider type per week day

cyclistic_df3 %>%  
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n()
            ,average_ride_length = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = average_ride_length, fill = member_casual)) +
  geom_col(position = "dodge") + labs(title= "Average ride lenght of users per weekday")

Insight
# Casual members take longer trips than registered members weekly


#Task: 
The difference between casual users and members is in the number of trips per week,
the number of trips over the weekends, and the duration of the trips 

Recommendations
 Introduce a reward program for members based on ride_lenght
 Introduce a reward program for members that use the bikes during weekends
 Offer discount to members based on ride_length

	
write_csv(cyclistic_df3, "final_cylisticdf.csv")

Resources
Statmethods.net and Kaggle community.
