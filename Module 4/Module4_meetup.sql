SELECT
    *
FROM
    (
        SELECT
            pf.city,
            pf.product,
            SUM(pf.total_sales_kg)       AS "total_sales",
            RANK()
            OVER(PARTITION BY pf.city
                 ORDER BY SUM(pf.total_sales_kg) DESC
            )                            AS "rank"
        FROM
            dwprac.pet_fact pf
        GROUP BY
            pf.city,
            pf.product
        ORDER BY
            pf.city
    )
WHERE
    "rank" < 3;

SELECT
    pf.time_period,
    pf.city,
    SUM(pf.total_transactions)       AS "total_transactions",
    SUM(SUM(pf.total_transactions))
    OVER(
        ORDER BY
            pf.time_period, pf.city
        ROWS UNBOUNDED PRECEDING
    )                                AS "cumulative transactions"
FROM
    dwprac.pet_fact pf
GROUP BY
    pf.time_period,
    pf.city
ORDER BY
    pf.time_period;