--/ Get required tables from dw account (dw.charter_fact, dw.time, dw.pilot, and dw.model).

CREATE TABLE charter_fact
    AS
        SELECT
            *
        FROM
            dw.charter_fact;

CREATE TABLE time
    AS
        SELECT
            *
        FROM
            dw.time;

CREATE TABLE pilot
    AS
        SELECT
            *
        FROM
            dw.pilot;

CREATE TABLE model
    AS
        SELECT
            *
        FROM
            dw.model;
            
