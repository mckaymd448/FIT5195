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
    *
FROM
    trainerfact tf
    Join dateDim dd on dd.date_id = tf.hire_date_id
    Join salaryDim sd on tf.sal_range_id = sd.sal_range_id;