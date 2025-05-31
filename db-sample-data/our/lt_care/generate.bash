#!/bin/bash
set -e

# 將查詢 SQL 內容變成單行 + 單引號 escape
export CHART_QUERY_TAIPEI="$(cat queries/taipei.sql | sed "s/'/''/g" | tr '\n' ' ')"
export CHART_QUERY_METROTAIPEI="$(cat queries/metrotaipei.sql | sed "s/'/''/g" | tr '\n' ' ')"
echo "test"
# 替換變數並輸出(會將 root.template.sql 中的環境變數（如 $CHART_QUERY_TAIPEI）替換成實際值)
envsubst < root.template.sql | tee ../data/dashboardmanager/elder_care_location_component.sql

echo "✅ Created elder_care_location_component.sql"