/*#########################################################################
#	Dataset: FitBit Fitness Tracker Data				  #
#	Source: https://www.kaggle.com/datasets/arashnic/fitbit		  #
#	Language: Microsoft SQL Server Management Studio 19		  #
##########################################################################*/

-- Merging and organizing some data sets for the analysis
SELECT
	DI.Id,
	DA.TotalSteps,
	DA.TotalDistance,
	DA.ActivityDate AS 'Date',
	SD.TotalTimeInBed AS TotalTimeInBed,
	SD.TotalMinutesAsleep AS TotalMinutesAsleep,
	DI.SedentaryMinutes AS SedentaryMinutes,
	DI.LightlyActiveMinutes AS LightlyActiveMinutes,
	DI.FairlyActiveMinutes AS FairlyActiveMinutes,
	DI.VeryActiveMinutes AS VeryActiveMinutes,
	DC.Calories AS DailyCalories
INTO #Bellabeat_daily  -- Storing the query in a temporary table 
FROM 
	dailyIntensities_merged AS DI 
	LEFT JOIN sleepDay_merged AS SD 
	ON (DI.Id = SD.Id AND DI.ActivityDay = SD.SleepDay) 
	LEFT JOIN dailyCalories_merged AS DC 
	ON (DI.Id = DC.Id AND DI.ActivityDay = DC.ActivityDay) 
	JOIN dailyActivity_merged AS DA
	ON (DI.Id = DA.Id AND DI.ActivityDay = DA.ActivityDate)


-- Checking for duplicates
WITH DUPLICATES AS (
    SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY TotalSteps, Date, TotalDistance, Id ORDER BY Id) AS RowNum
    FROM #Bellabeat_daily
)
DELETE FROM DUPLICATES
WHERE 
	RowNum >1;

-- Deleting Incoherent data points. 
-- Which correspond to all calorie comsuption under 666 per day
WITH OUTLIERS AS (
	SELECT *
	FROM #Bellabeat_daily
	WHERE DailyCalories < 666
)
DELETE FROM OUTLIERS

-- Classification by their Activity Level according to the week of the year
SELECT *,
	CASE 
		WHEN Steps <5000 THEN 'Sedentary'
		WHEN Steps <= 7499 AND Steps >=5000 THEN 'LightlyActive'
		WHEN Steps>=7500 AND Steps <=9999 THEN 'FairlyActive'
		ELSE 'VeryActive' 
	END AS ActivityLevel
INTO #TempTable  -- Saving the activity classification in a temporary table
FROM (SELECT
	Id,
	AVG(TotalSteps) AS Steps,
	AVG(TotalDistance) AS Distance,
	AVG(TotalTimeInBed) AS TimeInBed,
	AVG(TotalMinutesAsleep) AS MinutesAsleep,
	AVG(DailyCalories) AS Calories,
	WeekOfYear
FROM (SELECT *,
	DATEPART(WEEK,Date) AS WeekOfYear
FROM #Bellabeat_daily) A
GROUP BY WeekOfYear, Id) A

-- Analyzing if the clients become more active by using FitBit's product
SELECT ActivityLevel,
	AVG(CAST(Count AS FLOAT)) AS Median
FROM (
SELECT
	ActivityLevel,
	WeekOfYear,
	COUNT(*) AS Count
FROM
	#TempTable
--WHERE 
--	ActivityLevel = 'Sedentary'
GROUP BY 
	ActivityLevel, WeekOfyear) A
GROUP BY ActivityLevel

/*We can observe that for the most part, all the users were still on their activity level throughout 
each week. However, the bottom two categories with the least amount of people were Sedentary and Fairly 
Active, and the top two groups were Lightly Active and Very active, which means that throughout most 
of the use of the app, the majority of Fitbit clients stayed active.*/

SELECT *
FROM #TempTable

-- Analyzing if we can observed any other pattern in the physical activiy throughout each week of the year
SELECT
	WeekOfYear,
	AVG(Steps) AS Steps
FROM #TempTable
GROUP BY	
	WeekOfYear

/*We can observe that in the first 3 weeks of use, people were doing more physical activity, 
but after the 4th week, they become less active*/

-- Determine Calories needed per Activity Level
-- Average Calories
SELECT 
	#Bellabeat_daily.Id,
	ROUND(AVG(#Bellabeat_daily.DailyCalories),2) AS AvgCalories
FROM 
	#Bellabeat_daily JOIN #TempTable 
	ON #Bellabeat_daily.Id = #TempTable.Id
GROUP BY 
	#Bellabeat_daily.Id, #TempTable.WeekOfYear

--Calories Burned vs BMR per Activity Level
DECLARE @Age INTEGER; -- Average age in the USA population in 2021
SET @Age = 38.1  -- Source: datacommons.org/place/country/USA/?utm_medium=explore&mprop=age&popt=Person&hl=en
SELECT *,
	CASE 
/* Here, I assumed that people under 5.4 feet are women, and also the person with ID = 1927972279, 
because of her calorie consumption per day */
		WHEN HeightInches < 5.4 OR (Id = 1927972279)  
		THEN ROUND((9.563*WeightKg)+ (1.85*HeightCm)- (4.676*@Age)+ 655.1 ,2) -- For women
		ELSE ROUND((13.75*WeightKg)+ (5.003*HeightCm)- (6.775*@Age)+ 66.5,2)  -- For men
	END AS BMR 
/* This is the Harris Benedict equation, this is why the classification per sex was important.
For reference see: 
[1] ncbi.nlm.nih.gov/pmc/articles/PMC7784146/#:~:text=In%20men%2C%20the%20Harris%2DBenedict,4.6756%20x%20age%20in%20years.
[2] en.wikipedia.org/wiki/Harris%E2%80%93Benedict_equation    */
INTO #TempTable2
FROM (
	SELECT *,
		ROUND(SQRT(WeightPounds/BMI*703)*2.54,2) AS HeightCm,
		ROUND(SQRT(WeightPounds/BMI*703)/12,2) AS HeightInches
	FROM weightLogInfo_merged) A
ORDER BY HeightCm


-- Deleting unecesarry columns from the previous query
ALTER TABLE #TempTable2
DROP COLUMN Fat, IsManualReport, LogId;

SELECT *
FROM #TempTable2

-- Calculating Calories Burned per Activity level and week of the year
SELECT TT2.Id,
	TT.WeekOfYear,
	TT2.WeightPounds,
	TT2.HeightInches,
	TT2.BMR,
	TT.Steps,
	TT.ActivityLevel,
/* According to the information in: 
medicalnewstoday.com/articles/319731#factors-influencing-daily-calorie-burn-and-weight-loss

For each activity level there is a point associated with it, and by multiplying it with the 
basal metabolic rate (BMR) we obtain the amount of calories needed to maintain their weight*/
	CASE 
		WHEN TT.ActivityLevel = 'Sedentary' THEN TT2.BMR*1.2
		WHEN TT.ActivityLevel = 'LightlyActive' THEN TT2.BMR*1.375
		WHEN TT.ActivityLevel = 'FairlyActive' THEN TT2.BMR*1.55
		ELSE TT2.BMR*1.725 
	END AS CaloriesBurned,
	TT.Calories
INTO #TempTable3
FROM #TempTable2 AS TT2 LEFT JOIN #TempTable AS TT
ON (TT.Id = TT2.Id)


-- Removing Duplicates from the previous query
WITH DUPLICATES AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY Id, BMR, CaloriesBurned ORDER BY Id) AS RowNum
FROM #TempTable3
)
DELETE FROM DUPLICATES
WHERE RowNum >1

-- Classifing the number of clients who are in Deficit and Surplus
WITH CalorieClassification AS(
SELECT 
	CASE 
		WHEN Remainder <0 THEN 'Deficit'
		ELSE 'Surplus' 
	END AS CalorieClassification
FROM (
	SELECT *,
		ROUND(Calories - CaloriesBurned,2) AS Remainder
	FROM #TempTable3
) A)
SELECT CalorieClassification,
	COUNT(*) AS Count
FROM CalorieClassification
GROUP BY CalorieClassification;

/*Here we can observed that most of FitBit's users stayed in a Calorie Deficit diet throughout 
their use of the product. Which indicates that they loose weight throught the use of this product.*/

/*In conclusion, FitBit's users find good use of the content that the app provides, they are 78% 
likely to reach their goal of losing weight and became fitter. However, I suggest more engagement for 
long time users, more than 3 weeks of use; this will make users more happy with their results, and 
more engage with the product.*/

DROP TABLE #TempTable
DROP TABLE #TempTable2
DROP TABLE #TempTable3
