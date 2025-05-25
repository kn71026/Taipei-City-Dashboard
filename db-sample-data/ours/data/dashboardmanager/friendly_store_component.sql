DO $$
DECLARE
    target_index text := 'friendly_store';
BEGIN
    DELETE FROM public.query_charts
  	WHERE index LIKE '%' || target_index || '%';

	DELETE FROM public.component_maps
  	WHERE index LIKE '%' || target_index || '%';

    DELETE FROM public.component_charts
  	WHERE index LIKE '%' || target_index || '%';

    DELETE FROM public.components
  	WHERE index LIKE '%' || target_index || '%';
END $$;

-- Root: components
INSERT INTO
    public.components (id, index, name)
VALUES (741, 'friendly_store', '友善店家');

-- component_charts
INSERT INTO public.component_charts (index, color, types, unit) 
VALUES ('friendly_store',ARRAY['#24B0DD','#56B96D','#F8CF58','#F5AD4A','#E170A6','#ED6A45','#AF4137','#10294A']::text[],'{ColumnChart,DistrictChart,PolarAreaChart}', '項目');

-- component_maps
INSERT INTO
    public.component_maps (
        id,
        index,
        title,
        type,
        source,
        size,
        icon,
        paint,
        property
    )
VALUES (
        '1',
        'friendly_store',
        '友善商家',
        'circle',
        'geojson',
        'big',
        'heatmap',
        '{"circle-color":"#4CAF50","circle-radius":6,"circle-opacity":0.8,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}',
        '[{"key":"name","name":"友善店家名稱"},{"key":"address","name":"地址"},{"key":"phone","name":"電話"},{"key":"description","name":"簡介"},{"key":"english_friendly","name":"英文友善"},{"key":"japanese_friendly","name":"日文友善"},{"key":"korean_friendly","name":"韓文友善"},{"key":"mobile_charging","name":"行動裝置充電"},{"key":"accessibility_friendly","name":"無障礙友善"},{"key":"gender_friendly","name":"性別友善"},{"key":"digital_payment_friendly","name":"便利支付"},{"key":"vegetarian_friendly","name":"素食"},{"key":"restroom_friendly","name":"友善廁所"},{"key":"fair_trade_friendly","name":"公平貿易友善"},{"key":"free_wifi","name":"Free WiFi"},{"key":"bike_friendly","name":"自行車友善"},{"key":"breastfeeding_friendly","name":"哺集乳友善"},{"key":"muslim_friendly","name":"穆斯林友善"},{"key":"menstruation_friendly","name":"月經友善"},{"key":"friendly_feature_count","name":"友善項目總計"}]'
    ),
    (
        '2',
        'friendly_store_metrotaipei',
        '友善商家',
        'circle',
        'geojson',
        'big',
        'heatmap',
        '{"circle-color":"#4CAF50","circle-radius":6,"circle-opacity":0.8,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}',
        '[{"key":"name","name":"友善店家名稱"},{"key":"address","name":"地址"},{"key":"phone","name":"電話"},{"key":"description","name":"簡介"},{"key":"english_friendly","name":"英文友善"},{"key":"japanese_friendly","name":"日文友善"},{"key":"korean_friendly","name":"韓文友善"},{"key":"mobile_charging","name":"行動裝置充電"},{"key":"accessibility_friendly","name":"無障礙友善"},{"key":"gender_friendly","name":"性別友善"},{"key":"digital_payment_friendly","name":"便利支付"},{"key":"vegetarian_friendly","name":"素食"},{"key":"restroom_friendly","name":"友善廁所"},{"key":"fair_trade_friendly","name":"公平貿易友善"},{"key":"free_wifi","name":"Free WiFi"},{"key":"bike_friendly","name":"自行車友善"},{"key":"breastfeeding_friendly","name":"哺集乳友善"},{"key":"muslim_friendly","name":"穆斯林友善"},{"key":"menstruation_friendly","name":"月經友善"},{"key":"friendly_feature_count","name":"友善項目總計"}]'
    );

-- query_charts
INSERT INTO
    public.query_charts (
        index,
        history_config,
        map_config_ids,
        map_filter,
        time_from,
        time_to,
        update_freq,
        update_freq_unit,
        source,
        short_desc,
        long_desc,
        use_case,
        links,
        contributors,
        created_at,
        updated_at,
        query_type,
        query_chart,
        query_history,
        city
    )
VALUES (
        'friendly_store',
        'null',
        '{1}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '臺北市政府商業處',
        '顯示臺北市友善店家分布統計',
        '顯示臺北市友善店家在各行政區的分布情況，包括英文友善、性別友善、無障礙友善、穆斯林友善等類型。此資料有助於了解臺北市各區域對不同族群的友善程度，提供市民選擇消費場所的參考，也可作為政策制定的依據。',
        '適用於商圈分析、無障礙環境評估、多元族群服務規劃等用途。市民可透過此資料找到符合需求的友善店家，政府單位可評估各區域的友善環境建置成效，並規劃相關輔導措施。企業也可參考此資料選擇展店地點或調整服務項目。',
        '{https://data.taipei/dataset/detail?id=11405}',
        '{doit}',
        '2024-03-21 05:56:00+00',
        '2025-05-24 18:13:43.063599+00',
        'three_d',
        'WITH district_list AS (   SELECT unnest(ARRAY[     ''北投區'', ''士林區'', ''內湖區'', ''南港區'', ''松山區'', ''信義區'',     ''中山區'', ''大同區'', ''中正區'', ''萬華區'', ''大安區'', ''文山區''   ]) AS district ), type_list AS (   SELECT unnest(ARRAY[''性別友善'', ''無障礙友善'', ''穆斯林友善'']) AS friendly_type ), unpivoted AS (   SELECT     CASE       WHEN address LIKE ANY (         SELECT ''%'' || d.district || ''%'' FROM district_list d       ) THEN (         SELECT d.district FROM district_list d         WHERE address LIKE ''%'' || d.district || ''%''         LIMIT 1       )       ELSE ''其他區''     END AS district,     un.friendly_type,     un.friendly_value   FROM friendly_stores s   CROSS JOIN LATERAL (VALUES     (''性別友善'', s.gender_friendly),     (''無障礙友善'', s.accessibility_friendly),     (''穆斯林友善'', s.muslim_friendly)   ) AS un(friendly_type, friendly_value)   WHERE s.address IS NOT NULL AND un.friendly_value = 1 ), aggregated AS (   SELECT district, friendly_type, COUNT(*) AS data   FROM unpivoted   WHERE district != ''其他區''   GROUP BY district, friendly_type ) SELECT   d.district AS x_axis,   t.friendly_type AS y_axis,   COALESCE(a.data, 0) AS data FROM district_list d CROSS JOIN type_list t LEFT JOIN aggregated a   ON a.district = d.district AND a.friendly_type = t.friendly_type ORDER BY   array_position(ARRAY[     ''北投區'', ''士林區'', ''內湖區'', ''南港區'', ''松山區'', ''信義區'',     ''中山區'', ''大同區'', ''中正區'', ''萬華區'', ''大安區'', ''文山區''   ], d.district),   array_position(ARRAY[''英文友善'', ''性別友善'', ''無障礙友善'', ''穆斯林友善''], t.friendly_type);',
        NULL,
        'taipei'
    ),
    (
        'friendly_store',
        'null',
        '{1,2}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '雙北政府商業處',
        '顯示雙北友善店家分布統計',
        '顯示雙北地區友善店家在各行政區的分布情況，包括英文友善、性別友善、無障礙友善、穆斯林友善等類型。此資料有助於了解雙北各區域對不同族群的友善程度，提供市民選擇消費場所的參考，也可作為政策制定的依據。',
        '適用於商圈分析、無障礙環境評估、多元族群服務規劃等用途。市民可透過此資料找到符合需求的友善店家，政府單位可評估各區域的友善環境建置成效，並規劃相關輔導措施。企業也可參考此資料選擇展店地點或調整服務項目。',
        '{https://data.taipei/dataset/detail?id=11405}',
        '{doit,ntpc}',
        '2024-03-21 05:58:00+00',
        '2025-05-24 18:17:05.602385+00',
        'three_d',
        'WITH district_list AS (   SELECT unnest(ARRAY[     ''北投區'', ''士林區'', ''內湖區'', ''南港區'', ''松山區'', ''信義區'', ''中山區'',     ''大同區'', ''中正區'', ''萬華區'', ''大安區'', ''文山區'',     ''板橋區'', ''新莊區'', ''中和區'', ''永和區'', ''三重區'', ''新店區'', ''土城區'', ''樹林區'', ''汐止區'',     ''淡水區'', ''蘆洲區'', ''五股區'', ''鶯歌區'', ''三峽區'', ''三芝區'', ''石門區'', ''八里區'', ''泰山區'',     ''林口區'', ''深坑區'', ''石碇區'', ''坪林區'', ''烏來區''   ]) AS district ), type_list AS (   SELECT unnest(ARRAY[''性別友善'', ''無障礙友善'', ''穆斯林友善'']) AS friendly_type ), unpivoted AS (   SELECT     CASE       WHEN address LIKE ANY (         SELECT ''%'' || d.district || ''%'' FROM district_list d       ) THEN         (SELECT d.district FROM district_list d WHERE address LIKE ''%'' || d.district || ''%'' LIMIT 1)       ELSE ''其他區''     END AS district,     un.friendly_type,     un.friendly_value   FROM friendly_stores s   CROSS JOIN LATERAL (VALUES     (''性別友善'', s.gender_friendly),     (''無障礙友善'', s.accessibility_friendly),     (''穆斯林友善'', s.muslim_friendly)   ) AS un(friendly_type, friendly_value)   WHERE s.address IS NOT NULL AND un.friendly_value = 1 ), aggregated AS (   SELECT district, friendly_type, COUNT(*) AS data   FROM unpivoted   WHERE district != ''其他區''   GROUP BY district, friendly_type ) SELECT   d.district AS x_axis,   t.friendly_type AS y_axis,   COALESCE(a.data, 0) AS data FROM district_list d CROSS JOIN type_list t LEFT JOIN aggregated a ON a.district = d.district AND a.friendly_type = t.friendly_type ORDER BY   array_position(ARRAY(     SELECT district FROM district_list   ), d.district),   array_position(ARRAY(     SELECT friendly_type FROM type_list   ), t.friendly_type);',
        NULL,
        'metrotaipei'
    );
