-- list the cities in which there is no flight from moscow --
select distinct (city) ->> 'en' as city
from airports
where city ->> 'en' != 'Moscow'

-- select airports where the time zone is in Asia/Novokuznetsk and Asia/Krasnoyarsk
select airport_name ->> 'en' as airport_name
from airports
where timezone in ('Asia/Novokuznetsk', 'Asia/Krasnoyarsk')
order by 1

--- Get model, range and miles of every aircraft that exists in the airlines database, notice that miles = range/1.609 and round the result to 2 numbers after the float point.
select model ->> 'en' as model, range, round(range/1.609, 2) as mile
from aircrafts

-- Return all information about aircraft that has aircraft_code SU9 and its range in miles
select aircraft_code, round((range/1.609), 2) as Miles
from aircrafts
where aircraft_code = 'SU9'

--- Calculate the average tickets sales
select round(avg(total_amount), 2) as average_ticket_sales
from ticket_flights

-- return all the number of seats in the aircraft that has aircraft code = 'CN1'
select count(seat_no) as number_of_seats
from seats
where aircraft_code = 'CN1' 

--- Return the number of seats in the aircraft that aircraft code = 'SU9'
select count(seat_no) as number_of_seats
from seats
where aircraft_code = 'SU9'

--- Write a query to return the aircraft_code and the number of seats of each aircraft ordered ascending
select aircraft_code, count(seat_no) as number_of_seats
from seats
group by 1
order by 2 asc

--- calculate the number of seats in the salons for all aircraft models, but now taking into account the clas of service (business and economic class)
select aircraft_code, fare_conditions, count(*)
from seats
group by 1,2
order by 1,2

--- which day has the least booking amount
SELECT date FROM(
				SELECT date(book_date),
				RANK() OVER(PARTITION BY  SUM(total_amount) ORDER BY date(book_date) DESC ) as rank
				FROM bookings
				GROUP BY 1
	) as f

-- or  

SELECT Date(book_date), sum(total_amount)
from bookings
group by 1
ORDER BY 2 ASC
LIMIT 1

-- Determine how many flights from each city to other cities, return the name of the city and count of flights more than 50, order the data from largest no_ of flights to the least
select a.city ->> 'en' as city, count(f.flight_id) as number_of_flights
from airports as a
inner join flights as f
on a.airport_code = f.departure_airport
group by 1
having count(f.flight_id) > 50
order by 2 desc

-- return all flights details in the indicated day 2017-08-28 include flight count ascending order,departure count, time of departure and arrival time
select flight_no, scheduled_departure :: time as dep_time, scheduled_arrival :: time as arrival_time,departure_airport as departures, arrival_airport as arrival, count(flight_id) as No_of_flight
from flights
where scheduled_departure >= '2017-08-28' ::date and scheduled_departure < '2017-08-29' ::date
group by 1,2,3,4,5
order by 4 asc

--- write a query to arrange the range of models of aircrafts, so short range is than 2000. Middle range is more than 2000 and less than 5000 and any range above 5000 is long range
select model ->> 'en' as models, range, case when range < 2000 then 'short range'
				when range > 2000 and range < 5000 then 'middle range'
				when range > 5000 then 'long range' end as range_category
from aircrafts

-- what is the shortest flight duration for each possible flight from Moscow to St. Petersburg, and how many times was the flight delayed for more than an hour
select f.flight_no, (f.scheduled_arrival - f.scheduled_departure) as scheduled_duration, min(f.scheduled_arrival - f.scheduled_departure), max(f.scheduled_arrival - f.scheduled_departure), sum(case when f.actual_departure > f.scheduled_departure + interval '1 hour' then 1 else 0 end) as delays
from flights f
where (select city ->> 'en' from airports where airport_code = departure_airport) = 'Moscow' and (select city ->> 'en' from airports where airport_code = arrival_airport) = 'St. petersburg' and f.status = 'arrived'
group by 1, (f.scheduled_arrival - f.scheduled_departure)

-- who travlled from Moscow(SVO) to Novosibirsk(OVB) on seat 1A, and when was the ticket booked?
select t.passenger_name, b.book_date, bp.seat_no
from bookings b
join tickets as t
on b.book_ref = t.book_ref
join boarding_passes as bp
on t.ticket_no = bp.ticket_no
join flights as f
on f.flight_id = bp.flight_id
where departure_airport = 'SVO' and arrival_airport = 'OVB' and bp.seat_no = '1A' and f.scheduled_departure::date = public.now()::date - interval '2 day'

-- find the most disciplined passengers who checked in  first for all thier flights, take into account only those passengers who took atleast two flights

select t.passenger_name, t.ticket_no
from tickets as t
join boarding_passes as bp
on t.ticket_no = bp.ticket_no
group by 1, 2
having max(bp.boarding_no) = 1 and count(*) > 1

--- calculate the number of passengers and number of flights departing from one airport (SVO) during each hour on 2017 - 08 -02
select date_part('hour', f.scheduled_departure) as hour, count(distinct(tf.ticket_no)) as number_of_passengers, count(distinct(f.flight_id)) as flight_count 
from ticket_flights as tf
join flights as f
on tf.flight_id = f.flight_id
where  f.departure_airport = 'SVO' and f.scheduled_departure >= '2017-08-02'::date and f.scheduled_departure < '2017-08-03'::date
group by 1
order by 1 asc

