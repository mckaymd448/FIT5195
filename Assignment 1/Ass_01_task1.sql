--/ Copy required tables from the MFit folder.

DROP TABLE branch CASCADE CONSTRAINTS;

CREATE TABLE branch
    AS
        SELECT
            *
        FROM
            mfit.branch;

DROP TABLE class CASCADE CONSTRAINTS;

CREATE TABLE class
    AS
        SELECT
            *
        FROM
            mfit.class;

DROP TABLE client CASCADE CONSTRAINTS;

CREATE TABLE client
    AS
        SELECT
            *
        FROM
            mfit.client;

DROP TABLE membership CASCADE CONSTRAINTS;

CREATE TABLE membership
    AS
        SELECT
            *
        FROM
            mfit.membership;

DROP TABLE trainer CASCADE CONSTRAINTS;

CREATE TABLE trainer
    AS
        SELECT
            *
        FROM
            mfit.trainer;

DROP TABLE trains CASCADE CONSTRAINTS;

CREATE TABLE trains
    AS
        SELECT
            *
        FROM
            mfit.trains;

DROP TABLE workout_session CASCADE CONSTRAINTS;

CREATE TABLE workout_session
    AS
        SELECT
            *
        FROM
            mfit.workout_session;
            
--/ Checking branch for duplicate values.

SELECT
    *
FROM
    branch b;

--/ No duplicates found.  A null value has been found for this (branch 5).  This is error 1.  Should check if is it referenced in trainer table.  If not, is OK to delete.

SELECT
    *
FROM
    trainer t
WHERE
    t.branch_id = 5;
    
--// branch 5 never referred to in datatable.  Can delete from the branch table.

DELETE FROM branch
WHERE
    upper(branch_name) = 'UNKNOWN';

COMMIT;

--/ Check to make sure manager assignment for branch matches the trainer table.

SELECT
    *
FROM
         branch b
    JOIN trainer t ON b.manager_id = t.emp_id
                      AND b.branch_id = t.branch_id;
                           
--/ No mismatches.

--/ Checking class for errors.  Checking to see if any entries for calories burned that don't have a value entered.

SELECT
    *
FROM
    class b
WHERE
    b.calories_burned IS NULL
ORDER BY
    b.session_id,
    b.client_id;

--/ No null values found.  Checking for duplicate values, two primary key values are been concatinated into one attribute.

SELECT
    c.session_id
    || '-'
    || c.client_id       AS pk,
    COUNT(c.session_id
          || '-'
          || c.client_id)      AS pk_count
FROM
    class c
GROUP BY
    c.session_id
    || '-'
    || c.client_id
HAVING
    COUNT(c.session_id
          || '-'
          || c.client_id) > 1;

--/ No duplicate entries found.  Checking to see if any values where the number of calories burnt is a negative number.  This value needs to be positive.

SELECT
    *
FROM
    class b
WHERE
    b.calories_burned < 0
ORDER BY
    b.session_id,
    b.client_id;
    
--/ -40 calories burnt for session id 155.  Error 2.  Leaving error in as it doesn't affect our Data warehouse.

--/ Checking client for error.  Looking for duplicate entries.

SELECT
    c.client_id,
    COUNT(c.client_id) AS "num_entries"
FROM
    client c
GROUP BY
    c.client_id
HAVING
    COUNT(c.client_id) > 1;
    
--/ Duplicate entries found.  Client ID inserted 4 times.  Error 3.  Will fix by creating a new table from this with a distinct function included.

DROP TABLE client_cleaned CASCADE CONSTRAINTS;

CREATE TABLE client_cleaned
    AS
        SELECT DISTINCT
            *
        FROM
            client;

--/ Checking to see if duplicate entries remain.

SELECT
    c.client_id,
    COUNT(c.client_id) AS "num_entries"
FROM
    client_cleaned c
GROUP BY
    c.client_id
HAVING
    COUNT(c.client_id) > 1;
    
--/ Duplicate entries gone now.

--/ Checking membership for errors.  Checking for duplicate entries.

SELECT
    m.membership_id,
    COUNT(m.membership_id) AS "num_entries"
FROM
    mfit.membership m
GROUP BY
    m.membership_id
HAVING
    COUNT(m.membership_id) > 1;
    
--/ No duplicate values.  Checking if any membership values have a end date before the starting date.
SELECT
    m.membership_id,
    ( m.member_end_date - m.member_start_date ) AS date_difference
FROM
    membership m;
WHERE
    ( m.member_end_date - m.member_start_date ) < 0;
     
--/ membership 114 and 116 have end dates before the start dates.  Error 4.  Will leave in as we don't know what the proper end date should be.  
--/ Check to see if all memberships have an entry in the client table.

SELECT
    *
FROM
    membership m
WHERE
    m.client_id NOT IN (
        SELECT
            client_id
        FROM
            client
    );
    
--/ Membership id 115 does not have an entry in the client table.  Error 5.  Client may not longer be a member.  Will remove from membership table.
DELETE FROM membership WHERE client_id NOT
in

( SELECT
    client_id
FROM
    client
);

COMMIT;

--/ Check the trainer table for errors.

SELECT
    *
FROM
    trainer;
    
--// one trainer has a negative salary.  Error 6.  This will not interfere with the data warehouse, so shouldn't update as don't know what proper value should be.

--// Check to see if any errors in workout_sessions table.  Check if any dates don't make sense, such as if they occur ahead of time.

SELECT
    s.session_id,
    s.training_goal,
    to_char(s.work_date, 'dd-mm-yyyy') AS "Date"
FROM
    workout_session s
WHERE
    s.work_date > current_date;

--// incorrect date for session 201.  has happened in the future.  Error 7.  This will affect the data warehouse.  Assume year meant to be this year.

UPDATE workout_session
SET
    work_date = TO_DATE('30-03-2020', 'dd-mm-yyyy')
Where session_id = 201;