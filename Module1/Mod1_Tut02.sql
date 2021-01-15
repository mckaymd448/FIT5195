--/ 3.	Write the SQL statements for the implementation of the star schema.
--/     The following operational databases have been provided for you:
--/      dw.Class: table that stores information about classification ids and descriptions
--/      dw.Major: table that stores information about major codes and descriptions
--/      dw.Student: table that stores information about students as described above
--/      dw.Uselog: table that stores information about lab usage as described above

--/     You do not need to copy these four tables (dw.Class, dw.Major, dw.Student, and dw.Uselog) into your account. You can just simply use these tables.

CREATE TABLE majordim
    AS
        SELECT
            major_code,
            major_name
        FROM
            dw.major;

CREATE TABLE classdim
    AS
        SELECT
            class_id,
            class_description
        FROM
            dw.class;

CREATE TABLE timeperioddim (
    tp_id       NUMBER(5, 0),
    time_desc   VARCHAR2(50),
    begin_time  DATE,
    end_time    DATE,
    PRIMARY KEY ( tp_id )
);

INSERT INTO timeperioddim VALUES (
    1,
    'Morning',
    TO_DATE('06:01', 'HH24:MI'),
    TO_DATE('12:00', 'HH24:MI')
);

INSERT INTO timeperioddim VALUES (
    2,
    'Afternoon',
    TO_DATE('12:01', 'HH24:MI'),
    TO_DATE('18:00', 'HH24:MI')
);

INSERT INTO timeperioddim VALUES (
    3,
    'Night',
    TO_DATE('18:01', 'HH24:MI'),
    TO_DATE('06:00', 'HH24:MI')
);

COMMIT;

CREATE TABLE semesterdim (
    sem_id      NUMBER(5, 0),
    sem_desc    VARCHAR2(50),
    begin_date  DATE,
    end_end     DATE,
    PRIMARY KEY ( sem_id )
);

INSERT INTO semesterdim VALUES (
    1,
    'Semester 1',
    TO_DATE('01-JAN', 'DD-MON'),
    TO_DATE('15-JUL', 'DD-MON')
);

INSERT INTO semesterdim VALUES (
    2,
    'Semester 2',
    TO_DATE('16-JUL', 'DD-MON'),
    TO_DATE('31-DEC', 'DD-MON')
);

COMMIT;

CREATE TABLE tempusagefact
    AS
        SELECT
            u.log_date,
            u.log_time,
            c.class_id,
            m.major_code,
            COUNT(u.student_id) AS studenttotal
        FROM
                 dw.uselog u
            JOIN dw.student    s ON s.student_id = u.student_id
            JOIN dw.major      m ON s.major_code = m.major_code
            JOIN dw.class      c ON c.class_id = s.class_id
        GROUP BY
            u.log_date,
            u.log_time,
            c.class_id,
            m.major_code;

ALTER TABLE tempusagefact ADD sem_id NUMBER(5, 0);

ALTER TABLE tempusagefact ADD tp_id NUMBER(5, 0);

UPDATE tempusagefact
SET
    sem_id = '1'
WHERE
    to_char(log_date, 'MMDD') BETWEEN '0101' AND '0715';

UPDATE tempusagefact
SET
    sem_id = '2'
WHERE
    to_char(log_date, 'MMDD') BETWEEN '0716' AND '1231';

COMMIT;

UPDATE tempusagefact
SET
    tp_id = '1'
WHERE
    to_char(log_time, 'HH24MI') BETWEEN '0601' AND '1200';

UPDATE tempusagefact
SET
    tp_id = '2'
WHERE
    to_char(log_time, 'HH24MI') BETWEEN '1201' AND '1800';

UPDATE tempusagefact
SET
    tp_id = '3'
WHERE
    to_char(log_time, 'HH24MI') > '1800';

COMMIT;

CREATE TABLE usagefact
    AS
        SELECT
            tp_id,
            sem_id,
            major_code,
            class_id,
            studenttotal
        FROM
            tempusagefact
        ORDER BY
            sem_id,
            tp_id;

--/ 4.	Write the SQL statements to produce the following reports:
--/     a.	Show the usage numbers by different time periods (e.g. morning, afternoon, night)

SELECT
    t.time_desc,
    SUM(u.studenttotal) AS "Students Using"
FROM
         usagefact u
    JOIN timeperioddim t ON u.tp_id = t.tp_id
GROUP BY
    t.time_desc
ORDER BY
    t.time_desc;

--/     b.	Show the usage numbers by time period (e.g. morning, afternoon, night), by major, and by student's class

SELECT
    u.tp_id,
    t.time_desc,
    u.major_code,
    m.major_name,
    u.class_id,
    c.class_description,
    SUM(u.studenttotal) AS "Students Using"
FROM
         usagefact u
    JOIN timeperioddim  t ON u.tp_id = t.tp_id
    JOIN majordim       m ON u.major_code = m.major_code
    JOIN classdim       c ON u.class_id = c.class_id
GROUP BY
    u.tp_id,
    t.time_desc,
    u.major_code,
    m.major_name,
    u.class_id,
    c.class_description
ORDER BY
    u.tp_id;

--/     c.	Show the usage numbers for different majors and semesters (e.g. semester 1, semester 2).

SELECT
    u.sem_id,
    s.sem_desc,
    u.major_code,
    m.major_name,
    SUM(u.studenttotal) AS "Students Using"
FROM
         usagefact u
    JOIN majordim     m ON u.major_code = m.major_code
    JOIN semesterdim  s ON u.sem_id = s.sem_id
GROUP BY
    u.sem_id,
    s.sem_desc,
    u.major_code,
    m.major_name
ORDER BY
    u.major_code;