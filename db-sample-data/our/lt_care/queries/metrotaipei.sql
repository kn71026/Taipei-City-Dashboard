SELECT 
    all_districts.district as x_axis,
    COALESCE(elder_care_location.ratio, 0) as data
FROM (
    SELECT unnest(ARRAY[
        '北投區', '士林區', '內湖區', '南港區', '松山區', '信義區', '中山區', '大同區', '中正區', '萬華區', 
        '大安區', '文山區', '新莊區', '板橋區', '三重區', '樹林區', '土城區', '蘆洲區', 
        '中和區', '永和區', '新店區', '鶯歌區', '五股區', '三芝區'
    ]) as district
) all_districts
LEFT JOIN (
    SELECT district, ratio
    FROM elder_care_location
    GROUP BY district, ratio
) elder_care_location ON all_districts.district = elder_care_location.district
ORDER BY array_position(ARRAY[
    '北投區', '士林區', '內湖區', '南港區', '松山區', '信義區', '中山區', '大同區', '中正區', '萬華區', 
        '大安區', '文山區', '新莊區', '板橋區', '三重區', '樹林區', '土城區', '蘆洲區', 
        '中和區', '永和區', '新店區', '鶯歌區', '五股區', '三芝區'
], all_districts.district);