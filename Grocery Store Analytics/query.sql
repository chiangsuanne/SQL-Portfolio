# Select the unique identifiers of customers who bought products from the 'milk' category that cost more than $17 or ones from the 'butter' category that cost more than $9.

SELECT DISTINCT user_id
FROM 
	transactions
WHERE 
    id_product IN
	(SELECT 
	id_product 
	FROM 
	products_data_all
	WHERE 
	(category='milk' AND  price > 17) OR 
	(category='butter' AND price > 9)); 


# Calculate the ratio of prices of particular products to the average price of products sold from their categories at their stores

SELECT
    name AS product_name,
    name_store AS store_name,
    category,
    price AS product_price,
    price / AVG(price) OVER (PARTITION BY category, name_store) AS product_mul
FROM
    products_data_all
ORDER BY
    id_product;


# Find the share of each category in the total sales of each store for every day within the period June 1-6

SELECT 
    DISTINCT name_store AS STORE_NAME,
    CAST(date_upd AS date) AS SALE_DATE,
    category AS CATEGORY,
    SUM(price) OVER (PARTITION BY category, name_store, CAST(date_upd AS date)) * 100 / 
    SUM(price) OVER (PARTITION BY name_store, CAST(date_upd AS date)) AS PERCENT
FROM
    products_data_all
WHERE
    CAST(date_upd AS date) BETWEEN '2019-06-01' AND '2019-06-06'
ORDER BY
    CAST(date_upd AS date),
    name_store;


# Calculate the change in total revenue in each category and in the store in general after the sale of each product on June 2, 2019

SELECT 
    name_store,
    category,
    name,
    price,
    SUM(price) OVER (PARTITION BY category ORDER BY id_product ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS category_accum,
    SUM(price) OVER (PARTITION BY name_store ORDER BY id_product ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS store_accum
FROM
    products_data_all
WHERE
    name_store = 'Four' AND
    CAST(date_upd AS date) = '2019-06-02'
ORDER BY
    id_product;  


# Rank the price in each store and category on June 2, 2019

SELECT 
    DISTINCT name_store AS store_name,
    category,
    CAST(date_upd AS date) AS sale_date,
    name,
    price,
    RANK() OVER (PARTITION BY name_store, category ORDER BY price)
FROM
    products_data_all
WHERE
    CAST(date_upd AS date) = '2019-06-02'
ORDER BY 
    name_store,
    category, 
    price;
