import requests
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from datetime import datetime

def get_data(stations):
    # initialize list for results
    results = []

    #api endpoint
    endpointurl = "https://marudor.de/api/iris/v2/abfahrten/"

    payload= {"lookbehind":"360"}

    for station in stations:
        url = f"{endpointurl}{station}"
        r = requests.get(url, params=payload)
        results.extend(r.json()["lookbehind"])

    return results


def normalize_data(results):
    # create pandas dataframe from normalized JSON
    dat = pd.json_normalize(results, meta=["initialDeparture","scheduledDestination","id","substitute","cancelled","currentStopPlace.evaNumber",
        "train.name","train.number","train.line","train.type","messages.delay","messages.qos","messages.him"])

    # drop 'route' column
    dat = dat.drop(['route'], axis=1)

    return dat


def save_data(dat):
    # add logtime column with current time
    dat.insert(0, 'logtime', pd.to_datetime(datetime.now()).replace(microsecond=0))
    
    # convert pandas dataframe to arrow table
    table = pa.Table.from_pandas(dat)

    # define GCP bucket name and file name
    bucket_name = "nwb_api_input"
    current_time = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    file_name = f"nwb_results_{current_time}.parquet"
    
    # define GCP storage path
    storage_path = f"gs://{bucket_name}/{file_name}"
    
    # write arrow table to parquet file in GCP bucket
    pq.write_table(table, storage_path)
    
    print("Data saved successfully to GCP bucket!")

def main(data, context):
    # define list of stations to request
    stations = ["8000086","8000317","8005225","8005910","8000644","8005059","8004023","8000500","8006630"]
    
    # get data from API
    results = get_data(stations)
    
    # normalize data
    dat = normalize_data(results)
    
    # save data to GCP bucket
    save_data(dat)
