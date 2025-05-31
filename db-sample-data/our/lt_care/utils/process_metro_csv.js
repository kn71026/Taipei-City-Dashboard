const fs = require('fs');
const csv = require('csv-parse/sync');
const { stringify } = require('csv-stringify/sync');

// 讀取原始 CSV 檔案
const inputFile = '../data/lt_care_metro.csv';
const outputFile = '../data/lt_care_metro_processed.csv';

// 讀取檔案內容
const fileContent = fs.readFileSync(inputFile, 'utf-8');

// 解析 CSV
const records = csv.parse(fileContent, {
  columns: true,
  skip_empty_lines: true
});

// 處理每一筆資料
const processedRecords = records.map(record => {
  // 從地址中提取行政區
  const districtMatch = record.hosp_addr.match(/新北市([^區]+)區/);
  const district = districtMatch ? districtMatch[1] : '';

  // 建立新的記錄，移除指定欄位並新增 district
  return {
    hosp_name: record.hosp_name,
    phone: record.phone,
    hosp_addr: record.hosp_addr,
    district: district
  };
});

// 將處理後的資料寫入新的 CSV 檔案
const output = stringify(processedRecords, {
  header: true,
  columns: ['hosp_name', 'hosp_addr','phone', 'district']
});

fs.writeFileSync(outputFile, output);
console.log('處理完成！新檔案已儲存為：', outputFile); 