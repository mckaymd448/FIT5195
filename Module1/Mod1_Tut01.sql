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

CREATE TABLE student2
    AS
        SELECT
            *
        FROM
            dtaniar.student2;

DESCRIBE student2;

SELECT
    *
FROM
    student2;

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

SELECT
    sb.utitle,
    COUNT(s.sid) AS "Number of Students"
FROM
         student2 s
    JOIN enrollment2  e ON s.sid = e.sid
    JOIN offering2    o ON o.oid = e.oid
    JOIN subject2     sb ON sb.ucode = o.ucode
WHERE
        upper(sb.utitle) = 'SAP'
    AND o.osem = 1
    AND o.oyear = 2009
    AND upper(e.grade) = 'HD'
GROUP BY
    sb.utitle;