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

Commit;

--/ a.	Create a dimension table called TruckDim1.
--/ b.	Create a dimension table called TripSeason1. This table will have 4 records (Summer, Autumn, Winter, and Spring).
--/ c.	Create a dimension table called TripDim1.
--/ d.	Create a bridge table called BridgeTableDim1.
--/ e.	Create a dimension table called StoreDim1.
--/ f.	Create a tempfact (and perform the necessary alter and update), and then create the final fact table (called it TruckFact1).
--/ g.	Display (and observe) the contents of the fact table (TruckFact1).
