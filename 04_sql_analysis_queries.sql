
--What are the different payment methods and how many transactions and items were sold with each method?

SELECT
payment_method,
COUNT(DISTINCT invoice_id) AS total_transactions,SUM(quantity) AS items_sold FROM walmart_sales
GROUP BY payment_method;

--Which category received the highest average rating in each branch?
select Branch,category,avg_rating from(
select Branch,category,round(avg(rating)::numeric,2)as avg_rating,
ROW_NUMBER() over(partition by Branch order by avg(rating) desc ) as rnk from walmart_sales
group by Branch,category
)t
where rnk=1;

-- What is the busiest day of the week for each branch based on transaction volume?
SELECT branch,day_name,no_transactions
FROM (SELECT branch,TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'FMDay') AS day_name,
COUNT(*) AS no_transactions,RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
FROM walmart_sales GROUP BY branch, day_name) t
WHERE rnk = 1;

--How many items were sold through each payment method
SELECT payment_method,SUM(quantity) AS items_sold FROM walmart_sales
GROUP BY payment_method ORDER BY items_sold DESC;

--What are the average, minimum, and maximum ratings for each category in each city?
SELECT city,category,ROUND(AVG(rating)::NUMERIC, 2) AS avg_rating,
MIN(rating) AS min_rating,MAX(rating) AS max_rating
FROM walmart_sales GROUP BY city, category ORDER BY city, category;

--What is the total profit for each category, ranked from highest to lowest?
SELECT category,ROUND(SUM(total * profit_margin)::NUMERIC,2) AS total_profit
FROM walmart_sales GROUP BY category ORDER BY total_profit DESC;

--What is the most frequently used payment method in each branch?
SELECT branch,payment_method,usage_count
FROM ( SELECT branch,payment_method,COUNT(*) AS usage_count,
ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
FROM walmart_sales GROUP BY branch, payment_method
) t
WHERE rnk = 1;

--How many transactions occur in each shift (Morning, Afternoon, Evening)across branches?
SELECT branch,
    CASE 
        WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening' END AS day_time,
COUNT(DISTINCT invoice_id) AS transactions
FROM walmart_sales GROUP BY branch, day_time ORDER BY branch, transactions DESC;