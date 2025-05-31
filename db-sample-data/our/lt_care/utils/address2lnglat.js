require('dotenv').config();
const fs = require('fs');
const { parse } = require('csv-parse');
const stringify = require('csv-stringify').stringify;
const axios = require('axios');

const MAPBOX_TOKEN = process.env.MAPBOX_TOKEN;
const INPUT_CSV = '../data/lt_care_metro_processed.csv';
const OUTPUT_CSV = '../data/lt_care_metro_latlng.csv';
const RELEVANCE_THRESHOLD = 0.6; // 設定相關性閾值

async function geocode(address) {
    const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(address)}.json?access_token=${MAPBOX_TOKEN}&limit=1&language=zh-Hant`;
    try {
        const response = await axios.get(url);
        const features = response.data.features;
        if (features && features.length > 0) {
            const feature = features[0];
            // 檢查相關性分數
            if (feature.relevance >= RELEVANCE_THRESHOLD) {
                const [longitude, latitude] = feature.center;
                return { 
                    latitude, 
                    longitude,
                    relevance: feature.relevance,
                    place_name: feature.place_name
                };
            } else {
                console.log(`地址匹配度不足 (${feature.relevance}): ${address}`);
                return null;
            }
        }
    } catch (error) {
        console.error(`Geocoding error for address: ${address}`, error.message);
    }
    return null;
}

async function processCSV() {
    const records = [];
    const fileContent = fs.readFileSync(INPUT_CSV, 'utf8');
    // 移除 BOM 標記
    const cleanContent = fileContent.replace(/^\uFEFF/, '');
    
    const parser = parse(cleanContent, {
        columns: true,
        skip_empty_lines: true,
        bom: true
    });

    for await (const record of parser) {
        records.push(record);
    }

    const validRecords = [];
    let skippedCount = 0;

    for (const record of records) {
        const addr = record.hosp_addr;
        if (addr) {
            const result = await geocode(addr);
            if (result) {
                record.latitude = result.latitude;
                record.longitude = result.longitude;
                validRecords.push(record);
                console.log(`成功: ${addr} => ${result.latitude}, ${result.longitude} (相關性: ${result.relevance})`);
            } else {
                skippedCount++;
                console.log(`跳過: ${addr} - 無法找到準確位置`);
            }
        }
    }

    stringify(validRecords, { header: true }, (err, output) => {
        if (err) throw err;
        fs.writeFileSync(OUTPUT_CSV, output);
        console.log(`\n處理完成！`);
        console.log(`總筆數: ${records.length}`);
        console.log(`有效筆數: ${validRecords.length}`);
        console.log(`跳過筆數: ${skippedCount}`);
        console.log(`已輸出：${OUTPUT_CSV}`);
    });
}

processCSV().catch(console.error); 