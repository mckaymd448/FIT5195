--/ Create dimension table clientSubDim.

DROP TABLE clientSubDim CASCADE CONSTRAINTS;

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

Drop table memberDim CASCADE CONSTRAINTS;

