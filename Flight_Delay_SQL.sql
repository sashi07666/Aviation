USE aviation;                   

CREATE TABLE flights            
( 
YEAR INT NULL,
MONTH INT NULL,
DAY INT NULL,
DAY_OF_WEEK INT NULL,
AIRLINE VARCHAR(255) NULL,
FLIGHT_NUMBER INT NULL,
TAIL_NUMBER VARCHAR(255) NULL,
ORIGIN_AIRPORT VARCHAR(255) NULL,
DESTINATION_AIRPORT VARCHAR(255) NULL,
SCHEDULED_DEPARTURE VARCHAR(255) NULL,
DEPARTURE_TIME VARCHAR(255) NULL,
DEPARTURE_DELAY INT NULL,
TAXI_OUT INT NULL,
WHEELS_OFF VARCHAR(255) NULL,
SCHEDULED_TIME INT NULL,
ELAPSED_TIME INT NULL,
AIR_TIME INT NULL,
DISTANCE INT NULL,
WHEELS_ON VARCHAR(255) NULL,
TAXI_IN INT NULL,
SCHEDULED_ARRIVAL VARCHAR(255) NULL,
ARRIVAL_TIME VARCHAR(255) NULL,
ARRIVAL_DELAY INT NULL,
DIVERTED INT NULL,
CANCELLED INT NULL,
CANCELLATION_REASON VARCHAR(255) NULL,
AIR_SYSTEM_DELAY VARCHAR(255) NULL,
SECURITY_DELAY VARCHAR(255) NULL,
AIRLINE_DELAY VARCHAR(255) NULL,
LATE_AIRCRAFT_DELAY VARCHAR(255) NULL,
WEATHER_DELAY VARCHAR(255) NULL
);

LOAD DATA INFILE 'flights.csv' INTO TABLE flights             
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT * FROM flights;

SELECT COUNT(FLIGHT_NUMBER) FROM flights;

set autocommit = 0;
set sql_safe_updates = 0;

-- KPI 1 - weekday vs weekend total flights statistics
    
SELECT WEEKDAY_WEEKEND, count(FLIGHT_NUMBER) AS NO_OF_TOTAL_FLIGHTS FROM flights
GROUP BY WEEKDAY_WEEKEND;

-- KPI 2. Total no. of cancelled flights for JetBlue Airways on first date of every month

ALTER TABLE flights ADD COLUMN month_name VARCHAR(20);

SELECT month_name FROM flights;

UPDATE flights
SET month_name = CASE MONTH
                  WHEN 1 THEN 'Jan'
                  WHEN 2 THEN 'Feb'
                  WHEN 3 THEN 'Mar'
                  WHEN 4 THEN 'Apr'
                  WHEN 5 THEN 'May'
                  WHEN 6 THEN 'Jun'
                  WHEN 7 THEN 'Jul'
                  WHEN 8 THEN 'Aug'
                  WHEN 9 THEN 'Sep'
                  WHEN 10 THEN 'Oct'
                  WHEN 11 THEN 'Nov'
                  WHEN 12 THEN 'Dec'
                  ELSE 'Null'
                 END;
                                  
SELECT airlines.AIRLINE, flights.month_name, COUNT(flights.FLIGHT_NUMBER) AS total_cancelled
FROM flights
INNER JOIN airlines ON flights.AIRLINE = airlines.IATA_CODE
WHERE flights.Cancelled = 1
AND flights.Day = 1
AND airlines.AIRLINE = 'JetBlue Airways'
GROUP BY airlines.AIRLINE, flights.month_name;



--  KPI 3. Week wise, State wise and City wise statistics of delay of flights with airline details

ALTER TABLE flights ADD COLUMN WEEK_NUMBER VARCHAR(20);

UPDATE flights
SET WEEK_NUMBER = CONCAT('Week - ', WEEK(CONCAT(YEAR,'-',MONTH,'-',DAY), 1));

ALTER TABLE flights ADD COLUMN DEPARTURE_STATUS VARCHAR(20);

UPDATE flights
SET DEPARTURE_STATUS =
    CASE
        WHEN DEPARTURE_DELAY < 0 THEN 'Early'
        WHEN DEPARTURE_DELAY = 0 THEN 'On Time'
        WHEN DEPARTURE_DELAY > 0 THEN 'Delayed'
        ELSE NULL
    END;

ALTER TABLE flights ADD COLUMN ARRIVAL_STATUS VARCHAR(20);

UPDATE flights
SET ARRIVAL_STATUS =
    CASE
        WHEN ARRIVAL_DELAY < 0 THEN 'Early'
        WHEN ARRIVAL_DELAY = 0 THEN 'On Time'
        WHEN ARRIVAL_DELAY > 0 THEN 'Delayed'
        ELSE NULL
    END;
    
-- Week wise delay
    
SELECT airlines.AIRLINE, flights.WEEK_NUMBER, COUNT(flights.FLIGHT_NUMBER) AS No_of_delayed
FROM flights
INNER JOIN airlines ON flights.AIRLINE = airlines.IATA_CODE
WHERE flights.ARRIVAL_STATUS = 'Delayed' AND flights.DEPARTURE_STATUS = 'Delayed'
GROUP BY airlines.AIRLINE, flights.WEEK_NUMBER;

-- state wise delay

SELECT airlines.AIRLINE, airports.STATE, COUNT(flights.FLIGHT_NUMBER) AS No_of_delayed
FROM flights
INNER JOIN airlines ON flights.AIRLINE = airlines.IATA_CODE
INNER JOIN airports ON flights.ORIGIN_AIRPORT = airports.IATA_CODE
WHERE flights.DEPARTURE_STATUS = 'Delayed' AND flights.ARRIVAL_STATUS = 'Delayed'
GROUP BY airlines.AIRLINE, airports.STATE;


-- city wise delay

SELECT airlines.AIRLINE, airports.CITY, COUNT(flights.FLIGHT_NUMBER) AS No_of_delayed
FROM flights
INNER JOIN airlines ON flights.AIRLINE = airlines.IATA_CODE
INNER JOIN airports ON flights.ORIGIN_AIRPORT = airports.IATA_CODE
WHERE flights.DEPARTURE_STATUS = 'Delayed' AND flights.ARRIVAL_STATUS = 'Delayed'
GROUP BY airlines.AIRLINE, airports.CITY;


-- KPI 4. Number of airlines with no departure/arrival delay with distance covered between 2500 and 3000

SELECT airlines.AIRLINE, COUNT(flights.FLIGHT_NUMBER) AS No_delay
FROM flights
JOIN airlines ON airlines.IATA_CODE = flights.AIRLINE
WHERE flights.ARRIVAL_STATUS IN ('On Time', 'Early') AND flights.DEPARTURE_STATUS IN ('On Time', 'Early')
AND flights.DISTANCE BETWEEN 2500 AND 3000
GROUP BY airlines.AIRLINE;


























