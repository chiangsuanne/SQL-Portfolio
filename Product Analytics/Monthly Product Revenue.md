## Data scheme	
![image](https://github.com/chiangsuanne/SQL-Portfolio/assets/108243961/41fa9399-4efa-46f3-a9b1-104498f7b592)

## Calculating descriptive statistics for monthly revenue by product
### Objective	  
The leadership team at your company is making goals for 2023 and wants to understand how much revenue each product subscriptions, basic and expert, are generating each month. More specifically, they want to understand the distribution of monthly revenue across the past year, 2022.	
They've asked the following questions:	
1. How much revenue does each product usually generate each month?
2. Which product had the most success throughout all of last year?
3. Did either product fluctuate greatly each month or was the month-to-month trend fairly consistent?

**Query**
```sql
WITH product_rev as (
SELECT 
    ProductName,
    sum(Revenue) as monthly_rev,
    date_trunc('month', OrderDate) as order_month
FROM Products as p
JOIN Subscriptions as s
WHERE p.PRODUCTID = s.PRODUCTID
    AND date_trunc('month', OrderDate) BETWEEN '2022-01-01' AND '2022-12-01'
GROUP BY ProductName, order_month
)

SELECT
    ProductName,
    min(monthly_rev) as min_rev,
    max(monthly_rev) as max_rev,
    avg(monthly_rev) as avg_rev,
    stddev(monthly_rev) as std_dev_rev
FROM product_rev
GROUP BY ProductName;
````
**Output**
| PRODUCTNAME | MIN_REV | MAX_REV | AVG_REV | STD_DEV_REV        |
|-------------|---------|---------|---------|--------------------|
| Basic       | 500     | 28000   | 13188   | 8123.763642197237  |
| Expert      | 3000    | 46000   | 18000   | 13796.134724383252 |

### Conclusion
**Monthly Revenue Distribution:**	

For the Basic product, the monthly revenue ranges from $500 to $28,000, with an average of $13,188 and a standard deviation of $8,123.76.	

The Expert product shows a wider range, with monthly revenue varying from $3,000 to $46,000. The average monthly revenue for the Expert product is $18,000, and the standard deviation is $13,796.13.	

Both products exhibit variability in monthly revenues, with the Expert product having a higher standard deviation, indicating greater fluctuation.	

**Most Successful Product:**	

In terms of average monthly revenue, the Expert product outperforms the Basic product, generating $18,000 on average compared to $13,188 for the Basic product.	

However, success can be defined differently based on specific business goals, such as market share, customer retention, or profit margins.	

**Fluctuation in Monthly Revenue:**	

Both products show variability in monthly revenue, but the Expert product has a higher standard deviation, indicating more significant fluctuations.	

The Basic product has a narrower range and a lower standard deviation, suggesting a more consistent month-to-month trend.	

### Suggestions for Further Improvement
1. **Stabilize Expert Product Revenue:**	

	Given the higher variability in monthly revenue for the Expert product, consider strategies to stabilize this revenue stream. This could involve identifying and addressing factors contributing to the fluctuations, such as seasonality or specific market conditions.	

2. **Enhance Basic Product Growth:**

	While the Basic product has a more consistent monthly trend, there might be opportunities to enhance its revenue growth. This could involve introducing new features, expanding the customer base, or exploring upselling opportunities.	

3. **Customer Segmentation and Targeting:**	

	Analyze customer segments to understand the preferences and needs of different customer groups. Tailor marketing strategies to target these segments effectively. For example, highlight the advanced features of the Expert product for customers seeking a more comprehensive solution.	

4. **Price Optimization:**	

	Evaluate the pricing strategy for both products. Consider whether adjustments are needed to align with customer perceptions of value. This could involve introducing different pricing tiers or promotions to attract a wider range of customers.

5. **Continuous Monitoring and Adaptation:**	

	Business environments evolve, and customer preferences change. Implement a system for continuous monitoring and adaptation to stay responsive to market dynamics. Regularly review product performance and customer feedback to inform ongoing improvements.	

6. **Customer Retention Strategies:**	

	Develop and implement strategies to enhance customer retention for both products. Customer loyalty programs, excellent customer support, and continuous product improvement can contribute to long-term customer relationships.

7. **Market Expansion:**	

	Explore opportunities for market expansion, either by targeting new customer segments or entering new geographic markets. Diversifying the customer base can provide a buffer against fluctuations in specific market segments.	

8. **Forecasting and Planning:**	

	Use the historical data to improve revenue forecasting and planning. This can help the leadership team set realistic annual goals and allocate resources effectively.	

By implementing these recommendations, your company can work towards optimizing both products, improving overall revenue stability, and ensuring sustained growth.


