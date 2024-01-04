# Analyzing Students' Mental Health in SQL
## Introduction 
### Objective
Does going to university in a different country affect your mental health? A Japanese international university surveyed its students in 2018 and published a study the following year that was approved by several ethical and regulatory boards.

The study found that international students have a higher risk of mental health difficulties than the general population, and that social connectedness (belonging to a social group) and acculturative stress (stress associated with joining a new culture) are predictive of depression.

Explore the students data using PostgreSQL to find out if you would come to a similar conclusion for international students and see if the length of stay is a contributing factor.

Here is a data description of the columns you may find helpful.  

| Field Name    | Description                                           |
|---------------|-------------------------------------------------------|
| inter_dom     | Types of students (international or domestic)         |
| japanese_cate | Japanese language proficiency                         |
| english_cate  | English language proficiency                          |
| academic      | Current academic level (undergraduate or graduate)    |
| age           | Current age of student                                |
| stay          | Current length of stay in years                        |
| todep         | Total score of depression (PHQ-9 test)                 |
| tosc          | Total score of social connectedness (SCS test)        |
| toas          | Total score of acculturative stress (ASISS test)      |


**Query**  
```sql
-- count all of the records
SELECT COUNT(*) as total_records
FROM students;
````
| total_records |
| ------------- |
| 286           |

```sql
-- count all records per student type
SELECT inter_dom
	, COUNT(*) as count_inter_dom
FROM students
GROUP BY inter_dom;
````
| inter_dom       | count_inter_dom |
|-----------------|-----------------|
| Inter           | 201             |
| Dom             | 67              |
| null            | 18              |

```sql
-- filter to understand data for international student type
SELECT inter_dom
	, japanese_cate
	, english_cate
	, academic
	, age 
	, stay
	, todep
	, tosc
	, toas
FROM students
WHERE inter_dom = 'Inter';
````
View [Output data](https://github.com/chiangsuanne/SQL-Portfolio/blob/main/Students'%20Mental%20Health%20Analysis/international%20student%20data.csv)

```sql
-- filter to understand data for domestic student type
SELECT inter_dom
	, japanese_cate
	, english_cate
	, academic
	, age 
	, stay
	, todep
	, tosc
	, toas
FROM students
WHERE inter_dom = 'Dom';
````
View [Output data](https://github.com/chiangsuanne/SQL-Portfolio/blob/main/Students'%20Mental%20Health%20Analysis/domestic%20student%20data.csv)

```sql
-- filter to understand data for null student type
SELECT inter_dom
	, japanese_cate
	, english_cate
	, academic
	, age 
	, stay
	, todep
	, tosc
	, toas
FROM students
WHERE inter_dom IS NULL;
````
View [Output data](https://github.com/chiangsuanne/SQL-Portfolio/blob/main/Students'%20Mental%20Health%20Analysis/null%20student%20data.csv)

```sql
-- query the summary statistics of the diagnostics scores for all students
SELECT MIN(todep) as min_phq
	, MAX(todep) as max_phq
	, ROUND(AVG(todep), 2) as avg_phq
	, MIN(tosc) as min_scs
	, MAX(tosc) as max_scs
	, ROUND(AVG(tosc), 2) as avg_scs
	, MIN(toas) as min_as
	, MAX(toas) as max_as
	, ROUND(AVG(toas), 2) as avg_as
FROM students;
````
| min_phq | max_phq | avg_phq | min_scs | max_scs | avg_scs | min_as | max_as | avg_as |
|---------|---------|---------|---------|---------|---------|--------|--------|--------|
| 0       | 25      | 8.19    | 8       | 48      | 37.47   | 36     | 145    | 72.38  |

```sql
-- query the summary statistics of the diagnostics scores for international students only
SELECT MIN(todep) as min_phq
	, MAX(todep) as max_phq
	, ROUND(AVG(todep), 2) as avg_phq
	, MIN(tosc) as min_scs
	, MAX(tosc) as max_scs
	, ROUND(AVG(tosc), 2) as avg_scs
	, MIN(toas) as min_as
	, MAX(toas) as max_as
	, ROUND(AVG(toas), 2) as avg_as
FROM students
WHERE inter_dom = 'Inter';
````
| min_phq | max_phq | avg_phq | min_scs | max_scs | avg_scs | min_as | max_as | avg_as |
|---------|---------|---------|---------|---------|---------|--------|--------|--------|
| 0       | 25      | 8.04    | 11      | 48      | 37.42   | 36     | 145    | 75.56  |

```sql
-- group by length of stay
SELECT stay
	, MIN(todep) as min_phq
	, MAX(todep) as max_phq
	, ROUND(AVG(todep), 2) as avg_phq
	, MIN(tosc) as min_scs
	, MAX(tosc) as max_scs
	, ROUND(AVG(tosc), 2) as avg_scs
	, MIN(toas) as min_as
	, MAX(toas) as max_as
	, ROUND(AVG(toas), 2) as avg_as
FROM students
WHERE inter_dom = 'Inter'
GROUP BY stay
ORDER BY stay DESC;
````
| stay | min_phq | max_phq | avg_phq | min_scs | max_scs | avg_scs | min_as | max_as | avg_as |
|------|---------|---------|---------|---------|---------|---------|--------|--------|--------|
| 10   | 13      | 13      | 13      | 32      | 32      | 32      | 50     | 50     | 50     |
| 8    | 10      | 10      | 10      | 44      | 44      | 44      | 65     | 65     | 65     |
| 7    | 4       | 4       | 4       | 48      | 48      | 48      | 45     | 45     | 45     |
| 6    | 2       | 10      | 6       | 35      | 41      | 38      | 42     | 83     | 58.67  |
| 5    | 0       | 0       | 0       | 34      | 34      | 34      | 91     | 91     | 91     |
| 4    | 0       | 14      | 8.57    | 17      | 48      | 33.93   | 36     | 129    | 87.71  |
| 3    | 0       | 24      | 9.09    | 13      | 48      | 37.13   | 36     | 133    | 78     |
| 2    | 0       | 21      | 8.28    | 11      | 48      | 37.08   | 36     | 127    | 77.67  |
| 1    | 0       | 25      | 7.48    | 11      | 48      | 38.11   | 36     | 145    | 72.8   |

```sql
-- final output
SELECT stay
	, ROUND(AVG(todep), 2) as average_phq
	, ROUND(AVG(tosc), 2) as average_scs
	, ROUND(AVG(toas), 2) as average_as
FROM students
WHERE inter_dom = 'Inter'
GROUP BY stay
ORDER BY stay DESC;
````
| stay | average_phq | average_scs | average_as |
|------|-------------|-------------|------------|
| 10   | 13          | 32          | 50         |
| 8    | 10          | 44          | 65         |
| 7    | 4           | 48          | 45         |
| 6    | 6           | 38          | 58.67      |
| 5    | 0           | 34          | 91         |
| 4    | 8.57        | 33.93       | 87.71      |
| 3    | 9.09        | 37.13       | 78         |
| 2    | 8.28        | 37.08       | 77.67      |
| 1    | 7.48        | 38.11       | 72.8       |

### Conclusion
The summary statistics for the entire student population (both international and domestic) indicate that the average scores for depression (PHQ-9), social connectedness (SCS), and acculturative stress (ASISS) are 8.19, 37.47, and 72.38, respectively.

When specifically looking at international students, their average scores are slightly different, with average depression, social connectedness, and acculturative stress scores of 8.04, 37.42, and 75.56, respectively.

Further analysis by grouping international students based on their length of stay reveals interesting insights:	
- Students with a longer stay (e.g., 10 years) tend to have higher average scores in depression, social connectedness, and acculturative stress.	
- There's a variation in scores across different lengths of stay, suggesting that the duration of stay might be a contributing factor to mental health outcomes.	
### Suggestions for Further Analysis
1. **Correlation Analysis:**	

   Perform correlation analysis between the length of stay and diagnostic scores to determine if there is a statistically significant relationship.	
2. **Statistical Tests:**	

   Conduct statistical tests to assess the significance of differences in diagnostic scores among different length-of-stay groups.
3. **Qualitative Analysis:**		

   Consider qualitative data, such as student experiences or feedback, to provide additional context to the quantitative findings.	
4. **Multivariate Analysis:**	

   Explore multivariate analysis to understand the combined effect of different factors on mental health, considering language proficiency, academic level, and age alongside length of stay.

By systematically conducting these further steps, you can gain a more comprehensive understanding of whether the length of stay is indeed a contributing factor to the mental health of international students at the Japanese university.
