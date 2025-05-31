DO $$
DECLARE
    target_index text := 'women_children_secure';
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
VALUES (741, 'women_children_secure', '婦幼安全');

-- component_charts
INSERT INTO public.component_charts (index, color, types, unit) 
VALUES ('women_children_secure',ARRAY['#24B0DD','#56B96D','#F8CF58','#F5AD4A','#E170A6','#ED6A45','#AF4137','#10294A']::text[],'{DistrictChart,ColumnChart,DonutChart}', '件');

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
        'women_children_secure_tpe',
        '婦幼被害',
        'circle',
        'geojson',
        'big',
        'heatmap',
        '{"circle-color":"#4CAF50","circle-radius":6,"circle-opacity":0.8,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}',
        '[{"key":"location","name":"location"},{"key":"precinct","name":"precinct"}]'
    ),
    (
        '2',
        'women_children_secure_metrotaipei',
        '婦幼被害',
        'circle',
        'geojson',
        'big',
        'heatmap',
        '{"circle-color":"#4CAF50","circle-radius":6,"circle-opacity":0.8,"circle-stroke-width":1,"circle-stroke-color":"#ffffff"}',
        '[{"key":"location","name":"location"},{"key":"precinct","name":"precinct"}]'
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
        'women_children_secure',
        'null',
        '{1}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '臺北市政府',
        '顯示臺北市婦幼被害統計',
        '顯示臺北市婦幼被害統計',
        '適用於婦幼安全分析、婦幼安全規劃等用途。市民可透過此資料找到符合需求的婦幼安全資料，政府單位可評估各區域的婦幼安全建置成效，並規劃相關輔導措施。',
        '{https://data.gov.tw/dataset/145628}',
        '{doit}',
        '2024-03-21 05:56:00+00',
        '2025-05-24 18:13:43.063599+00',
        'two_d',
        '${CHART_QUERY_TAIPEI}',
        NULL,
        'taipei'
    ),
    (
        'women_children_secure',
        'null',
        '{1,2}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '雙北政府',
        '顯示雙北市婦幼被害統計',
        '顯示雙北地區在各行政區婦幼被害的分布情況，包括性侵害、性騷擾、家庭暴力、兒童及少年保護等類型。此資料有助於了解雙北各區域對不同族群的友善程度，提供市民選擇消費場所的參考，也可作為政策制定的依據。',
        '顯示雙北地區在各行政區婦幼被害的分布情況，包括性侵害、性騷擾、家庭暴力、兒童及少年保護等類型。此資料有助於了解雙北各區域對不同族群的友善程度，提供市民選擇消費場所的參考，也可作為政策制定的依據。',
        '{https://data.ntpc.gov.tw/datasets/0dfd96ca-5da6-4733-b649-9b78cecc136b}',
        '{doit,ntpc}',
        '2024-03-21 05:58:00+00',
        '2025-05-24 18:17:05.602385+00',
        'two_d',
        '${CHART_QUERY_METROTAIPEI}',
        NULL,
        'metrotaipei'
    );