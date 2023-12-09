## Data scheme	
![image](https://github.com/chiangsuanne/SQL-Portfolio/assets/108243961/41fa9399-4efa-46f3-a9b1-104498f7b592)	

### Objective
A marketing manager wants to understand the performance of their recent email campaign. After the campaign launch, the marketing manager wants to know how many users have clicked the link in the email.   

Tracking events located in the FrontendEventLog table, is logged when the user reaches a unique landing page that is only accessed from this campaign email.    
Since an overall aggregate metric like an average can hide outliers and further insights under the hood, it's best to calculate distribution of the number of email link clicks per user.    

**Query**
```sql
WITH email_link_clicks as (
    SELECT
        COUNT(EventID) as num_link_clicks,
        UserID
    FROM FrontendEventLog
    WHERE EventID = 5
    GROUP BY UserID
)

SELECT 
    num_link_clicks,
    COUNT(UserID) as num_users
FROM email_link_clicks
GROUP BY num_link_clicks;
````
**Output**    
| NUM_LINK_CLICKS | NUM_USERS |
|-----------------|-----------|
| 1               | 3         |
| 2               | 2         |
| 3               | 1         |    
