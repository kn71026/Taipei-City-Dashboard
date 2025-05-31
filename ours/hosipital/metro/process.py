import os
from pathlib import Path
from dotenv import load_dotenv
import pandas as pd
import requests
import re


def process_hosp(hosp_type):
    df = pd.read_csv(f"{hosp_type}.csv", encoding="utf-8")
    df["類型"] = hosp_type

    # filter only [臺北市, 台北市, 新北市]
    def is_in_taipei_or_newtaipei(address):
        return "台北" in address or "臺北" in address or "新北" in address

    df = df[df["地址"].apply(is_in_taipei_or_newtaipei)]

    return df


def geocode_with_mapbox(address: str):
    """使用 Mapbox 將地址轉換為經緯度座標"""
    # Get the root directory path (3 levels up from current file)
    root_dir = Path(__file__).parent.parent.parent.parent
    load_dotenv(root_dir / ".env")
    # 替換成你自己的 Mapbox token
    MAPBOX_TOKEN = os.getenv("MAPBOX_TOKEN")

    url = f"https://api.mapbox.com/geocoding/v5/mapbox.places/{address}.json"
    params = {
        "access_token": MAPBOX_TOKEN,
        "limit": 1,
        "country": "TW",
    }
    try:
        resp = requests.get(url, params=params).json()
        print(resp)
        features = resp.get("features")
        if features:
            lon, lat = features[0]["geometry"]["coordinates"]
            print(f"Geocoding success for {address}: {lon}, {lat}")
            return (lon, lat)
    except Exception as e:
        print(f"Geocoding failed for {address}: {e}")
    return None


def clean_address(address: str) -> str:
    # 只保留到門牌號碼
    address = re.search(r"^.*?號", address)
    if address:
        return address.group(0)
    return address.strip()


if __name__ == "__main__":

    # 地區醫院
    hosp_types = ["地區醫院", "區域醫院", "醫學中心"]

    total_df = pd.DataFrame()
    for t in hosp_types:
        df = process_hosp(t)
        total_df = pd.concat([total_df, df])

    total_df.to_csv("metro_hospital.csv", index=False)

    # geocoding
    total_df["地址"] = total_df["地址"].apply(clean_address)
    total_df[["lng", "lat"]] = (
        total_df["地址"].apply(geocode_with_mapbox).apply(pd.Series)
    )

    # add district
    def get_city(address):
        return address.split("市")[0] + "市"

    def get_district(address):
        part = address.split("市")[1]
        return part.split("區")[0] + "區"

    total_df["市"] = total_df["地址"].apply(get_city)
    total_df["行政區"] = total_df["地址"].apply(get_district)

    total_df.to_csv("hospital_metrotaipei.csv", index=False)

    # filter only taipei by[台北市,臺北市]
    def is_in_taipei(address):
        return "台北" in address or "臺北" in address

    total_df = total_df[total_df["地址"].apply(is_in_taipei)]
    total_df.to_csv("hospital_taipei.csv", index=False)
