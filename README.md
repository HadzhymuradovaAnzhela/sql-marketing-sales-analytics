# SQL: Comprehensive Analysis of User Engagement and Email Metrics
### Comprehensive Analysis of User Engagement and Email Metrics by Top 10 Countries
[View SQL Query Code](./comprehensive_user_engagement.sql)  
This SQL enables simultaneous tracking of daily trends and regional performance, offering deep insights into account status and email funnel efficiency across different countries. By integrating window functions and ranking logic, the query automatically isolates the top 10 markets to focus on high-impact areas. 
### Regional Sales Performance and Account Verification Analysis
[View SQL Query Code](./revenue_and_user_engagement_by_continent.sql)   
This analysis provides an overview of sales performance across geographic regions and device types.The project focused  
on comparing user behavior in different parts of the world, specifically analyzing purchasing patterns and account verification rates.  
### Dynamic Email Engagement and Detailed Performance Analytics by Operating System
[View SQL Query Code](./email_engagement.sql)  
The query identifies and ranks the Top 10 global markets, providing a clear breakdown of Total Accounts and messaging volumes across different regions. It delivers a granular view of daily registration dynamics alongside key email performance metrics, such as Sent, Opened, and Visited messages. By consolidating account metadata with interaction data, the results highlight geographical leaders and the overall efficiency of the communication funnel.  
## Analysis Summary:
<img width="1120" height="770" alt="image" src="https://github.com/user-attachments/assets/b2509951-01dd-4d05-bfd4-4d9badea9d2d" />  
  <br>
  <br>
The query successfully identifies and ranks the Top 10 global markets, providing a clear breakdown of Total Accounts and messaging volumes across different regions. It delivers a granular view of daily registration dynamics alongside key email performance metrics, such as Sent, Opened, and Visited messages. By consolidating account metadata with interaction data, the results highlight geographical leaders and the overall efficiency of the communication funnel. This structured output enables data-driven decisions regarding regional market scale and user engagement levels.  
<br>
<br>
<img width="1476" height="553" alt="image" src="https://github.com/user-attachments/assets/957f34ac-c518-4afa-aea2-f132e14bce0c" />  
<br>
<br>
The Americas emerge as the leading market, driven by a balanced revenue split between mobile and desktop platforms. Despite significant variations in user volume across continents, the account verification rate remains stable at approximately 71-72%, indicating a consistent global registration process.  
<br>
<br>
<img width="1436" height="641" alt="image" src="https://github.com/user-attachments/assets/d5cde851-e88d-457b-963c-4d82c3b3f7bb" />  
<br>
<br>
The SQL View provides instant access to real-time data without the need for manual query execution. The dashboard enables quick monitoring of performance trends and tracking of current funnel metrics. This allows for rapid identification of conversion shifts and timely data-driven adjustments to the marketing strategy.  

## Main stages
- In this project, I utilized SQL to extract and analyze email metrics and user activity across various regions. This allowed me to investigate user engagement patterns and KPIs in dynamics, identifying key trends and the most active geographical areas.
- To focus on high-impact areas, I implemented ranking logic to isolate the Top 10 performing countries based on account volume. This allowed for a detailed investigation into geographical leaders.
- Finally, I connected the processed data to Looker Studio for intuitive visualizations, enabling a rapid review of major trends and confirming the code's analytical accuracy.
## Functions and Techniques
- CTEs and View
- Window Functions for Ranking(DENSE_RANK() OVER (ORDER BY SUM(account_cnt) OVER (PARTITION BY country) DESC) AS rank_accounts)
- Window Functions for Aggregation(SUM(CASE WHEN sp.device = 'desktop' THEN pr.price END) AS revenue_from_desktop)
- UNION, Left Join, Inner Join
- Temporal Grouping(DATE(EXTRACT(YEAR FROM full_sent_date), EXTRACT(MONTH FROM full_sent_date), 1) AS sent_month)



