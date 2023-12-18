import pandas as pd
from influxdb_client import InfluxDBClient
from influxdb_client.client.write_api import SYNCHRONOUS
import datetime


class INSERTDATA:

   def __init__(self):
        self.client = InfluxDBClient(url = "http://localhost:8086", token="xJVlOom1GRUxDNkldo1v")


def explode(df):
     for col in df.columns:
             if isinstance(df.iloc[0][col], list):
                     df = df.explode(col)
             d = df[col].apply(pd.Series)
             df[d.columns] = d
             df = df.drop(col, axis=1)
     return df


def jsonToTable(df):
     df.index = range(len(df))
     cols = [col for col in df.columns if isinstance(df.iloc[0][col], dict) or isinstance(df.iloc[0][col], list)]
     if len(cols) == 0:
             return df
     for col in cols:
             d = explode(pd.DataFrame(df[col], columns=[col]))
             d = d.dropna(axis=1, how='all')
             df = pd.concat([df, d], axis=1)
             df = df.drop(col, axis=1).dropna()
     return jsonToTable(df)


def time(df):
     df.index = pd.date_range(start=datetime.datetime.now(), freq='10ms', periods=len(df))
     df['measTimeStampRf'] = df['measTimeStampRf'].apply(lambda x: str(x))
     return df


def populatedb():
     df = pd.read_json('cell.json', lines=True)
     df = df[['cellMeasReport']].dropna()
     df = jsonToTable(df)
     df = time(df)
     db = INSERTDATA()
     write_api = db.client.write_api(write_options=SYNCHRONOUS)
     write_api.write(bucket="UEData",record=df, data_frame_measurement_name="liveCell",org="primary")

populatedb()
