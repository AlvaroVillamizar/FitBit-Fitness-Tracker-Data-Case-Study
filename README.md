# FitBit Fitness Tracker Data

Fitbit is an American company dedicated to produce fitness electronics devices. Their product ranges from wireless-enabled wearable bracelets, personalize catalogue of workouts, meditation and more, and also has an [app](https://play.google.com/store/apps/details?id=com.fitbit.FitbitMobile&hl=en&gl=US&pli=1) able to monitor physical activity, heart rate, quality of sleep, and steps.

<p align="center">

<img src="https://help.fitbit.com/articles/en_US/Resources/Images/Fitbit%20App/App%20icons/Three%20Screenshots.png" width="300" height="auto">
<img src="https://cdn.vox-cdn.com/thumbor/kg-vepOqtURn-mG2qcgmhWjnSvU=/0x0:2040x1360/1400x788/filters:focal(1020x680:1021x681)/cdn.vox-cdn.com/uploads/chorus_asset/file/23324425/VRG_ILLO_5090_The_best_Fitbit_for_your_fitness_and_health.jpg" width="300" height="auto">

</p>

 Between March 12 and May 12 of 2016, a distributed survey via Amazon Mechanical Turk recollected data from thirty eligible FitBit users, with users consent, for the submission of their personal trackable data, including: minute-level output for physical activity, hear rate, and sleep monitoring. This [data](https://www.kaggle.com/datasets/arashnic/fitbit) was used to analyze users behavior, and how to improve overall health. The main goal of this analysis is to find solutions of the following questions

 - Do users accomplish weight loss?
 - Do users become more active by using the product?

## Data Description

The data collected can be classified in three categories: daily records, hourly records, and minute records. For the purpose of this analysis, only daily information was used, these datasets contain information about: Activity date, total steps, physical activity in minutes, and calories.

The *first step* was to organize all the daily datasets into a single main dataset for the rest of the analysis. The tool employed for this task was Microsoft SQL Server 19.

<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/Bellabeat_table.png?raw=true" width="525" height="auto">
</p>

The *next step*, and repeated throughout the analysis to guarantee data integrity, involve checking and removing duplicates and errors within the data. Due to the absence of a primary key in each dataset, SQL JOIN commands resulted in duplicates, and there ware instances of human error in the data recollection that required correction.

<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/Duplicates_Outliers.png?raw=true" width="525" height="auto">
</p>

## Correlation graph between Calories and Number of Steps

<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/Calorie-Steps.png?raw=true" width="400" height="auto">
</p>

- In the previous graph we can observe a positive correlation between calorie intake and the number of steps, which indicates that the more calories a person consumes, the more active it becomes.

## Bar chart of week of the year and average steps

<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/AvgSteps-Weeks.png?raw=true" width="400" height="auto">
</p>

- In the previous bar chart we can observe not noticeable difference between the average of steps per week. However, there exist a tiny decreasing after the second week of FitBit usage.

## Trend line of week of the year and average steps
<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/Correlation_Weeks-AvgSteps.png?raw=true" width="400" height="auto">
</p>
- In this plot we can observe that the relationship of average steps and weeks of usage decrease, which means that after the third week of usage, users tent to become less active.

## Distribution of users per activity level and Calories burned
<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/Boxplot_ActivityLevel-CaloriesBurned.png?raw=true" width="400" height="auto">
</p>

- We can observer from the previous graph that sedentary and fairly active group burned, on average, similar amount of calories. On contrast, Lightly active groups, which do more exercise than the previous one, has the lowest burned calories ratio.

## Number of people in each dietary group
<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/CalorieClassification.png?raw=true" width="400" height="auto">
</p>

- Here we can confirm that most of FitBit users tent to lose weight by being on calorie deficit.

## Number of people per each physical activity group
<p align="center">
<img src="https://github.com/AlvaroVillamizar/FitBit-Fitness-Tracker-Data-Case-Study/blob/main/Images/ActivityLevel-CalorieClassification.png?raw=true" width="525" height="auto">
</p>

- Contrary to what the previous graph suggest, people from the groups, Lightly Active and Very Active have the highest number of people on calorie deficit. Therefore, the most likely to lose weight.

## Conclusions and recommendations

In conclusion, FitBit' users find good use of the content that the app provides, they are 78%
likely to reach their goal of losing weight and became fitter. However, I suggest more engagement for
long time users, users with more than 3 weeks of use; this will make users more healthy, and engage with the product.
