const csv2geojson = require('csv2geojson');
const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch');

// 地理編碼函數
async function geocode(address) {
  try {
    // 清理地址字串
    const cleanAddress = address
      .replace(/[\(\)]/g, '') // 移除括號
      .replace(/、/g, '與')   // 將頓號替換為「與」
      .replace(/\s+/g, ' ')   // 將多個空格替換為單個空格
      .trim();

    // 嘗試不同的地址格式
    const addressVariations = [
      cleanAddress,
      `${cleanAddress}, 台北市`,
      `${cleanAddress}, 臺北市`,
      cleanAddress.replace('臺北市', '台北市'),
      cleanAddress.replace('台北市', '臺北市'),
      // 特別處理捷運站
      cleanAddress.replace('捷運', '捷運站'),
      cleanAddress.replace('捷運站站', '捷運站')
    ];

    for (const addr of addressVariations) {
      console.log(`嘗試地址: ${addr}`);
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(addr)}&countrycodes=tw&limit=1`
      );
      const data = await response.json();
      
      if (data && data.length > 0) {
        // 檢查結果是否在台北市範圍內
        const result = data[0];
        const lat = parseFloat(result.lat);
        const lon = parseFloat(result.lon);
        
        // 台北市的大致範圍檢查
        if (lat >= 24.9 && lat <= 25.2 && lon >= 121.4 && lon <= 121.7) {
          console.log(`找到匹配: ${addr}`);
          return { lat, lon };
        }
      }
    }
    
    console.warn(`無法找到地址的經緯度: ${address}`);
    return null;
  } catch (error) {
    console.error(`地理編碼錯誤 (${address}):`, error);
    return null;
  }
}

// 主函數
async function main() {
  // 讀取 CSV 檔案
  const csvString = fs.readFileSync(path.join(__dirname, '..', 'data', 'tp_wcs.csv'), 'utf-8');
  const rows = csvString.split('\n').map(row => row.split(','));
  
  // 只保留需要的欄位：地點位置、管轄分局
  const headers = ['地點位置', '管轄分局', 'latitude', 'longitude'];
  
  // 儲存成功轉換的資料
  const successfulRows = [headers];
  
  // 處理每一行資料
  for (let i = 1; i < rows.length; i++) {
    if (rows[i].length < 2) continue; // 跳過空行
    
    const address = rows[i][1]; // 地點位置欄位
    const policeStation = rows[i][2]; // 管轄分局欄位
    console.log(`\n處理地址: ${address}`);
    
    const coords = await geocode(address);
    if (coords) {
      // 只保留需要的欄位
      const newRow = [
        address,
        policeStation,
        coords.lat.toString(),
        coords.lon.toString()
      ];
      successfulRows.push(newRow);
    }
    
    // 避免過於頻繁的請求
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  // 將處理後的資料寫入新的 CSV
  const newCsvString = successfulRows.map(row => row.join(',')).join('\n');
  const tempCsvPath = path.join(__dirname, '..', 'data', 'tp_wcs_with_coords.csv');
  fs.writeFileSync(tempCsvPath, newCsvString, 'utf-8');
  
  // 檢查結果
  const processedRows = rows.filter(row => row.length > 1);
  const successfulCount = successfulRows.length - 1; // 減去標題行
  
  console.log('\n處理結果統計：');
  console.log(`總筆數: ${processedRows.length}`);
  console.log(`成功轉換: ${successfulCount}`);
  console.log(`排除筆數: ${processedRows.length - successfulCount}`);
  
  // 設定 GeoJSON 轉換選項
  const options = {
    latfield: 'latitude',
    lonfield: 'longitude',
    delimiter: ',',
    encoding: 'utf-8'
  };
  
  // 轉換為 GeoJSON
  csv2geojson.csv2geojson(newCsvString, options, (err, data) => {
    if (err) {
      console.error('轉換過程中發生錯誤：', err);
      return;
    }
    
    // 將結果寫入檔案
    const outputPath = path.join(__dirname, '..', 'data', 'tp_wcs.geojson');
    fs.writeFileSync(outputPath, JSON.stringify(data, null, 2), 'utf-8');
    console.log(`\n轉換完成！結果已儲存至：${outputPath}`);
  });
}

main().catch(console.error); 