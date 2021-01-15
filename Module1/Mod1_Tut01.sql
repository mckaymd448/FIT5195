--/ a)	Create table SUBJECT2 and insert the above 5 records.

CREATE TABLE subject2 (
    ucode    VARCHAR2(5),
    utitle   VARCHAR2(30),
    ucredit  NUMBER(4, 0),
    PRIMARY KEY ( ucode )
);

INSERT INTO subject2 VALUES (
    'IT001',
    'Database',
    5
);

INSERT INTO subject2 VALUES (
    'IT002',
    'Java',
    5
);

INSERT INTO subject2 VALUES (
    'IT003',
    'SAP',
    10
);

INSERT INTO subject2 VALUES (
    'IT004',
    'Network',
    5
);

INSERT INTO subject2 VALUES (
    'IT005',
    'ASP.net',
    5
);

COMMIT;

SELECT
    *
FROM
    subject2;

--/ b)	Table STUDENT2 has been created in the dtaniar account. Several records have been inserted to this table. You can now import table STUDENT2 to your account using the following SQL statement:

CREATE TABLE student2
    AS
        SELECT
            *
        FROM
            dtaniar.student2;

--/ c)	Describe the structure of table STUDENT2.

DESCRIBE student2;

--/ d)	Display all records from table STUDENT2.

SELECT
    *
FROM
    student2;

--/ e)	Insert the missing records to table STUDENT2.

INSERT INTO student2 VALUES (
    '10008',
    'Miller',
    'Larry',
    'M',
    TO_DATE('22-Jul-1973', 'DD-Mon-YYYY'),
    211
);

INSERT INTO student2 VALUES (
    '10009',
    'Smith',
    'Leonard',
    'M',
    TO_DATE('26-May-1985', 'DD-Mon-YYYY'),
    211
);

INSERT INTO student2 VALUES (
    '10010',
    'Brown',
    'Menson',
    'M',
    TO_DATE('12-Jul-1983', 'DD-Mon-YYYY'),
    112
);

COMMIT;

--/ f)	Import Tables OFFERING2 and ENROLLMENT2 from dtaniar account. The method is similar to question (b) above.

CREATE TABLE offering2
    AS
        SELECT
            *
        FROM
            dtaniar.offering2;

CREATE TABLE enrollment2
    AS
        SELECT
            *
        FROM
            dtaniar.enrollment2;
--/ g)	Using SQL to answer the questions:
--/ 1)	How many students enrolled in the Database unit offered in Main campus?

SELECT
    sb.utitle,
    COUNT(s.sid) AS "Number of Students"
FROM
         student2 s
    JOIN enrollment2  e ON s.sid = e.sid
    JOIN offering2    o ON o.oid = e.oid
    JOIN subject2     sb ON sb.ucode = o.ucode
WHERE
        upper(sb.utitle) = 'DATABASE'
    AND upper(o.ocampus) = 'MAIN'
GROUP BY
    sb.utitle;
    
--/ 2)	What is the total score of students taking the Database unit in Main campus?    

SELECT
    sb.utitle,
    SUM(e.score) AS "Total Score"
FROM
         student2 s
    JOIN enrollment2  e ON s.sid = e.sid
    JOIN offering2    o ON o.oid = e.oid
    JOIN subject2     sb ON sb.ucode = o.ucode
WHERE
        upper(sb.utitle) = 'DATABASE'
    AND upper(o.ocampus) = 'MAIN'
GROUP BY
    sb.utitle;

--/ 3)	How many students enrolled in the Java unit offered in Semester 2, 2009?

SELECT
    sb.utitle,
    COUNT(s.sid) AS "Number of Students"
FROM
         student2 s
    JOIN enrollment2  e ON s.sid = e.sid
    JOIN offering2    o ON o.oid = e.oid
    JOIN subject2     sb ON sb.ucode = o.ucode
WHERE
        upper(sb.utitle) = 'JAVA'
    AND o.osem = 2
    AND o.oyear = 2009
GROUP BY
    sb.utitle;

--/ 4)	What is the total score of students taking the Java unit in Semester 2, 2009?

SELECT
    sb.utitle,
    SUM(e.score) AS "Total Score"
FROM
         student2 s
    JOIN enrollment2  e ON s.sid = e.sid
    JOIN offering2    o ON o.oid = e.oid
    JOIN subject2     sb ON sb.ucode = o.ucode
WHERE
        upper(sb.utitle) = 'JAVA'
    AND o.osem = 2
    AND o.oyear = 2009
GROUP BY
    sb.utitle;
    
--/ 5)	How many students received HD in the SAP unit offered in Semester 1, 2009?    

SELECT
    COUNT(*) AS "Number of Students"
FROM
         student2 s
    JOIN enrollment2  e ON s.sid = e.sid
    JOIN offering2    o ON o.oid = e.oid
    JOIN subject2     sb ON sb.ucode = o.ucode
WHERE
        upper(sb.utitle) = 'SAP'
    AND o.osem = 1
    AND o.oyear = 2009
    AND upper(e.grade) = 'HD';
    
--/ i)	Use the SQL command to create and populate the dimension tables.

CREATE TABLE campusdim
    AS
        SELECT DISTINCT
            ocampus
        FROM
            offering2
        ORDER BY
            ocampus;

CREATE TABLE subjectdim
    AS
        SELECT
            ucode,
            utitle,
            ucredit
        FROM
            subject2;

CREATE TABLE gradedim
    AS
        SELECT DISTINCT
            grade
        FROM
            enrollment2
        ORDER BY
            grade;

CREATE TABLE timedim
    AS
        SELECT DISTINCT
            oyear
            || '-'
            || osem as sem_id,
            oyear,
            osem 
        FROM
            offering2;