--/ The rank function displays the rank of a record. Its usage is as follow. To find the rank of the records in the time table is as follow:

SELECT
    time_year,
    time_month,
    RANK()
    OVER(
        ORDER BY time_year, time_month
    ) AS time_rank
FROM
    dw.time;

--/ Try the query below and compare the result with A.1. Investigate the purpose of using ‘+0’ in order by time_month.

SELECT
    time_year,
    time_month,
    RANK()
    OVER(
        ORDER BY time_year, time_month + 0
    ) AS time_rank
FROM
    dw.time;
    
--/ Display the row number of total charter hours used by each aircraft model in year 1996 (Hints: Use ROW_NUMBER() Over) 
--/ The results should look like as follows.    

SELECT
    cf.mod_code,
    cf.time_id,
    SUM(cf.tot_char_hours),
    ROW_NUMBER()
    OVER(
        ORDER BY SUM(cf.tot_char_hours)
    ) AS row_num
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
WHERE
    td.time_year = 1996
GROUP BY
    cf.mod_code,
    cf.time_id
ORDER BY
    SUM(cf.tot_char_hours);
    
--/ Display the ranking of total charter hours used by each aircraft model in year 1996(Hints: Use Dense_Rank() Over) 
--/ The results should look like as follows.

SELECT
    cf.mod_code,
    cf.time_id,
    SUM(cf.tot_char_hours),
    DENSE_RANK()
    OVER(
        ORDER BY SUM(cf.tot_char_hours)
    ) AS dense_rank
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
WHERE
    td.time_year = 1996
GROUP BY
    cf.mod_code,
    cf.time_id
ORDER BY
    SUM(cf.tot_char_hours);
    
--/ Display the ranking of total charter hours used by each aircraft model in year
--/ 1996 (Hints: Use Rank() Over) The results should look like as follows.

SELECT
    cf.mod_code,
    cf.time_id,
    SUM(cf.tot_char_hours),
    RANK()
    OVER(
        ORDER BY SUM(cf.tot_char_hours)
    ) AS rank
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
WHERE
    td.time_year = 1996
GROUP BY
    cf.mod_code,
    cf.time_id
ORDER BY
    SUM(cf.tot_char_hours);
    
--/ Modify the ranking in question A.6 above, where ranking based on Model, so that the results will look like this:

SELECT
    cf.mod_code,
    cf.time_id,
    SUM(cf.tot_char_hours),
    RANK()
    OVER(PARTITION BY cf.mod_code
         ORDER BY SUM(cf.tot_char_hours)
    ) AS rank_by_model
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
WHERE
    td.time_year = 1996
GROUP BY
    cf.mod_code,
    cf.time_id
ORDER BY
    cf.mod_code,
    SUM(cf.tot_char_hours);
    
--/ Display the ranking of each airplane model based on the yearly total fuel-used and the ranking of yearly total fuel-used by each airplane model, 
--/ and (Hints: use multiple partitioning ranking). 

SELECT
    td.time_year           AS time,
    cf.mod_code,
    SUM(cf.tot_fuel)       AS total,
    RANK()
    OVER(PARTITION BY td.time_year
         ORDER BY SUM(cf.tot_fuel) DESC
    )                      AS rank_by_year,
    RANK()
    OVER(PARTITION BY cf.mod_code
         ORDER BY SUM(cf.tot_fuel) DESC
    )                      AS rank_by_model
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
GROUP BY
    td.time_year,
    cf.mod_code
ORDER BY
    td.time_year ASC,
    SUM(cf.tot_fuel) DESC;
    
 --/ Using the rank function (nested within a sub query, because rank cannot exist in a where clause) display the mod_code and mod_name of the 
 --/ two airplanes that have the largest total fuel used.
 
SELECT
    *
FROM
    (
        SELECT
            cf.mod_code,
            md.mod_name,
            SUM(cf.tot_fuel)       AS total,
            RANK()
            OVER(
                ORDER BY SUM(cf.tot_fuel) DESC
            )                      AS myrank
        FROM
                 dw.charter_fact cf
            JOIN dw.model md ON cf.mod_code = md.mod_code
        GROUP BY
            cf.mod_code,
            md.mod_name
        ORDER BY
            SUM(cf.tot_fuel) DESC
    )
WHERE
    myrank <= 2;
    
--/ Using the Percent_Rank() function (nested within a sub query), display the
--/ time periods which had revenue in the top 10% of the months.

SELECT
    *
FROM
    (
        SELECT
            cf.time_id,
            SUM(cf.revenue)       AS total,
            PERCENT_RANK()
            OVER(
                ORDER BY SUM(cf.revenue)
            )                     AS percent_rank
        FROM
            dw.charter_fact cf
        GROUP BY
            cf.time_id
        ORDER BY
            SUM(cf.revenue) DESC
    )
WHERE
    percent_rank > 0.9;
    
--/ Use the cumulative aggregate to show the following results. We only need to show 1995 revenues 
--/ (Hints: Since we only display 1995 data, there is no PARTITION). 

SELECT
    cf.time_id,
    SUM(cf.revenue),
    SUM(SUM(cf.revenue))
    OVER(
        ORDER BY
            cf.time_id
        ROWS UNBOUNDED PRECEDING
    ) AS cummulate_rev
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
WHERE
    td.time_year = 1995
GROUP BY
    cf.time_id
ORDER BY
    cf.time_id;
    
--/ Redo question C.1 above, instead of using cumulative aggregate, use moving aggregate to show the following 
--/ results moving aggregate of 3 monthly. (Hints: Use ROWS 2 PRECEDING).

SELECT
    cf.time_id,
    SUM(cf.revenue),
    to_char(AVG(SUM(cf.revenue))
            OVER(
        ORDER BY
            cf.time_id
        ROWS 2 PRECEDING
            ),
            '999,999,999.99') AS cummulate_rev
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
WHERE
    td.time_year = 1995
GROUP BY
    cf.time_id
ORDER BY
    cf.time_id;
    
--/ Display the cumulative total fuel used based on the year, and another cumulative total used for each airplane model.

SELECT
    td.time_year           AS time,
    cf.mod_code,
    SUM(cf.tot_fuel)       AS total,
    SUM(SUM(cf.tot_fuel))
    OVER(PARTITION BY td.time_year
        ORDER BY
            cf.mod_code
        ROWS UNBOUNDED PRECEDING
    )                      AS cum_fuel_year,
    SUM(SUM(cf.tot_fuel))
    OVER(PARTITION BY cf.mod_code
        ORDER BY
            td.time_year
        ROWS UNBOUNDED PRECEDING
    )                      AS cum_fuel_mode
FROM
         dw.charter_fact cf
    JOIN dw.time td ON td.time_id = cf.time_id
GROUP BY
    td.time_year,
    cf.mod_code
ORDER BY
    td.time_year,
    cf.mod_code;