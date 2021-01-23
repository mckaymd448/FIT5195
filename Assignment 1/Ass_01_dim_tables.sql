--/ Create required dimension tables for the spreadsheet.

--/ Create dateDim table by doing a union of the three tables with dates we want to include in the data warehouse.

SELECT DISTINCT
    to_char(m.member_start_date, 'yyyymm')        AS date_id,
    to_char(m.member_start_date, 'yyyy')          AS year,
    to_char(m.member_start_date, 'mm')            AS month
FROM
    mfit.membership m
UNION
SELECT DISTINCT
    to_char(t.emp_hired_date, 'yyyymm')        AS date_id,
    to_char(t.emp_hired_date, 'yyyy')          AS year,
    to_char(t.emp_hired_date, 'mm')            AS month
FROM
    mfit.trainer t
UNION
SELECT DISTINCT
    to_char(w.work_date, 'yyyymm')        AS date_id,
    to_char(w.work_date, 'yyyy')          AS year,
    to_char(w.work_date, 'mm')            AS month
FROM
    mfit.workout_session w
ORDER BY
    1;
    
--/ Create the client suburb dimension table, clientSubDim.

SELECT DISTINCT
    c.client_suburb,
    c.client_postcode
FROM
    mfit.client c
ORDER BY
    c.client_suburb;
    
--/ Create the membership dimension table, membershipDim.  Maybe we need to make this table manually.

SELECT DISTINCT
    m.membership_id,
    m.member_type
FROM
    mfit.membership m
ORDER BY
    m.membership_id;
    
--/ Create the training goal dimension table, goalDim.

SELECT DISTINCT
    ws.training_goal
FROM
    mfit.workout_session ws
ORDER BY
    ws.training_goal;
    
--/ Create the salary range dimension table, salaryDim.  Needs to be created manually.
