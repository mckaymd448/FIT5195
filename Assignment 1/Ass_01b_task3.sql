--/ Michael McKay
--/ Student No: 32270208
--/ Submitted: 12-Feb-2021

--/ Simple reports:

--/ Report 1.  Query to get a ranked list of which months had the most new members, and which postcode they were located in.
SELECT
    *
FROM
    (
        SELECT
            md.member_start_month      AS starting_month,
            cd.client_postcode         AS post_code,
            SUM(cf.client_total)       AS total_clients,
            RANK()
            OVER(
                ORDER BY SUM(cf.client_total) DESC
            )                          AS month_rank
        FROM
                 clientfact cf
            JOIN memberdim     md ON md.member_id = cf.member_id
            JOIN clientsubdim  cd ON cd.suburb_id = cf.suburb_id
        GROUP BY
            md.member_start_month,
            cd.client_postcode
        ORDER BY
            SUM(cf.client_total) DESC,
            md.member_start_month
    )
WHERE
    month_rank <= 3;
     
--/ Report 2 - Ranking member for length of membership.

SELECT
    dd.year,
    dd.month,
    md.member_type,
    SUM(membership_fee_total)     AS total_membership,
    to_char(PERCENT_RANK()
            OVER(PARTITION BY dd.year
                 ORDER BY SUM(cf.membership_fee_total)
            ),
            '9.999')              AS percent_rank
FROM
         clientfact cf
    JOIN memberdim  md ON md.member_id = cf.member_id
    JOIN datedim    dd ON dd.date_id BETWEEN md.member_start_year || md.member_start_month AND md.member_end_year || md.member_end_month
GROUP BY
    dd.year,
    dd.month,
    md.member_type
ORDER BY
    dd.year,
    dd.month,
    md.member_type;

--/ Reports with subtotals.     
--/ Report 3.  Sum of membership fee divided by month, year, suburb and membership type.  Subtotals for all dimension attributes.

SELECT
    decode(GROUPING(dd.month), 1, 'All Months', dd.month)                                AS month,
    decode(GROUPING(cd.suburb_id), 1, 'All Suburbs', cd.suburb_id)                       AS suburb,
    decode(GROUPING(md.member_type), 1, 'All Memberships', md.member_type)               AS member_type,
    SUM(cf.membership_fee_total)                                                         AS "total_membership_fee"
FROM
         clientfact cf
    JOIN memberdim     md ON cf.member_id = md.member_id
    JOIN clientsubdim  cd ON cf.suburb_id = cd.suburb_id
    JOIN datedim       dd ON dd.date_id BETWEEN md.member_start_year || md.member_start_month AND md.member_end_year || md.member_end_month
GROUP BY
    CUBE(dd.month,
         cd.suburb_id,
         md.member_type)
ORDER BY
    dd.month;
    
--/ Report 4.  Sum of membership fee divided by month, year, suburb and membership type.  Subtotals for suburb_id and member_type.

SELECT
    dd.month,
    decode(GROUPING(cd.suburb_id), 1, 'All Suburbs', cd.suburb_id)                       AS suburb,
    decode(GROUPING(md.member_type), 1, 'All Memberships', md.member_type)               AS member_type,
    SUM(cf.membership_fee_total)                                                         AS "total_membership_fee"
FROM
         clientfact cf
    JOIN memberdim     md ON cf.member_id = md.member_id
    JOIN clientsubdim  cd ON cf.suburb_id = cd.suburb_id
    JOIN datedim       dd ON dd.date_id BETWEEN md.member_start_year || md.member_start_month AND md.member_end_year || md.member_end_month
GROUP BY
    dd.month,
    CUBE(cd.suburb_id,
         md.member_type)
ORDER BY
    dd.month;
    
--/ Report 5.  Total workouts completed, divided by year, month and training goal.  Subtotals for All years, all months, and all goals.

SELECT
    decode(GROUPING(dd.year), 1, 'All years', dd.year)                                 AS year,
    decode(GROUPING(dd.month), 1, 'All months', dd.month)                              AS month,
    decode(GROUPING(gd.training_goal), 1, 'All goals', gd.training_goal)               AS goal,
    SUM(wf.workout_total)                                                              AS total_workouts
FROM
         workoutfact wf
    JOIN goaldim  gd ON wf.training_goal = gd.training_goal
    JOIN datedim  dd ON wf.work_date_id = dd.date_id
GROUP BY
    ROLLUP(dd.year,
           dd.month,
           gd.training_goal)
ORDER BY
    dd.year,
    dd.month;
    
--/ Report 6.  Total workouts completed, divided by year, month and training goal.  Subtotals for all training goals.

SELECT
    dd.year,
    dd.month,
    decode(GROUPING(gd.training_goal), 1, 'All goals', gd.training_goal)               AS goal,
    SUM(wf.workout_total)                                                              AS total_workouts
FROM
         workoutfact wf
    JOIN goaldim  gd ON wf.training_goal = gd.training_goal
    JOIN datedim  dd ON wf.work_date_id = dd.date_id
GROUP BY
    dd.year,
    dd.month,
    ROLLUP(gd.training_goal)
ORDER BY
    dd.year,
    dd.month;

--/ Reports with moving and cumulative aggregates    
--/ Report 7.  Total number of workout sessions and cumulative total number of workout sessions divided by year and training goal.  Only 'injury rehabilitation' shown.

SELECT
    dd.year,
    gd.training_goal,
    SUM(wf.workout_total)       AS total_workouts,
    SUM(SUM(wf.workout_total))
    OVER(
        ORDER BY
            dd.year
        ROWS UNBOUNDED PRECEDING
    )                           AS cumulative_total
FROM
         workoutfact wf
    JOIN goaldim  gd ON wf.training_goal = gd.training_goal
    JOIN datedim  dd ON wf.work_date_id = dd.date_id
WHERE
    gd.training_goal = 'Injury Rehabilitation'
GROUP BY
    dd.year,
    gd.training_goal
ORDER BY
    dd.year;
    
--/ Report 8.  Average new members signing up per month.

SELECT
    md.member_start_year,
    md.member_start_month,
    NVL(SUM(cf.client_total),0)        AS new_clients,
    to_char(AVG(NVL(SUM(cf.client_total),0))
            OVER(
        ORDER BY
            md.member_start_year, md.member_start_month
        ROWS 2 PRECEDING
            ),
            '999,999,999.99')   AS ave_new_clients
FROM
         clientfact cf
    JOIN memberdim md ON md.member_id = cf.member_id
GROUP BY
    md.member_start_year,
    md.member_start_month
ORDER BY
    md.member_start_year,
    md.member_start_month;

--/ Reports with Partitions.    
--/ Report 9.  Total membership fee generated, divided by year, month and member_type.  Rank given partitioned by member_ship type.

SELECT
    *
FROM
    (
        SELECT
            RANK()
            OVER(PARTITION BY md.member_type
                 ORDER BY SUM(cf.membership_fee_total) DESC
            )                                  AS rank,
            dd.year,
            dd.month,
            md.member_type,
            SUM(cf.membership_fee_total)       AS "total_membership_fee"
        FROM
                 clientfact cf
            JOIN memberdim     md ON cf.member_id = md.member_id
            JOIN clientsubdim  cd ON cf.suburb_id = cd.suburb_id
            JOIN datedim       dd ON dd.date_id BETWEEN md.member_start_year || md.member_start_month AND md.member_end_year || md.member_end_month
        GROUP BY
            dd.year,
            dd.month,
            md.member_type
        ORDER BY
            dd.year,
            dd.month
    )
WHERE
    rank <= 5
ORDER BY
    rank;