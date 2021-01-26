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

INSERT INTO salarydim VALUES (1,'Low',0,74999);

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
