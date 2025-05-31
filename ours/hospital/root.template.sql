DO $$
DECLARE
    target_index text := 'hospital';
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
VALUES (2486, 'hospital', '醫院');

-- component_charts
INSERT INTO public.component_charts (index, color, types, unit) 
VALUES ('hospital',ARRAY['#24B0DD','#56B96D','#F8CF58','#F5AD4A','#E170A6','#ED6A45','#AF4137','#10294A']::text[],'{ColumnChart,DistrictChart,PolarAreaChart}', '間');

-- component_maps
-- no map
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
        'hospital_taipei',
        '醫院',
        'circle',
        'geojson',
        'big',
        'heatmap',
        '{"circle-color":"#4CAF50","circle-radius":6,"circle-opacity":0.8,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}',
		'{}'
	),
    (
        '2',
        'hospital_metrotaipei',
        '醫院',
        'circle',
        'geojson',
        'big',
        'heatmap',
        '{"circle-color":"#4CAF50","circle-radius":6,"circle-opacity":0.8,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}',
        '{}'
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
        'hospital',
        'null',
        '{}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '衛生福利部中央健康保險署',
		'醫院分佈',
        '顯示臺北市各醫院的數量分布情況。',
        '適用於了解臺北市各醫院的數量分布情況。',
        '{https://data.gov.tw/dataset/39280}',
        '{doit}',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        'three_d',
        '${CHART_QUERY_TAIPEI}',
        NULL,
        'taipei'
    ),
    (
        'hospital',
        'null',
        '{}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '衛生福利部中央健康保險署',
		'醫院分佈',
        '顯示雙北市各醫院的數量分布情況。',
        '適用於了解雙北市各醫院的數量分布情況。',
		'{https://data.gov.tw/dataset/39280}',
        '{doit,ntpc}',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        'three_d',
        '${CHART_QUERY_METROTAIPEI}',
        NULL,
        'metrotaipei'
    );