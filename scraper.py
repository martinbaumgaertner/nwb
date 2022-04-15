import requests
from itertools import product
import pandas as pd
import json

# initialize list for results
results = []

#all stations to request
stations = ["8000086","8000317","8005225","8005910","8000644","8005059","8004023","8000500","8006630"]
#api endpoint
endpointurl = ["https://marudor.de/api/iris/v2/abfahrten/"]

res = ['%s%s' % (ele[0], ele[1]) for ele in product(endpointurl, stations)]

payload= {"lookbehind":"360"}

for station in res:
    r = requests.get(station,params=payload)
    dat = pd.json_normalize(r.json()["lookbehind"],meta=["initialDeparture","scheduledDestination","id","substitute","cancelled","currentStopPlace.evaNumber",
        "train.name","train.number","train.line","train.type","messages.delay","messages.qos","messages.him"])
    results.append(dat)

dat=pd.concat(results).drop(['route'], axis=1)
dat.insert(0, 'logtime', pd.to_datetime('now').replace(microsecond=0))
x=dat[dat["train.line"]=="RB31"]

x.to_csv('nwb.csv', index=False)