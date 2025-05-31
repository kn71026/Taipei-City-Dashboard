WITH districts AS (
    SELECT unnest(ARRAY[
        '北投區','士林區','內湖區','南港區','松山區','信義區',
        '中山區','大同區','中正區','萬華區','大安區','文山區',
        '新莊區','淡水區','汐止區','板橋區','三重區','樹林區',
        '土城區','蘆洲區','中和區','永和區','新店區','鶯歌區',
        '三峽區','瑞芳區','五股區','泰山區','林口區','深坑區',
        '石碇區','坪林區','三芝區','石門區','八里區','平溪區',
        '雙溪區','貢寮區','金山區','萬里區','烏來區'
    ]) AS 行政區
),
types AS (
    SELECT unnest(ARRAY['地區醫院', '醫學中心', '區域醫院']) AS 類型
),
combinations AS (
    SELECT d.行政區, t.類型
    FROM districts d CROSS JOIN types t
),
counts AS (
    SELECT 行政區, 類型, COUNT(*) AS data
    FROM public.hospitals
    WHERE 市 IN ('臺北市', '新北市')
    GROUP BY 行政區, 類型
)
SELECT 
    c.行政區 AS x_axis,
    c.類型 AS y_axis,
    COALESCE(cnt.data, 0) AS data
FROM combinations c
LEFT JOIN counts cnt
    ON c.行政區 = cnt.行政區 AND c.類型 = cnt.類型
ORDER BY array_position(ARRAY[
    '北投區','士林區','內湖區','南港區','松山區','信義區',
    '中山區','大同區','中正區','萬華區','大安區','文山區',
    '新莊區','淡水區','汐止區','板橋區','三重區','樹林區',
    '土城區','蘆洲區','中和區','永和區','新店區','鶯歌區',
    '三峽區','瑞芳區','五股區','泰山區','林口區','深坑區',
    '石碇區','坪林區','三芝區','石門區','八里區','平溪區',
    '雙溪區','貢寮區','金山區','萬里區','烏來區'
], c.行政區),
c.類型;