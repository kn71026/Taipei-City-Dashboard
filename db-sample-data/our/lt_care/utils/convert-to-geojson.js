require('dotenv').config();
const fs = require('fs');
const { parse } = require('csv-parse');
const axios = require('axios');

const MAPBOX_TOKEN = process.env.MAPBOX_TOKEN;
const PROFILE = 'walking';
const CONTOURS_MINUTES = 15;
const INPUT_CSV = './h_metro.csv';
const OUTPUT_CSV = './h_metro.geojson';
async function getIsochrone(coordinates) {
    try {
        const url = `https://api.mapbox.com/isochrone/v1/mapbox/${PROFILE}/${coordinates}?contours_minutes=${CONTOURS_MINUTES}&access_token=${MAPBOX_TOKEN}`;
        const response = await axios.get(url);
        return response.data;
    } catch (error) {
        console.error(`Error fetching isochrone for coordinates ${coordinates}:`, error.message);
        return null;
    }
}

async function processCSV() {
    const records = [];
    const parser = fs
        .createReadStream(INPUT_CSV)
        .pipe(parse({
            columns: true,
            skip_empty_lines: true
        }));

    for await (const record of parser) {
        records.push(record);
    }

    const features = [];
    for (const record of records) {
        if (record.lng && record.lat) {
            const coordinates = `${record.lng},${record.lat}`;
            const isochrone = await getIsochrone(coordinates);
            
            if (isochrone && isochrone.features && isochrone.features.length > 0) {
                const coordinates = isochrone.features[0].geometry.coordinates;
                // 確保多邊形是封閉的（首尾座標相同）
                if (coordinates[0] !== coordinates[coordinates.length - 1]) {
                    coordinates.push(coordinates[0]);
                }
                const feature = {
                    type: 'Feature',
                    properties: {
                        ...record,
                        isochrone_minutes: CONTOURS_MINUTES
                    },
                    geometry: {
                        type: 'Polygon',
                        coordinates: [coordinates]
                    }
                };
                features.push(feature);
            }
        }
    }

    const geojson = {
        type: 'FeatureCollection',
        features: features
    };

    fs.writeFileSync(OUTPUT_CSV, JSON.stringify(geojson, null, 2));
    console.log(`轉換完成！輸出檔案：${OUTPUT_CSV}`);
}

processCSV().catch(console.error); 