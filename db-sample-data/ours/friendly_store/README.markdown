## Add this component to DB

1. input `data/dashboard/frinedly_stores_data.sql` into db `dashboard`
2. input `data/dashboardmanager/friendly_store_component.sql` into db `dashboardmanager`
3. Done! the new component id: `741`

---

## Note: the workflow of developing this component

以下是記錄一下開發時的流程

1. Prepare component's chart data

```sh
cd data
python gen_data_sql.py
generate data/dashboard/frinedly_stores_data.sql
```

2. Prepare geojson: use npm CLI to convert csv

https://mapbox.github.io/csv2geojson/

- 2.1 translate column name into English in CSV

```
name,address,longitude,latitude,phone,description,english_friendly,japanese_friendly,korean_friendly,mobile_charging,accessibility_friendly,gender_friendly,digital_payment_friendly,vegetarian_friendly,restroom_friendly,fair_trade_friendly,free_wifi,bike_friendly,breastfeeding_friendly,muslim_friendly,menstruation_friendly,friendly_feature_count
```

- 2-2. convert

```sh
csv2geojson --lat lat  --lon long 11405-友善店家總表.csv > friendly_stores.json
```

3. Write the component's data in`root.template.sql` and `queries/*.sql`

- query_chart 使用的 SQL 被另外放在 queries 資料夾下，方便複製執行

4. 執行 `./generate` ，會將 queries 到套用 root.tempalte.sql 產生一個完整的 component SQL

- data/dashboardmanager/friendly_store_component.sql
