WITH
district_list AS (
  SELECT unnest(ARRAY[
    '北投區', '士林區', '內湖區', '南港區', '松山區', '信義區', '中山區',
    '大同區', '中正區', '萬華區', '大安區', '文山區',
    '板橋區', '新莊區', '中和區', '永和區', '三重區', '新店區', '土城區', '樹林區', '汐止區',
    '淡水區', '蘆洲區', '五股區', '鶯歌區', '三峽區', '三芝區', '石門區', '八里區', '泰山區',
    '林口區', '深坑區', '石碇區', '坪林區', '烏來區'
  ]) AS district
),
type_list AS (
  SELECT unnest(ARRAY['性別友善', '無障礙友善', '穆斯林友善']) AS friendly_type
),
unpivoted AS (
  SELECT
    CASE
      WHEN address LIKE ANY (
        SELECT '%' || d.district || '%' FROM district_list d
      ) THEN
        (SELECT d.district FROM district_list d WHERE address LIKE '%' || d.district || '%' LIMIT 1)
      ELSE '其他區'
    END AS district,
    un.friendly_type,
    un.friendly_value
  FROM friendly_stores s
  CROSS JOIN LATERAL (VALUES
    ('性別友善', s.gender_friendly),
    ('無障礙友善', s.accessibility_friendly),
    ('穆斯林友善', s.muslim_friendly)
  ) AS un(friendly_type, friendly_value)
  WHERE s.address IS NOT NULL AND un.friendly_value = 1
),
aggregated AS (
  SELECT district, friendly_type, COUNT(*) AS data
  FROM unpivoted
  WHERE district != '其他區'
  GROUP BY district, friendly_type
)
SELECT
  d.district AS x_axis,
  t.friendly_type AS y_axis,
  COALESCE(a.data, 0) AS data
FROM district_list d
CROSS JOIN type_list t
LEFT JOIN aggregated a ON a.district = d.district AND a.friendly_type = t.friendly_type
ORDER BY
  array_position(ARRAY(
    SELECT district FROM district_list
  ), d.district),
  array_position(ARRAY(
    SELECT friendly_type FROM type_list
  ), t.friendly_type);