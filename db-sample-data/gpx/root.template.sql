DO $$
DECLARE
    target_index text := 'gpx';
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
VALUES (1337, 'gpx', '登山步道路線圖');

-- component_charts
INSERT INTO public.component_charts (index, color, types, unit) 
VALUES ('gpx',ARRAY['#4CAF50']::text[],'{MapLegend}', '條');

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
        '30',
        'gpx_tpe',
        '登山步道路線圖',
        'line',
        'geojson',
        NULL,
        NULL,
		'{"line-color":"#4CAF50"}',
        '[{"key":"name","name":"登山步道名稱"}]'
    ),
    (
        '31',
        'gpx_metrotaipei',
        '登山步道路線圖',
        'line',
        'geojson',
        NULL,
        NULL,
		'{"line-color":"#4CAF50"}',
        '[{"key":"name","name":"登山步道名稱"}]'
    );

-- -- query_charts
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
        'gpx',
        null,
        '{30}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '登山步道路線圖',
        '顯示臺北市登山步道路線圖',
        '顯示臺北市登山步道路線圖',
        '適用於登山步道路線圖分析、登山步道路線圖規劃等用途。市民可透過此資料找到符合需求的登山步道路線圖資料，政府單位可評估各區域的登山步道路線圖建置成效，並規劃相關輔導措施。',
        '{https://data.gov.tw/dataset/145628}',
        '{doit}',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        'map_legend',
		'SELECT ''登山步道'' AS name, ''line'' AS type, NULL AS icon;',
        NULL,
        'taipei'
    ),
    (
        'gpx',
        null,
        '{31}',
        '{}',
        'static',
        NULL,
        NULL,
        NULL,
        '登山步道路線圖',
        '顯示雙北市登山步道路線圖',
        '顯示雙北市登山步道路線圖',
		'適用於登山步道路線圖分析、登山步道路線圖規劃等用途。市民可透過此資料找到符合需求的登山步道路線圖資料，政府單位可評估各區域的登山步道路線圖建置成效，並規劃相關輔導措施。',
        NULL,
        '{doit,ntpc}',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        'map_legend',
        'SELECT ''登山步道'' AS name, ''line'' AS type, NULL AS icon;',
        NULL,
        'metrotaipei'
    );