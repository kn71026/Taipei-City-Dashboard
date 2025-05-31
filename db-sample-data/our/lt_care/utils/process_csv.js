const fs = require('fs');
const csv = require('csv-parser');
const { parse } = require('json2csv');

const inputFile = '../data/lt_care_tp.csv';
const outputFile = '../data/lt_care_tp_processed.csv';

// const columnsToRemove = [
//   '序號',
//   '郵遞區號',
//   '104年評鑑成績',
//   '105年評鑑成績',
//   '106年評鑑成績',
//   '107年評鑑成績',
//   '108年評鑑成績',
// ];
const columnsToRemove = [
  'seqno',
  'extension',
  'mobiletelephone',
  'service_area',
  'service_item',
  'contact_person',
  'twd97x',
  'wgs84ax',
  'wgs84ay',
];

// 台北市行政區列表
const districts = [
  '中正區', '大同區', '中山區', '松山區', '大安區', '萬華區',
  '信義區', '士林區', '北投區', '內湖區', '南港區', '文山區'
];

const results = [];

fs.createReadStream(inputFile, { encoding: 'utf8' })
  .pipe(csv({
    mapHeaders: ({ header }) => header.trim()
  }))
  .on('data', (data) => {
    // 移除指定欄位
    columnsToRemove.forEach(col => delete data[col]);
    
    // 從地址中提取行政區
    const address = data['地址'];
    let district = '';
    for (const d of districts) {
      if (address.includes(d)) {
        district = d;
        break;
      }
    }
    
    // 新增行政區欄位
    data['行政區'] = district;
    
    results.push(data);
  })
  .on('end', () => {
    const fields = Object.keys(results[0]);
    const opts = { 
      fields, 
      withBOM: true,
      header: true
    };
    const csvData = parse(results, opts);
    fs.writeFileSync(outputFile, csvData, { encoding: 'utf8' });
    console.log('處理完成，已輸出到', outputFile);
  }); 