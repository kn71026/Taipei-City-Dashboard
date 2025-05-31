DO $$
DECLARE
    target_index text := 'elder_care_location';
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
VALUES (742, 'elder_care_location', '長照機構分佈');

-- component_charts
INSERT INTO public.component_charts (index, color, types, unit) 
VALUES ('elder_care_location',ARRAY['#F5AD4A','#ED6A45']::text[],'{BarChart,ColumnChart}', '%');

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
        '5',
        'elder_care_location_tpe',
        '台北市長照機構分佈',
        'fill',
        'geojson',
        'big',
        'heatmap',
        '{
            "fill-color": "orange",
            "fill-opacity": 0.2,
            "fill-outline-color": "red"   
        }',
        '[{"key":"hosp_name","name":"機構名稱"},{"key":"hosp_addr","name":"地址"},{"key":"phone","name":"電話"}]'
    ),
    (
        '6',
        'elder_care_location_metrotaipei',
        '雙北市長照機構分佈',
        'fill',
        'geojson',
        'big',
        'heatmap',
        '{
            "fill-color": "orange",
            "fill-opacity": 0.5,
            "fill-outline-color": "red"   
        }',
        '[{"key":"hosp_name","name":"機構名稱"},{"key":"hosp_addr","name":"地址"},{"key":"phone","name":"電話"}]'
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
        'elder_care_location',
        'null',
        '{5}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '臺北市政府',
        '顯示臺北市長照機構分佈',
        '顯示臺北市長照機構分佈',
        '適用於長照機構分佈分析、長照機構分佈規劃等用途。市民可透過此資料找到符合需求的長照機構資料，政府單位可評估各區域的長照機構建置成效，並規劃相關輔導措施。',
        '{https://data.gov.tw/dataset/121983}',
        '{doit}',
        '2024-03-21 05:56:00+00',
        '2025-05-24 18:13:43.063599+00',
        'two_d',
        'SELECT      all_districts.district as x_axis,     COALESCE(elder_care_location.ratio, 0) as data FROM (     SELECT unnest(ARRAY[         ''北投區'', ''士林區'', ''內湖區'', ''南港區'', ''松山區'', ''信義區'', ''中山區'', ''大同區'', ''中正區'', ''萬華區'',          ''大安區'', ''文山區''     ]) as district ) all_districts LEFT JOIN (     SELECT district, ratio     FROM elder_care_location     GROUP BY district, ratio ) elder_care_location ON all_districts.district = elder_care_location.district ORDER BY array_position(ARRAY[     ''北投區'', ''士林區'', ''內湖區'', ''南港區'', ''松山區'', ''信義區'', ''中山區'', ''大同區'', ''中正區'', ''萬華區'',      ''大安區'', ''文山區'' ], all_districts.district);',
        NULL,
        'taipei'
    ),
    (
        'elder_care_location',
        'null',
        '{5,6}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '雙北政府',
        '顯示雙北市長照機構分佈',
        '顯示雙北市長照機構分佈',
        '適用於長照機構分佈分析、長照機構分佈規劃等用途。市民可透過此資料找到符合需求的長照機構資料，政府單位可評估各區域的長照機構建置成效，並規劃相關輔導措施。',
        '{https://data.ntpc.gov.tw/datasets/a0323809-1c7b-42f3-8dea-2b14f40118f7}',
        '{doit,ntpc}',
        '2024-03-21 05:58:00+00',
        '2025-05-24 18:17:05.602385+00',
        'two_d',
        'SELECT      all_districts.district as x_axis,     COALESCE(elder_care_location.ratio, 0) as data FROM (     SELECT unnest(ARRAY[         ''北投區'', ''士林區'', ''內湖區'', ''南港區'', ''松山區'', ''信義區'', ''中山區'', ''大同區'', ''中正區'', ''萬華區'',          ''大安區'', ''文山區'', ''新莊區'', ''板橋區'', ''三重區'', ''樹林區'', ''土城區'', ''蘆洲區'',          ''中和區'', ''永和區'', ''新店區'', ''鶯歌區'', ''五股區'', ''三芝區''     ]) as district ) all_districts LEFT JOIN (     SELECT district, ratio     FROM elder_care_location     GROUP BY district, ratio ) elder_care_location ON all_districts.district = elder_care_location.district ORDER BY array_position(ARRAY[     ''北投區'', ''士林區'', ''內湖區'', ''南港區'', ''松山區'', ''信義區'', ''中山區'', ''大同區'', ''中正區'', ''萬華區'',          ''大安區'', ''文山區'', ''新莊區'', ''板橋區'', ''三重區'', ''樹林區'', ''土城區'', ''蘆洲區'',          ''中和區'', ''永和區'', ''新店區'', ''鶯歌區'', ''五股區'', ''三芝區'' ], all_districts.district);',
        NULL,
        'metrotaipei'
    );