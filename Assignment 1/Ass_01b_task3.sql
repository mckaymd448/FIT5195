--/ Simple reports:

--/ Query to get a ranked list of which months had the most new members, and which postcode they were located in.
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
    
--/ Query to get percentage of workout goal grouped by date.

SELECT
    dd.year,
    gd.training_goal,
    SUM(wf.workout_total)       AS num_workouts,
    to_char(PERCENT_RANK()
            OVER(
        ORDER BY SUM(wf.workout_total)
            ), '9.999')                 AS percent_rank
FROM
         workoutfact wf
    JOIN datedim  dd ON wf.work_date_id = dd.date_id
    JOIN goaldim  gd ON wf.training_goal = gd.training_goal
GROUP BY
    dd.year,
    gd.training_goal
ORDER BY
    SUM(wf.workout_total) DESC,
    dd.year,
    gd.training_goal;
    
--/ Training salary and date query.

SELECT
    dd.year,
    sd.sal_range_id,
    sd.sal_desc,
    SUM(tf.trainer_total)       AS total_trainers,
    to_char(PERCENT_RANK()
            OVER(
        ORDER BY SUM(tf.trainer_total)
            ), '9.999')                 AS percent_rank
FROM
         trainerfact tf
    JOIN datedim    dd ON dd.date_id = tf.hire_date_id
    JOIN salarydim  sd ON tf.sal_range_id = sd.sal_range_id
GROUP BY
    dd.year,
    sd.sal_range_id,
    sd.sal_desc
ORDER BY
    dd.year,
    sd.sal_range_id;
    
    
--/ 
SELECT
    dd.month,
    cd.suburb_id,
    md.member_type,
    SUM(cf.membership_fee_total) AS "total_membership_fee"
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