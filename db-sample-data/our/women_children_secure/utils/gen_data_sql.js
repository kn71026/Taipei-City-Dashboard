const fs = require('fs');
const path = require('path');
const csv = require('csv-parse/sync');

function csvToSql(csvFilePath, outputSqlPath, tableName = 'women_children_secure') {
    try {
        // 讀取 CSV 文件
        const csvContent = fs.readFileSync(csvFilePath, 'utf-8');
        const records = csv.parse(csvContent, {
            columns: true,
            skip_empty_lines: true,
            quote: '"'
        });

        // 選擇需要的欄位
        const selectedColumns = [
            'location',
            'precinct',
            'longitude',
            'latitude'
        ];

        // 檢查欄位是否存在
        const missingColumns = selectedColumns.filter(col => !records[0] || !(col in records[0]));
        if (missingColumns.length > 0) {
            console.log(`警告：以下欄位在 CSV 中不存在：${missingColumns.join(', ')}`);
            // 只選擇存在的欄位
            selectedColumns = selectedColumns.filter(col => records[0] && col in records[0]);
        }

        // 生成 SQL
        const sqlStatements = [];

        // 創建表格的 SQL
        const createTableSql = `
DROP TABLE IF EXISTS ${tableName};
-- 創建表格
CREATE TABLE IF NOT EXISTS ${tableName} (
    id SERIAL PRIMARY KEY,
    precinct TEXT,
    location TEXT,
    longitude DECIMAL(10, 7),
    latitude DECIMAL(10, 7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
`;
        sqlStatements.push(createTableSql);

        // 生成 INSERT 語句
        sqlStatements.push(`\n-- 插入資料`);
        sqlStatements.push(`INSERT INTO ${tableName} (location, precinct, longitude, latitude) VALUES`);

        const insertValues = records.map(record => {
            const values = selectedColumns.map(col => {
                const value = record[col];
                if (value === undefined || value === null || value === '') {
                    return 'NULL';
                } else if (['longitude', 'latitude'].includes(col)) {
                    // 數字欄位
                    return value;
                } else {
                    // 字串欄位 - 處理單引號轉義
                    return `'${value.replace(/'/g, "''")}'`;
                }
            });
            return `    (${values.join(', ')})`;
        });

        // 組合所有 INSERT 值
        sqlStatements.push(insertValues.join(',\n') + ';');

        // 寫入 SQL 文件
        fs.writeFileSync(outputSqlPath, sqlStatements.join('\n'), 'utf-8');

        console.log('✅ 轉換完成！');
        console.log(`📄 輸入文件：${csvFilePath}`);
        console.log(`💾 輸出文件：${outputSqlPath}`);
        console.log(`📊 處理了 ${records.length} 筆資料`);
        console.log(`🔍 保留的欄位：${selectedColumns.join(', ')}`);

        // 顯示生成的 SQL 文件的前幾行
        console.log('\n📝 生成的 SQL 文件前幾行預覽：');
        console.log('-'.repeat(50));
        const previewLines = sqlStatements.join('\n').split('\n').slice(0, 20);
        previewLines.forEach((line, index) => {
            console.log(`${(index + 1).toString().padStart(2)}: ${line}`);
        });
        if (sqlStatements.join('\n').split('\n').length > 20) {
            console.log('... (更多內容)');
        }

    } catch (error) {
        console.error(`❌ 錯誤：${error.message}`);
    }
}

function main() {
    // 設定文件路徑
    const csvFile = path.join(__dirname, '..', 'data', 'w_c_s_總表.csv');
    const outputFile = path.join(__dirname, '..', '..', 'data', 'dashboard', 'women_children_secure_data.sql');

    // 檢查 CSV 文件是否存在
    if (!fs.existsSync(csvFile)) {
        console.log(`❌ CSV 文件不存在：${csvFile}`);
        console.log('請確認文件路徑是否正確');
        return;
    }

    // 執行轉換
    csvToSql(csvFile, outputFile);
}

main(); 