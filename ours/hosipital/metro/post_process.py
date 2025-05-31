import pandas as pd


def clean(file):
    df = pd.read_csv(file)
    df = df[
        [
            "醫事機構代碼",
            "醫事機構名稱",
            "醫事機構種類",
            "電話",
            "地址",
            "行政區",
            "市",
            "lng",
            "lat",
            "類型",
        ]
    ]
    df.to_csv(file.replace(".csv", "_cleaned.csv"), index=False)


if __name__ == "__main__":

    clean("hospital_metrotaipei.csv")
    clean("hospital_taipei.csv")
