--select * from album;

--Who is the senior most employee based on the job title?
--select * from employee order by levels DESC LIMIT 1;

--Q2 Which countries have the most Invoices
select count(*) as total_invoice , billing_country from invoice group by billing_country ORDER by  total_invoice DESC;

-- Q3 What are top 3 values of total invoice

SELECT total from invoice order by total desc LIMIT 3 ;

--Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--totals

select sum(total) as invoice_total, billing_city from invoice GROUP by billing_city ORDER by invoice_total DESC ;

-- Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money
 
select customer.customer_id, customer.first_name, customer.last_name , sum(invoice.total) as total 
from customer 
JOIN invoice on customer.customer_id = invoice.customer_id
GROUP by customer.customer_id
ORDER by total DESC
LIMIT 1;

--Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT email, first_name, last_name
from customer
JOIN invoice on customer.customer_id = invoice.customer_id
JOIN invoice_line on invoice.invoice_id = invoice_line.invoice_id
WHERE track_id in(
  		SELECT track_id from track
        join genre on track.genre_id = genre.genre_id
        WHERE genre.name LIKE 'Rock'
)
ORDER by email;

--Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands

select artist.artist_id, artist.name , COUNT(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
JOIN artist on artist.artist_id = album.artist_id
JOIN genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP by artist.artist_id
ORDER by number_of_songs DESC
LImit 10;

--Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first

SELECT name, milliseconds
from track
WHERE milliseconds>(
	SELECT avg(milliseconds) as avg_track_length
    from track)
ORDER by milliseconds desc;

--Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

with best_selling_artist as (
  SELECT artist.artist_id as artist_id, artist.name as artist_name, 
  sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
  from invoice_line
  join track on track.track_id = invoice_line.track_id
  join album on album.album_id = track.album_id
  join artist on artist.artist_id = album.artist_id
  GROUP by 1
  ORDER by 3 DESC
  LIMIT 1
);

--We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres

with popular_gener AS
(
  select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
  row_number() over(partition by customer.country order by count(invoice_line.quantity) DESC) as RowNo
  from invoice_line
  join invoice on invoice.invoice_id = invoice_line.invoice_id
  join customer on customer.customer_id = invoice.customer_id
  join track on track.track_id = invoice_line.track_id
  join genre on genre.genre_id = track.genre_id
  GROUP by 2,3,4
  ORDER by 2 ASC, 1 DESC
)
select * from popular_gener where RowNo <= 1;


--Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount

with RECURSIVE
     customer_with_country as (
       SELECT customer.customer_id, first_name, last_name, billing_country ,
       sum(total) as total_spending
       from invoice
       join customer on customer.customer_id = invoice.customer_id
       GROUP by 1,2,3,4
       ORDER by 2,3 DESC
  ),
  country_max_spending AS(
    SELECT billing_country, max(total_spending) as max_spending
    from customer_with_country
    group by billing_country
    )
 
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
ORDER by 1;