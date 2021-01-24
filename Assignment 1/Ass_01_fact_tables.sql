--/ query to created the fact table, clientFact.

SELECT
    m.member_type,
    c.client_suburb                               AS "suburb_id",
    to_char(m.member_start_date, 'yyyymm')        AS "start_date_id",
    to_char(m.member_end_date, 'yyyymm')          AS "end_date_id",
    COUNT(c.client_id)                            AS "client_total",
    SUM(m.monthly_fee)                            AS "membership_fee_total"
FROM
         mfit.client c
    JOIN mfit.membership m ON m.client_id = c.client_id
GROUP BY
    m.member_type,
    c.client_suburb,
    to_char(m.member_start_date, 'yyyymm'),
    to_char(m.member_end_date, 'yyyymm');
    
--/ query for clientFact with no grouping by date.

SELECT
    m.member_type,
    c.client_suburb          AS "suburb_id",
    COUNT(c.client_id)       AS "client_total",
    SUM(m.monthly_fee)       AS "membership_fee_total"
FROM
         mfit.client c
    JOIN mfit.membership m ON m.client_id = c.client_id
GROUP BY
    m.member_type,
    c.client_suburb;
    
--/ create the workout fact table, workoutFact.

SELECT
    to_char(ws.work_date, 'yyyymm')        AS "work_date_id",
    ws.training_goal,
    COUNT(ws.session_id)                   AS "workout_total"
FROM
    mfit.workout_session ws
GROUP BY
    to_char(ws.work_date, 'yyyymm'),
    ws.training_goal;
    
--/ create the trainer information table, trainerFact.
SELECT
    t.emp_salary,
    to_char(t.emp_hired_date, 'yyyymm')        AS "hire_date_id",
    COUNT(t.emp_id)                            AS "trainer_total"
FROM
    mfit.trainer t
GROUP BY
    t.emp_salary,
    to_char(t.emp_hired_date, 'yyyymm');
    
--/ create the workout fact table, workoutFact, with client information

Drop 
CREATE TABLE workoutclientfact
    AS
        SELECT
            to_char(ws.work_date, 'yyyymm')        AS "work_date_id",
            ws.training_goal,
            c.client_id,
            COUNT(ws.session_id)                   AS "workout_total"
        FROM
                 mfit.workout_session ws
            JOIN mfit.class c ON ws.session_id = c.session_id
        GROUP BY
            to_char(ws.work_date, 'yyyymm'),
            ws.training_goal,
            c.client_id;

SELECT
    wf.client_id,
    wf.training_goal,
    SUM(wf."workout_total") AS workouts
FROM
    workoutclientfact wf
WHERE
    wf.training_goal = 'Weight Loss'
GROUP BY
    client_id,
    training_goal;