import requests
import pandas as pd
from google.cloud import bigquery
from google.cloud.exceptions import NotFound
from datetime import datetime
import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from ingestion.validation import validate_batch

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
KEY_PATH = os.path.join(CURRENT_DIR, "..", "keys", "gcp-key.json")

PROJECT_ID = "usd-data-engineering"
DATASET_ID = "labor_market"
TABLE_ID = "raw_job_postings"

APP_ID = os.getenv("ADZUNA_APP_ID")
APP_KEY = os.getenv("ADZUNA_APP_KEY")
BASE_URL = "https://api.adzuna.com/v1/api/jobs/us/search/1"

if not APP_ID or not APP_KEY:
    raise ValueError("Error: ADZUNA_APP_ID or ADZUNA_APP_KEY not found in environment.")

def get_existing_ids(client, table_ref):
    try:
        client.get_table(table_ref)
        query = f"SELECT DISTINCT id FROM `{table_ref}`"
        query_job = client.query(query)
        return set(row.id for row in query_job)
    except NotFound:
        return set()

def ingest_jobs():
    # SETUP CLIENT
    if os.path.exists(KEY_PATH):
        print(f"Using key at: {KEY_PATH}")
        client = bigquery.Client.from_service_account_json(KEY_PATH)
    else:
        client = bigquery.Client(project=PROJECT_ID)

    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"

    # FETCH DATA FROM API
    print("Fetching jobs from Adzuna...")
    params = {
        'app_id': APP_ID,
        'app_key': APP_KEY,
        'results_per_page': 20,
        'what': 'data engineer',
        'content-type': 'application/json'
    }

    response = requests.get(BASE_URL, params=params)
    data = response.json()

    if 'results' not in data:
        print("API returned no results or error.")
        return

    jobs = []
    for item in data['results']:
        jobs.append({
            'id': str(item.get('id')),
            'title': item.get('title'),
            'company': item.get('company', {}).get('display_name'),
            'location': item.get('location', {}).get('display_name'),
            'description': item.get('description'),
            'salary_min': item.get('salary_min'),
            'salary_max': item.get('salary_max'),
            'contract_type': item.get('contract_time'),
            'category': item.get('category', {}).get('label'),
            'created_at': item.get('created'),
            'ingested_at': datetime.now().isoformat()
        })

    new_df = pd.DataFrame(jobs)
    new_df['created_at'] = pd.to_datetime(new_df['created_at']).dt.strftime('%Y-%m-%d %H:%M:%S')
    new_df['ingested_at'] = pd.to_datetime(new_df['ingested_at']).dt.strftime('%Y-%m-%d %H:%M:%S')

    # DEDUPLICATION LOGIC
    print("Checking for duplicates...")
    existing_ids = get_existing_ids(client, table_ref)
    unique_df = new_df[~new_df['id'].isin(existing_ids)]

    # VALIDATION
    print("Running batch validation...")
    if not validate_batch(unique_df):
        # We raise a ValueError here so GitHub Actions sees the failure
        raise ValueError("Data Validation Failed: The batch contains null IDs or is improperly formatted.")

    # UPLOAD
    if unique_df.empty:
        print("No new jobs found. All 20 jobs were duplicates.")
    else:
        print(f"Found {len(unique_df)} NEW jobs passing validation.")
        job_config = bigquery.LoadJobConfig(
            write_disposition="WRITE_APPEND",
            schema_update_options=[bigquery.SchemaUpdateOption.ALLOW_FIELD_ADDITION]
        )
        load_job = client.load_table_from_dataframe(unique_df, table_ref, job_config=job_config)
        load_job.result()
        print(f"Success! Uploaded {len(unique_df)} rows.")

if __name__ == "__main__":
    ingest_jobs()