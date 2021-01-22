--/ Create operation databases.

CREATE TABLE warehouse (
    warehouseid  VARCHAR2(10) NOT NULL,
    location     VARCHAR2(10) NOT NULL,
    PRIMARY KEY ( warehouseid )
);

CREATE TABLE truck (
    truckid         VARCHAR2(10) NOT NULL,
    volcapacity     NUMBER(5, 2),
    weightcategory  VARCHAR2(10),
    costperkm       NUMBER(5, 2),
    PRIMARY KEY ( truckid )
);

CREATE TABLE trip (
    tripid    VARCHAR2(10) NOT NULL,
    tripdate  DATE,
    totalkm   NUMBER(5),
    truckid   VARCHAR2(10),
    PRIMARY KEY ( tripid ),
    FOREIGN KEY ( truckid )
        REFERENCES truck ( truckid )
);

CREATE TABLE tripfrom (
    tripid       VARCHAR2(10) NOT NULL,
    warehouseid  VARCHAR2(10) NOT NULL,
    PRIMARY KEY ( tripid,
                  warehouseid ),
    FOREIGN KEY ( tripid )
        REFERENCES trip ( tripid ),
    FOREIGN KEY ( warehouseid )
        REFERENCES warehouse ( warehouseid )
);

CREATE TABLE store (
    storeid       VARCHAR2(10) NOT NULL,
    storename     VARCHAR2(20),
    storeaddress  VARCHAR2(20),
    PRIMARY KEY ( storeid )
);

CREATE TABLE destination (
    tripid   VARCHAR2(10) NOT NULL,
    storeid  VARCHAR2(10) NOT NULL,
    PRIMARY KEY ( tripid,
                  storeid ),
    FOREIGN KEY ( tripid )
        REFERENCES trip ( tripid ),
    FOREIGN KEY ( storeid )
        REFERENCES store ( storeid )
);

--Insert Records to Operational Database
INSERT INTO warehouse VALUES (
    'W1',
    'Warehouse1'
);

INSERT INTO warehouse VALUES (
    'W2',
    'Warehouse2'
);

INSERT INTO warehouse VALUES (
    'W3',
    'Warehouse3'
);

INSERT INTO warehouse VALUES (
    'W4',
    'Warehouse4'
);

INSERT INTO warehouse VALUES (
    'W5',
    'Warehouse5'
);

INSERT INTO truck VALUES (
    'Truck1',
    250,
    'Medium',
    1.2
);

INSERT INTO truck VALUES (
    'Truck2',
    300,
    'Medium',
    1.5
);

INSERT INTO truck VALUES (
    'Truck3',
    100,
    'Small',
    0.8
);

INSERT INTO truck VALUES (
    'Truck4',
    550,
    'Large',
    2.3
);

INSERT INTO truck VALUES (
    'Truck5',
    650,
    'Large',
    2.5
);

INSERT INTO trip VALUES (
    'Trip1',
    TO_DATE('14-Apr-2013', 'DD-MON-YYYY'),
    370,
    'Truck1'
);

INSERT INTO trip VALUES (
    'Trip2',
    TO_DATE('14-Apr-2013', 'DD-MON-YYYY'),
    570,
    'Truck2'
);

INSERT INTO trip VALUES (
    'Trip3',
    TO_DATE('14-Apr-2013', 'DD-MON-YYYY'),
    250,
    'Truck3'
);

INSERT INTO trip VALUES (
    'Trip4',
    TO_DATE('15-Jul-2013', 'DD-MON-YYYY'),
    450,
    'Truck1'
);

INSERT INTO trip VALUES (
    'Trip5',
    TO_DATE('15-Jul-2013', 'DD-MON-YYYY'),
    175,
    'Truck2'
);

INSERT INTO tripfrom VALUES (
    'Trip1',
    'W1'
);

INSERT INTO tripfrom VALUES (
    'Trip1',
    'W4'
);

INSERT INTO tripfrom VALUES (
    'Trip1',
    'W5'
);

INSERT INTO tripfrom VALUES (
    'Trip2',
    'W1'
);

INSERT INTO tripfrom VALUES (
    'Trip2',
    'W2'
);

INSERT INTO tripfrom VALUES (
    'Trip3',
    'W1'
);

INSERT INTO tripfrom VALUES (
    'Trip3',
    'W5'
);

INSERT INTO tripfrom VALUES (
    'Trip4',
    'W1'
);

INSERT INTO tripfrom VALUES (
    'Trip5',
    'W4'
);

INSERT INTO tripfrom VALUES (
    'Trip5',
    'W5'
);

INSERT INTO store VALUES (
    'M1',
    'Myer City',
    'Melbourne'
);

INSERT INTO store VALUES (
    'M2',
    'Myer Chaddy',
    'Chadstone'
);

INSERT INTO store VALUES (
    'M3',
    'Myer HiPoint',
    'High Point'
);

INSERT INTO store VALUES (
    'M4',
    'Myer West',
    'Doncaster'
);

INSERT INTO store VALUES (
    'M5',
    'Myer North',
    'Northland'
);

INSERT INTO store VALUES (
    'M6',
    'Myer South',
    'Southland'
);

INSERT INTO store VALUES (
    'M7',
    'Myer East',
    'Eastland'
);

INSERT INTO store VALUES (
    'M8',
    'Myer Knox',
    'Knox'
);

INSERT INTO destination VALUES (
    'Trip1',
    'M1'
);

INSERT INTO destination VALUES (
    'Trip1',
    'M2'
);

INSERT INTO destination VALUES (
    'Trip1',
    'M4'
);

INSERT INTO destination VALUES (
    'Trip1',
    'M3'
);

INSERT INTO destination VALUES (
    'Trip1',
    'M8'
);

INSERT INTO destination VALUES (
    'Trip2',
    'M4'
);

INSERT INTO destination VALUES (
    'Trip2',
    'M1'
);

INSERT INTO destination VALUES (
    'Trip2',
    'M2'
);

COMMIT;

--/ a.	Create a dimension table called TruckDim1.

CREATE TABLE truckdim1
    AS
        SELECT
            *
        FROM
            truck;

--/ b.	Create a dimension table called TripSeason1. This table will have 4 records (Summer, Autumn, Winter, and Spring).

CREATE TABLE tripseason1 (
    seasonid      NUMBER(1, 0),
    seasonperiod  VARCHAR(10)
);

INSERT INTO tripseason1 VALUES (
    1,
    'Summer'
);

INSERT INTO tripseason1 VALUES (
    2,
    'Autumn'
);

INSERT INTO tripseason1 VALUES (
    3,
    'Winter'
);

INSERT INTO tripseason1 VALUES (
    4,
    'Spring'
);

COMMIT;

--/ c.	Create a dimension table called TripDim1.

CREATE TABLE tripdim1
    AS
        SELECT
            tripid,
            tripdate AS "date",
            totalkm
        FROM
            trip;

--/ d.	Create a bridge table called BridgeTableDim1.

CREATE TABLE bridgetabledim1
    AS
        SELECT
            tripid,
            storeid
        FROM
            destination;
            
--/ e.	Create a dimension table called StoreDim1.

CREATE TABLE storedim1
    AS
        SELECT
            *
        FROM
            store;

--/ f.	Create a tempfact (and perform the necessary alter and update), and then create the final fact table (called it TruckFact1).

CREATE TABLE tempstorefact
    AS
        SELECT
            t.tripid,
            t.tripdate,
            t.truckid,
            SUM(t.totalkm * tr.costperkm) AS total_delivery_cost
        FROM
                 trip t
            JOIN truck tr ON t.truckid = tr.truckid
        GROUP BY
            t.tripid,
            t.tripdate,
            t.truckid;

ALTER TABLE tempstorefact ADD (
    seasonid NUMBER(1, 0)
);

SELECT
    *
FROM
    tempstorefact;

UPDATE tempstorefact
SET
    seasonid = 1
WHERE
        to_char(tripdate, 'MM') >= '12'
    AND to_char(tripdate, 'MM') <= '02';

UPDATE tempstorefact
SET
    seasonid = 2
WHERE
    to_char(tripdate, 'MM') >= '03'
    OR to_char(tripdate, 'MM') <= '05';

UPDATE tempstorefact
SET
    seasonid = 3
WHERE
        to_char(tripdate, 'MM') >= '06'
    AND to_char(tripdate, 'MM') <= '08';

UPDATE tempstorefact
SET
    seasonid = 4
WHERE
        to_char(tripdate, 'MM') >= '09'
    AND to_char(tripdate, 'MM') <= '11';

COMMIT;

CREATE TABLE storefact
    AS
        SELECT
            tripid,
            seasonid,
            truckid,
            total_delivery_cost
        FROM
            tempstorefact;

--/ g.	Display (and observe) the contents of the fact table (TruckFact1).

SELECT
    *
FROM
    storefact;

--/ Part 2

--/ a.	Create a dimension table called TruckDim2.

CREATE TABLE truckdim2
    AS
        SELECT
            *
        FROM
            truckdim1;

--/ b.	Create a dimension table called TripSeason2. This table will have 4 records (Summer, Autumn, Winter, and Spring).

CREATE TABLE tripseason2
    AS
        SELECT
            *
        FROM
            tripseason1;

--/ c.	Create a dimension table called StoreDim2.

CREATE TABLE storedim2
    AS
        SELECT
            *
        FROM
            storedim1;
            
--/ d.	Create a bridge table called BridgeTableDim2.

CREATE TABLE bridgetabledim2
    AS
        SELECT
            *
        FROM
            bridgetabledim1;

--/ e.	Create a dimension table called TripDim2 (Notes: this dimension is different from TripDim1 in the previous section).

CREATE TABLE trimdim2
    AS
        SELECT
            t.tripid,
            t.tripdate,
            t.totalkm,
            1 / COUNT(d.storeid) AS weight_factor
        FROM
                 trip t
            JOIN destination d ON t.tripid = d.tripid
        GROUP BY
            t.tripid,
            t.tripdate,
            t.totalkm;

--/ f.	Create a tempfact (and perform the necessary alter and update), and then create the final fact table (called it TruckFact2).
            
CREATE TABLE tempstorefact2
    AS
        SELECT
            t.tripid,
            t.tripdate,
            t.truckid,
            SUM(t.totalkm * tr.costperkm) AS total_delivery_cost
        FROM
                 trip t
            JOIN truck tr ON t.truckid = tr.truckid
        GROUP BY
            t.tripid,
            t.tripdate,
            t.truckid;

ALTER TABLE tempstorefact2 ADD (
    seasonid NUMBER(1, 0)
);

SELECT
    *
FROM
    tempstorefact;

UPDATE tempstorefact2
SET
    seasonid = 1
WHERE
        to_char(tripdate, 'MM') >= '12'
    AND to_char(tripdate, 'MM') <= '02';

UPDATE tempstorefact2
SET
    seasonid = 2
WHERE
    to_char(tripdate, 'MM') >= '03'
    OR to_char(tripdate, 'MM') <= '05';

UPDATE tempstorefact2
SET
    seasonid = 3
WHERE
        to_char(tripdate, 'MM') >= '06'
    AND to_char(tripdate, 'MM') <= '08';

UPDATE tempstorefact2
SET
    seasonid = 4
WHERE
        to_char(tripdate, 'MM') >= '09'
    AND to_char(tripdate, 'MM') <= '11';

COMMIT;

CREATE TABLE storefact2
    AS
        SELECT
            tripid,
            seasonid,
            truckid,
            total_delivery_cost
        FROM
            tempstorefact2;
            
--/ h.	What is the total delivery cost for each store?         

SELECT
    s.storename,
    SUM(f.total_delivery_cost * t.weight_factor) AS "Total Cost for Store"
FROM
         storefact2 f
    JOIN trimdim2         t ON t.tripid = f.tripid
    JOIN bridgetabledim2  b ON f.tripid = b.tripid
    JOIN storedim2        s ON b.storeid = s.storeid
GROUP BY
    s.storename
ORDER BY
    s.storename;