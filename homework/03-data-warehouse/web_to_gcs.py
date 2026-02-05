import io
import os
import time
import requests
import pandas as pd
from google.cloud import storage
from concurrent.futures import ThreadPoolExecutor

"""
1. Create GCS bucket using terraform
2. Change the bucket name to be the one created using terraform
"""

BUCKET_NAME = "fit-reference-447221-v2-hw3-bucket"
CLIENT = storage.Client()
BUCKET = CLIENT.bucket(BUCKET_NAME)

BASE_URL = 'https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-' # 01.parquet'
MONTHS = [f"{i:02d}" for i in range(1, 7)] # January 2024 - June 2024
DOWNLOAD_DIR = "./data"
CHUNK_SIZE = 8 * 1024 * 1024  # 8 MB

def upload_to_gcs(file_path, max_retries=3):
    """
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    """
    
    blob_name = os.path.basename(file_path) 
    blob = BUCKET.blob(blob_name) # destination blob name
    blob.chunk_size = CHUNK_SIZE
    
    for attempt in range(max_retries):
        try:
            print(f"Uploading {file_path} to GCS: {blob_name} (Attempt {attempt + 1}/{max_retries})")
            blob.upload_from_filename(file_path) # source file name
            print(f"Uploaded: gs://{BUCKET_NAME}/{blob_name}")
            
            if verify_gcs_upload(blob_name):
                print(f"Verified: gs://{BUCKET_NAME}/{blob_name}")
                return
            else:
                print(f"Failed to verify: gs://{BUCKET_NAME}/{blob_name}, retrying...")
        except Exception as e:
            print(f"Failed to upload {file_path} to GCS: {e}, retrying...")
        
        time.sleep(5)
        
    print(f"Failed to upload {file_path} after {max_retries} attempts.")
            
            
def verify_gcs_upload(blob_name):
    return BUCKET.blob(blob_name).exists(CLIENT)


def download_file(month):
    url = f"{BASE_URL}{month}.parquet"
    file_path = os.path.join(DOWNLOAD_DIR, f"yellow_trip_data_2024-{month}.parquet")
    
    try: 
        r = requests.get(url, stream=True)
        with open(file_path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=CHUNK_SIZE):
                f.write(chunk)
        print(f"Downloaded: {file_path}")
        return file_path
    except requests.exceptions.RequestException as e:
        print(f"Failed to download {url}: e")
        return None


if __name__ == '__main__':
    with ThreadPoolExecutor(max_workers=4) as executor:
        file_paths = list(executor.map(download_file, MONTHS))
    
    with ThreadPoolExecutor(max_workers=4) as executor:
        executor.map(upload_to_gcs, filter(None, file_paths))
    
    print("All files processed and verified.")