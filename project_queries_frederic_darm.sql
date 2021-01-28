/* Query 1 - query used for first insight */
SELECT CONCAT(rental_month, ' - ', rental_year) date, store, count_rentals
FROM
  (SELECT DATE_PART('month', r.rental_date) rental_month,
       DATE_PART('year', r.rental_date) rental_year,
       st.store_id store,
       COUNT(*) count_rentals
   FROM store AS st
   JOIN staff AS sta ON st.store_id = sta.store_id
   JOIN rental AS r ON sta.staff_id = r.staff_id
   GROUP BY 1,
            2,
            3
   ORDER BY 4 DESC) sub_table;



/*Query 2 - query used for second insight*/
WITH final_payment_data AS
  (SELECT DATE_TRUNC('month', p.payment_date) pay_mon,
    CONCAT(c.first_name,' ', c.last_name) fullname,
    COUNT(p.amount) pay_countpermon, SUM(p.amount) pay_amount
   FROM customer c
   JOIN payment p ON c.customer_id = p.customer_id
   WHERE CONCAT(c.first_name,' ', c.last_name) IN
       (SELECT fullname
        FROM
          (SELECT CONCAT(c.first_name,' ', c.last_name) fullname, SUM(p.amount) pay_amount
           FROM customer c
           JOIN payment p ON c.customer_id = p.customer_id
           GROUP BY 1
           ORDER BY 2 DESC LIMIT 10) top_ten_table)
   AND (p.payment_date BETWEEN '2007-01-01' AND '2008-01-01')
   GROUP BY 1, 2)

SELECT ROW_NUMBER() OVER(PARTITION BY fullname
                         ORDER BY pay_mon, pay_countpermon) AS ROW,
       pay_mon,
       fullname,
       pay_countpermon,
       pay_amount
FROM final_payment_data;



/*Query 3 - query used for third insight*/
SELECT name,
       COUNT(*) rentals,
       COUNT(DISTINCT customer) distinct_customers
FROM
  (SELECT c.name AS name,
           r.customer_id AS customer
   FROM category AS c
   JOIN film_category AS fc ON c.category_id = fc.category_id
   JOIN film AS f ON f.film_id = fc.film_id
   JOIN inventory AS i ON fc.film_id = i.film_id
   JOIN rental AS r ON r.inventory_id = i.inventory_id
   ORDER BY 1) sub_table
GROUP BY 1
ORDER BY 2 DESC;



/*Query 4 - query used for fourth insight*/
WITH setup AS
  (SELECT CONCAT(c.first_name,' ', c.last_name) fullname,
                                                ca.name cat_name,
                                                        COUNT(*) quantity
   FROM customer c
   JOIN rental r ON c.customer_id = r.customer_id
   JOIN inventory i ON i.inventory_id = r.inventory_id
   JOIN film f ON f.film_id = i.film_id
   JOIN film_category fc ON fc.film_id= f.film_id
   JOIN category ca ON ca.category_id = fc.category_id
   GROUP BY 1,
            2
   ORDER BY 3 DESC)

SELECT ROW_NUMBER() OVER(PARTITION BY fullname
                         ORDER BY quantity DESC, cat_name) AS ROW,
       fullname,
       cat_name,
       quantity
FROM setup
WHERE fullname IN('Aaron Selby');
