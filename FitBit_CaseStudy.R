############################################################
# Title:    Exploratory analysis with Health dataset      ##
# File:     FitBit_CaseStudy                              ##
# Project:  FitBit Fitness Tracker Data                   ##
# Source: https://www.kaggle.com/datasets/arashnic/fitbit ##
############################################################

# Loading libraries ----------------------------------------
library(tidyverse)
library(lattice) 

# Reading data sets ----------------------------------------
Bellabeat_daily <- read.csv('C:\\Users\\claud\\OneDrive\\Documents\\Datasets\\Bellabeat_daily.csv')
WeightInfo <- read.csv('C:\\Users\\claud\\OneDrive\\Documents\\Datasets\\weightInfo.csv')

## Renaming variables
colnames(Bellabeat_daily)[2] = 'Steps'
colnames(Bellabeat_daily)[3] = 'Distance'
colnames(Bellabeat_daily)[5] = 'TimeinBed'
colnames(Bellabeat_daily)[6] = 'MinutesAsleep'
colnames(Bellabeat_daily)[11] = 'Calories'

## Convert data into the right data type --------------------
Bellabeat_daily$TimeinBed = as.numeric(Bellabeat_daily$TimeinBed)
Bellabeat_daily$MinutesAsleep = as.numeric(Bellabeat_daily$MinutesAsleep)
Bellabeat_daily$Date = as.Date(Bellabeat_daily$Date)

WeightInfo$ActivityLevel = as.factor(WeightInfo$ActivityLevel)
WeightInfo$ActivityLevel <- relevel(WeightInfo$ActivityLevel, "Sedentary")

# Descriptive Statistics -----------------------------------
summary(Bellabeat_daily)
summary(WeightInfo)

# Do our customers become more fit after using our product##
## Calories vs activity -----------------------------------
Bellabeat_daily %>% 
  ggplot() +
  geom_point(aes(x=Calories, y=Steps), alpha =0.1) +
  geom_smooth(mapping = aes(x=Calories, y=Steps) ,method = 'loess')

# In the previous graph we can observe a positive correlation 
# between calorie intake and the number of steps, which indicates 
# that the more calories, the most active the person becomes

# Here I'm going to extract the number of the week from Date for further analysis
Bellabeat_daily$Week <- strftime(Bellabeat_daily$Date, format = "%V")
Bellabeat_daily$Week = as.factor(Bellabeat_daily$Week)

#Classifying each person with their corresponding Physical Activity
df <- Bellabeat_daily %>% 
  group_by(Week, Id) %>% 
  summarize(AvgSteps = mean(Steps)) %>% 
  mutate(
    ActivityLevel = case_when(
      AvgSteps < 5000 ~ 'Sedentary',
      AvgSteps >= 5000 & AvgSteps <7500 ~ 'Lightly Active',
      AvgSteps >= 7500 & AvgSteps< 10000 ~ 'Fairly Active',
      AvgSteps >= 10000 ~ 'Very Active')) %>%
  left_join(Bellabeat_daily, by= c('Week', 'Id'))

Bellabeat_daily$ActivityLevel <- df$ActivityLevel 

#Bar chart of Week of the Year VS. Average Steps  ----------
StepsWeek <- Bellabeat_daily %>% 
  group_by(Id, Week) %>% 
  summarize(AvgSteps = mean(Steps)) %>% 
  group_by(Week) %>% 
  summarize(AvgSteps = mean(AvgSteps))

StepsWeek %>% 
  ggplot(aes(x=Week, y= AvgSteps)) +
  geom_col() 

# In the previous bar chart we can observe not noticeable 
# difference between the average of steps per week. What we can
# observed is a tiny decreasing after the second week of usage.


# Trend Line Week of the year VS. Average Steps ------------
x <- StepsWeek$Week
x <- (1:length(StepsWeek$Week))
plot(x, StepsWeek$AvgSteps, xlab = "Num. Week of the year", ylab= "Average Steps") 
lines(predict(lm(StepsWeek$AvgSteps~x)), col='green') 

# Plotting the trend line of the average steps, we can observe 
# that the relationship is decreasing, which means that after  
# the second week of usage, user then to become less active.

# Box plot for each Activity Level and Calories burned -----

qplot(ActivityLevel, 
      CaloriesBurned, 
      col  = ActivityLevel, 
      geom = c("boxplot", "jitter"), 
      data = WeightInfo)

# Now, with the previous graph we can observe the distribution 
# of Calories burned per physical activity from the Weight 
# Info data set. We can observe that Sedentary and Fairly active
# groups burned similar amount of calories. However, Lightly 
# Active group has the lowest burned calories on average.

# Classifying each person by calorie deficit or surplus ----
WeightInfo <- WeightInfo %>% 
  mutate(
    CalorieClassification = case_when(
      Calories - CaloriesBurned < 0 ~ 'Deficit',
      Calories - CaloriesBurned >= 0 ~ 'Surplus'
    )
  )

WeightInfo$CalorieClassification <- as.factor(WeightInfo$CalorieClassification)

# Which Physical Activity group has the most number of people
WeightInfo %>% 
  ggplot() +
  geom_bar(aes(ActivityLevel, fill = CalorieClassification))

# Contrary to what the previous graph suggest, people from the groups
# Lightly Active, and Very Active have the biggest amount of people
# on calorie deficit, which are the most likely to lose weight.

# However, on general terms, we can say that most of FitBit users 
# lose weight while using the app, as we can see, most of the users
# are on calorie deficit.

# Which group has the highest number of people
WeightInfo %>% 
  ggplot(aes(CalorieClassification)) +
  geom_bar()
  
# Here we can confirm that most of FitBit users tent to lose
# weight by being on calorie deficit.

# Clear plots
graphics.off()  # Clears plots, closes all graphics devices

# Clear console
cat("\014")  # ctrl+L