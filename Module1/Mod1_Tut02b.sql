--/3.	Define the SQL statements for the implementation of the star schema.

CREATE TABLE pilotdim
    AS
        SELECT
            *
        FROM
            dw.pilot;

CREATE TABLE airplanedim
    AS
        SELECT
            *
        FROM
            dw.model;

CREATE TABLE timecharterdim
    AS
        SELECT DISTINCT
            to_char(char_date, 'YYYYMM')      AS time_id,
            to_char(char_date, 'MM')          AS month,
            to_char(char_date, 'YYYY')        AS year
        FROM
            dw.charter
        ORDER BY
            to_char(char_date, 'YYYYMM');

CREATE TABLE charterfact
    AS
        SELECT
            to_char(c.char_date, 'YYYYMM')                AS time_id,
            a.mod_code,
            c.char_pilot                                  AS emp_num,
            SUM(c.char_hours_flown)                       AS hourstotal,
            SUM(c.char_fuel_gallons)                      AS fueltotal,
            SUM(c.char_distance * m.mod_chg_mile)         AS revenuetotal
        FROM
                 dw.charter c
            JOIN dw.aircraft    a ON c.ac_number = a.ac_number
            JOIN dw.model       m ON a.mod_code = m.mod_code
        GROUP BY
            to_char(c.char_date, 'YYYYMM'),
            a.mod_code,
            c.char_pilot;
            
--/  4.	Write the SQL statements to produce the following reports:
--/    a.	Show the total revenue each year

SELECT
    td.year,
    SUM(cf.revenuetotal) AS "Total Revenue"
FROM
         charterfact cf
    JOIN timecharterdim td ON td.time_id = cf.time_id
GROUP BY
    td.year
ORDER BY
    td.year;

--/    b.	Show the total hours flown by each pilot

SELECT
    cf.emp_num,
    SUM(cf.hourstotal) AS "Total Hours"
FROM
         charterfact cf
         
GROUP BY
    cf.emp_num
   ORDER BY
    cf.emp_num;

--/    c.	Show the total fuel used by each aircraft model

SELECT
    cf.mod_code,
    md.mod_name,
    SUM(cf.fueltotal) AS "Total Fuel"
FROM
         charterfact cf
         Join airplaneDim md on md.mod_code = cf.mod_code
GROUP BY
    cf.mod_code,
    md.mod_name
   ORDER BY
    cf.mod_code;