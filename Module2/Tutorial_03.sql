DROP TABLE itemdim;

DROP TABLE categorydim;

DROP TABLE locationdim;

DROP TABLE seasondim;

DROP TABLE auctiontemp;

DROP TABLE auctionfact;

CREATE TABLE itemdim
    AS
        SELECT DISTINCT
                i_itemkey,
                i_name,
                i_retailprice
        FROM
            item2;

CREATE TABLE categorydim
    AS
        SELECT DISTINCT
            *
        FROM
            dtaniar.category2;

CREATE TABLE locationdim
        AS
                SELECT DISTINCT
                    r.r_name || n.n_name AS locationid,
                    r.r_name,
                    n.n_name
                FROM
                        dtaniar.nation2    n,
                        dtaniar.region2

            r

        WHERE
            r.r_regionkey = n.n_regionkey;

CREATE TABLE seasondim (
    seasonid  NUMBER,
    s_desc    VARCHAR2(15),
    s_start   VARCHAR2(15),
    s_end     VARCHAR2(15)
);

Insert into SeasonDim values (1, 'Spring', 'September', 'November');
Insert into SeasonDim values (2, 'Summer', 'December', 'February');
Insert into SeasonDim values (3, 'Autumn', 'March', 'May');
Insert into SeasonDim values (4, 'Winter', 'June', 'August');

CREATE table auctiontemp as
SELECT 
  r.r_name || n.n_name as LocationID, 
  a.a_endtime, 
  i.i_itemkey, 
  c.cat_categorykey, 
  a.a_auctionprice, 
  i.i_retailprice, 
  a.a_auctionkey
FROM item2 i, 
 dtaniar.Category2 c, 
 dtaniar.Region2 r, 
 dtaniar.Nation2 n, 
 Auction2 a,
 dtaniar.Customer2 cus
WHERE a.a_itemkey = i.i_itemkey
AND i.i_categorykey = c.cat_categoryKey
AND cus.c_nationkey = n.n_nationkey
AND r.r_regionkey = n.n_regionkey
AND a.a_username = cus.c_username;

ALTER table auctiontemp 
ADD(SeasonID number);

Update auctiontemp
Set SeasonID = 1
Where to_char(a_endtime, 'MM')>= '09' and to_char(a_endtime, 'MM') <='11';

Update auctiontemp
Set SeasonID = 2
Where to_char(a_endtime, 'MM')>= '12' or to_char(a_endtime, 'MM') <='02';

Update auctiontemp
Set SeasonID = 3
Where to_char(a_endtime, 'MM')>= '03' and to_char(a_endtime, 'MM') <='05';

Update auctiontemp
Set SeasonID = 4
Where to_char(a_endtime, 'MM')>= '06' and to_char(a_endtime, 'MM') <='08';

CREATE table AuctionFact as Select
  t.LocationID, 
  t.SeasonID, 
  t.i_itemkey, 
  t.cat_categorykey,
  sum((t.a_auctionPrice/0.02) * 0.75 - t.i_retailPrice) as total_profit,
  count(t.a_auctionkey) as total_number_of_auctions
FROM auctiontemp t
GROUP BY 
  t.locationID, 
  t.SeasonID, 
  t.i_itemkey, 
  t.cat_categorykey;

