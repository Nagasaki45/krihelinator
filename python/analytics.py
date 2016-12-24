import json
import pandas as pd

def process(json):
    return (pd.read_json(json)
            .set_index('timestamp')
            .groupby('name')
            .resample('D')
            .mean()
            .interpolate()  # Fill NaNs by interpolating
            .reset_index()
            .to_json(orient='records', date_format='iso'))
