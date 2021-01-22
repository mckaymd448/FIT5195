--/ Checking branch for duplicate values.
SELECT
    *
FROM
    mfit.branch b;

--/ No duplicates found.  A null value has been found for this.  Should be deleted from operation database.  Error 1.

--/ Checking class for errors.

SELECT
    *
FROM
    mfit.class b
WHERE
    b.calories_burned IS NULL
ORDER BY
    b.session_id,
    b.client_id;

SELECT
    b.session_id,
    b.client_id,
    COUNT(b.calories_burned) AS "num entries"
FROM
    mfit.class b
GROUP BY
    b.session_id,
    b.client_id
HAVING
    COUNT(b.calories_burned) > 1;

--/ session id and client id are primary key, so no duplicates can exist in table.  No null values for calories burnt.

SELECT
    *
FROM
    mfit.class b
WHERE
    b.calories_burned < 0
ORDER BY
    b.session_id,
    b.client_id;
    
--/ -40 calories burnt for session id 155.  Error 2.

--/ Checking client for error.

SELECT
    c.client_id,
    COUNT(c.client_id) AS "num_entries"
FROM
    mfit.client c
GROUP BY
    c.client_id
HAVING
    COUNT(c.client_id) > 1;
    
--/ duplicate entry found.  Client ID inserted 4 times.  Error 3.

--/ Checking membership for errors.

SELECT
    m.membership_id,
    COUNT(m.membership_id) AS "num_entries"
FROM
    mfit.membership m
GROUP BY
    m.membership_id
HAVING
    COUNT(m.membership_id) > 1;
    
--/ No duplicate values.

SELECT
    m.membership_id,
    m.member_end_date - m.member_start_date
FROM
    mfit.membership m;
    
--/ membership 114 and 116 have end dates before the start dates.  Error 4.

SELECT
    *
FROM
    mfit.client        c
    LEFT JOIN mfit.membership    m ON c.client_id = m.client_id;
    
--/ all clients have an entry in membership table.

SELECT
    *
FROM
    mfit.trainer;
    
--// one trainer has a negative salary.  Error 4.

SELECT DISTINCT
    branch_id
FROM
    mfit.trainer;
    
--// branch 5 never referred to in datatable.  Can delete from the branch table.

SELECT
    *
FROM
    mfit.trains;

SELECT
    t.session_id,
    t.emp_id,
    COUNT(t.calories_burned) AS "num_rows"
FROM
    mfit.trains t
GROUP BY
    t.session_id,
    t.emp_id;
    
--/ No duplicate entries.

SELECT
    *
FROM
    mfit.class      c
    FULL OUTER JOIN mfit.trains     t ON c.session_id = t.session_id
    FULL OUTER JOIN mfit.trainer    tr ON t.emp_id = tr.emp_id;
    
--// emp_id 41 has not been assigned to any classes.  May not count as error though.

SELECT
    s.session_id,
    s.training_goal,
    to_char(s.work_date, 'dd-mm-yyyy') as "Date"
FROM
    mfit.workout_session s
Where s.work_date > current_date;

--// incorrect date for session 201.  has happened in the future.  Error 5.