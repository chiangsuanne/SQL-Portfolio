-- count all of the records
SELECT COUNT(*) as total_records
FROM students;  


-- count all records per student type
SELECT inter_dom
	, COUNT(*) as count_inter_dom
FROM students
GROUP BY inter_dom;


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


-- final output
SELECT stay
	, ROUND(AVG(todep), 2) as average_phq
	, ROUND(AVG(tosc), 2) as average_scs
	, ROUND(AVG(toas), 2) as average_as
FROM students
WHERE inter_dom = 'Inter'
GROUP BY stay
ORDER BY stay DESC;
