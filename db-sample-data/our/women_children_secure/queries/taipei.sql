WITH district_list AS (
    SELECT unnest(ARRAY[
        '北投區','士林區','內湖區','南港區','松山區','信義區',
        '中山區','大同區','中正區','萬華區','大安區','文山區'
    ]) AS district
)

SELECT
    d.district AS x_axis,
    COALESCE(c.data, 0) AS data
FROM district_list d
LEFT JOIN LATERAL (
        SELECT COUNT(*) AS data
        FROM   women_children_secure w
        WHERE  w.location LIKE '%' || d.district || '%'
    ) c ON TRUE
ORDER BY
    array_position(
        ARRAY[
            '北投區','士林區','內湖區','南港區','松山區','信義區',
            '中山區','大同區','中正區','萬華區','大安區','文山區'
        ],
        d.district
    );
