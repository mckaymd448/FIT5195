--/ Create dimension table clientSubDim.

DROP TABLE clientsubdim CASCADE CONSTRAINTS;

CREATE TABLE clientsubdim
    AS
        SELECT DISTINCT
            c.client_suburb AS suburb_id,
            c.client_postcode
        FROM
            client_cleaned c
        ORDER BY
            c.client_suburb;
            
--/ Create dimension table memberDim.

DROP TABLE memberdim CASCADE CONSTRAINTS;

CREATE TABLE memberdim
    AS
        SELECT DISTINCT
            m.member_type
            || '-'
            || to_char(m.member_start_date, 'yyyymm')
            || '-'
            || to_char(m.member_end_date, 'yyyymm')         AS member_id,
            m.member_type,
            to_char(m.member_start_date, 'mm')              AS member_start_month,
            to_char(m.member_start_date, 'yyyy')            AS member_start_year,
            to_char(m.member_end_date, 'mm')                AS member_end_month,
            to_char(m.member_end_date, 'yyyy')              AS member_end_year
        FROM
            membership m
        ORDER BY
            m.member_type
            || '-'
            || to_char(m.member_start_date, 'yyyymm')
            || '-'
            || to_char(m.member_end_date, 'yyyymm');
       
       
--/ Create dimension table memberDim.

DROP TABLE datedim CASCADE CONSTRAINTS;

CREATE TABLE datedim
    AS
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

--/ Create dimension table goalDim.

DROP TABLE goaldim CASCADE CONSTRAINTS;

CREATE TABLE goaldim
    AS
        SELECT DISTINCT
            ws.training_goal
        FROM
            workout_session ws
        ORDER BY
            ws.training_goal;
            
--/ Create dimension table salaryDim.
            
DROP TABLE salarydim CASCADE CONSTRAINTS;

CREATE TABLE salarydim (
    sal_range_id  NUMBER(1, 0),
    sal_desc      VARCHAR2(15),
    sal_lower     NUMBER(6, 0),
    sal_upper     NUMBER(6, 0)
);

INSERT INTO salarydim VALUES (
    1,
    'Low',
    0,
    74999
);

INSERT INTO salarydim VALUES (
    2,
    'Medium',
    75000,
    100000
);

INSERT INTO salarydim VALUES (
    3,
    'High',
    100001,
    999999
);

COMMIT;

--/ Create the fact table, clientFact.

DROP TABLE clientfact CASCADE CONSTRAINTS;

CREATE TABLE clientfact
    AS
        SELECT
            m.member_type
            || '-'
            || to_char(m.member_start_date, 'yyyymm')
            || '-'
            || to_char(m.member_end_date, 'yyyymm')         AS member_id,
            c.client_suburb                                 AS suburb_id,
            COUNT(c.client_id)                              AS client_total,
            SUM(m.monthly_fee)                              AS membership_fee_total
        FROM
                 client_cleaned c
            JOIN membership m ON m.client_id = c.client_id
        GROUP BY
            m.member_type
            || '-'
            || to_char(m.member_start_date, 'yyyymm')
            || '-'
            || to_char(m.member_end_date, 'yyyymm'),
            c.client_suburb;
    
--/ Create the fact table, workoutFact.

DROP TABLE workoutfact CASCADE CONSTRAINTS;

CREATE TABLE workoutfact
    AS
        SELECT
            to_char(ws.work_date, 'yyyymm')        AS work_date_id,
            ws.training_goal,
            COUNT(ws.session_id)                   AS workout_total
        FROM
            mfit.workout_session ws
        GROUP BY
            to_char(ws.work_date, 'yyyymm'),
            ws.training_goal;
            
--/ create the temp trainer information table, tempTrainerFact.
DROP TABLE temptrainerfact CASCADE CONSTRAINTS;

CREATE TABLE temptrainerfact
    AS
        SELECT
            t.emp_salary,
            to_char(t.emp_hired_date, 'yyyymm')        AS hire_date_id,
            COUNT(t.emp_id)                            AS trainer_total
        FROM
            mfit.trainer t
        GROUP BY
            t.emp_salary,
            to_char(t.emp_hired_date, 'yyyymm');

ALTER TABLE temptrainerfact ADD (
    sal_range_id NUMBER(1, 0)
);

UPDATE temptrainerfact
SET
    sal_range_id = 1
WHERE
    emp_salary < 75000;

UPDATE temptrainerfact
SET
    sal_range_id = 2
WHERE
        emp_salary >= 75000
    AND emp_salary <= 100000;

UPDATE temptrainerfact
SET
    sal_range_id = 3
WHERE
    emp_salary > 100000;

COMMIT;

--/ create the trainer information table, trainerFact from tempTrainerFact.
DROP TABLE trainerfact CASCADE CONSTRAINTS;

CREATE TABLE trainerfact
    AS
        SELECT
            t.sal_range_id,
            t.hire_date_id,
            t.trainer_total
        FROM
            temptrainerfact t
        ORDER BY
            t.hire_date_id;
            
--/ How many workout sessions were offered in November 2019?

SELECT
    SUM(wf.workout_total) AS "Total Workouts"
FROM
         workoutfact wf
    JOIN datedim dd ON wf.work_date_id = dd.date_id
WHERE
        dd.month = 11
    AND dd.year = 2019;

--/ How much is the total membership fee for Gold membership in October 2018?

SELECT
    SUM(cf.membership_fee_total) AS "Total Membership fee"
FROM
         clientfact cf
    JOIN memberdim md ON cf.member_id = md.member_id
WHERE
        upper(md.member_type) = 'GOLD'
    AND md.member_start_month <= 08
    AND md.member_start_year <= 2018
    AND md.member_end_month >= 08
    AND md.member_end_year >= 2018;

--/ How many Bronze clients live in Clayton?

SELECT
    nvl(COUNT(cf.client_total), 0) AS "Number of clients"
FROM
         clientfact cf
    JOIN memberdim     md ON cf.member_id = md.member_id
    JOIN clientsubdim  sd ON cf.suburb_id = sd.suburb_id
WHERE
        upper(md.member_type) = 'BRONZE'
    AND upper(sd.suburb_id) = 'CLAYTON';
    
--/ How many trainers are paid on a high salary scale in 2018?

SELECT
    SUM(tf.trainer_total) AS "Number of trainers"
FROM
         trainerfact tf
    JOIN salarydim  sd ON tf.sal_range_id = sd.sal_range_id
    JOIN datedim    dd ON tf.hire_date_id = dd.date_id
WHERE
        dd.year <= 2018
    AND upper(sd.sal_desc) = 'HIGH';

--/ What was the most popular training goal in December?

SELECT
    gd.training_goal,
    SUM(wf.workout_total) AS "Number of workouts"
FROM
         workoutfact wf
    JOIN goaldim  gd ON gd.training_goal = wf.training_goal
    JOIN datedim  dd ON dd.date_id = wf.work_date_id
WHERE
    dd.month = 12
GROUP BY
    gd.training_goal
ORDER BY
    SUM(wf.workout_total) DESC
FETCH FIRST 1 ROWS ONLY;

--/ Which suburb has the most number of clients?

SELECT
    cd.suburb_id,
    SUM(cf.client_total) AS "Total Number"
FROM
         clientfact cf
    JOIN clientsubdim cd ON cd.suburb_id = cf.suburb_id
GROUP BY
    cd.suburb_id
ORDER BY
    SUM(cf.client_total) DESC
FETCH FIRST 1 ROWS ONLY;

--/ How many trainers were hired in June 2018?

SELECT
    Sum(trainer_total) as "Number hired"
FROM
         trainerfact tf
    JOIN datedim dd ON tf.hire_date_id = dd.date_id
WHERE
        dd.month = 06
    AND dd.year = 2018;