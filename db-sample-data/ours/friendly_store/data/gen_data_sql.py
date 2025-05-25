import pandas as pd
import os

def csv_to_sql(csv_file_path, output_sql_path, table_name='friendly_stores'):
    """
    將 CSV 轉換為 SQL INSERT 語句
    只保留指定的欄位：名稱、地址、經度、緯度、電話、簡介、英文友善、性別友善、無障礙友善、穆斯林友善
    """
    
    try:
        # 讀取 CSV 文件
        df = pd.read_csv(csv_file_path, encoding='utf-8',quotechar='"')
        
        # 選擇需要的欄位
        selected_columns = [
            '友善店家名稱',
            '地址', 
            '經度',
            '緯度',
            '電話',
            '簡介',
            '性別友善', 
            '無障礙友善',
            '穆斯林友善'
        ]
        
        # 檢查欄位是否存在
        missing_columns = [col for col in selected_columns if col not in df.columns]
        if missing_columns:
            print(f"警告：以下欄位在 CSV 中不存在：{missing_columns}")
            # 只選擇存在的欄位
            selected_columns = [col for col in selected_columns if col in df.columns]
        
        # 選取指定欄位
        df_selected = df[selected_columns].copy()
        
        # 生成 SQL
        sql_statements = []
        
        # 創建表格的 SQL（可選）
        create_table_sql = f"""
DROP TABLE IF EXISTS {table_name};
-- 創建表格
CREATE TABLE IF NOT EXISTS {table_name} (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    address TEXT,
    longitude DECIMAL(10, 7),
    latitude DECIMAL(10, 7),
    phone VARCHAR(100),
    description TEXT,
    gender_friendly INTEGER,
    accessibility_friendly INTEGER,
    muslim_friendly INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""
        sql_statements.append(create_table_sql)
        
        # 生成 INSERT 語句
        sql_statements.append(f"\n-- 插入資料")
        sql_statements.append(f"INSERT INTO {table_name} (name, address, longitude, latitude, phone, description, gender_friendly, accessibility_friendly, muslim_friendly) VALUES")
        
        insert_values = []
        for index, row in df_selected.iterrows():
            # 處理每個值，確保字串有引號，NULL 值正確處理
            values = []
            for col in selected_columns:
                value = row[col]
                if pd.isna(value) or value == '':
                    values.append('NULL')
                elif col in ['經度', '緯度', '性別友善', '無障礙友善', '穆斯林友善']:
                    # 數字欄位
                    values.append(str(value))
                else:
                    # 字串欄位 - 處理單引號轉義
                    escaped_value = str(value).replace("'", "''")
                    values.append(f"'{escaped_value}'")
            
            insert_values.append(f"    ({', '.join(values)})")
        
        # 組合所有 INSERT 值
        sql_statements.append(',\n'.join(insert_values) + ';')
        
        # 寫入 SQL 文件
        with open(output_sql_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(sql_statements))
        
        print(f"✅ 轉換完成！")
        print(f"📄 輸入文件：{csv_file_path}")
        print(f"💾 輸出文件：{output_sql_path}")
        print(f"📊 處理了 {len(df_selected)} 筆資料")
        print(f"🔍 保留的欄位：{selected_columns}")
        
    except Exception as e:
        print(f"❌ 錯誤：{str(e)}")

def main():
    # 設定文件路徑
    csv_file = "11405-友善店家總表.csv"
    output_file = "../../data/dashboard/friendly_stores_data.sql"
    
    # 檢查 CSV 文件是否存在
    if not os.path.exists(csv_file):
        print(f"❌ CSV 文件不存在：{csv_file}")
        print("請確認文件路徑是否正確")
        return
    
    # 執行轉換
    csv_to_sql(csv_file, output_file)
    
    # 顯示生成的 SQL 文件的前幾行
    print("\n📝 生成的 SQL 文件前幾行預覽：")
    print("-" * 50)
    try:
        with open(output_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for i, line in enumerate(lines[:20]):  # 顯示前20行
                print(f"{i+1:2d}: {line.rstrip()}")
            if len(lines) > 20:
                print("... (更多內容)")
    except Exception as e:
        print(f"無法讀取輸出文件：{e}")

if __name__ == "__main__":
    main()