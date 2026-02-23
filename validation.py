import logging
import pandas as pd

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

def validate_job(job_data):
    """
    Checks for missing keys AND null values in critical fields.
    """
    # 1. Schema Shape: Are the keys present?
    required_keys = ['id', 'title', 'company', 'location', 'description', 'created']
    missing_keys = [key for key in required_keys if key not in job_data]

    if missing_keys:
        return False, f"Missing keys: {', '.join(missing_keys)}"

    # 2. Null Checks: Is the data actually there for critical fields?
    # We focus on 'id' and 'title' as they are the backbone of the dashboard.
    if not job_data.get('id') or str(job_data.get('id')).strip() == "":
        return False, "Critical Field Error: Job ID is null or empty"

    if not job_data.get('title') or str(job_data.get('title')).strip() == "":
        return False, "Critical Field Error: Job Title is null or empty"

    return True, None

def validate_batch(df):
    """
    Validation between layers: Checks the 'shape' of the entire dataframe before upload.
    """
    # 3. Row Count Validation
    if df.empty:
        logging.warning("Validation Alert: Batch is empty. No new rows to process.")
        return False

    # 4. Critical Field Null Check (Dataframe level)
    if df['id'].isnull().any():
        logging.error("Validation Failed: Found NULL values in the ID column.")
        return False

    logging.info(f"Validation Passed: {len(df)} rows are ready for ingestion.")
    return True
