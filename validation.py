import logging

# Configure logging to be simple and easy to read
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

def validate_job(job_data):
    """
    Validates a single job dictionary by checking for the presence of required keys.
    This is intended to detect API changes where fields might be dropped.
    
    Args:
        job_data (dict): A dictionary representing a single job.
        
    Returns:
        tuple: (is_valid, error_message)
            - is_valid (bool): True if the job is valid, False otherwise.
            - error_message (str or None): The error message if invalid, None if valid.
    """
    # Define fields that must be present in the API response keys.
    required_keys = [
        'id', 
        'title', 
        'company', 
        'location', 
        'description',
        'salary_min', 
        'salary_max', 
        'contract_time', 
        'category', 
        'created'
    ]

    errors = []
    
    # Check if the key exists in the dictionary
    for key in required_keys:
        if key not in job_data:
            errors.append(f"Missing key: '{key}'")
    
    # If there are any missing keys, return False and the error message
    if errors:
        error_msg = "; ".join(errors)
        logging.warning(f"Invalid Job Structure: {error_msg} | Job ID: {job_data.get('id', 'Unknown')}")
        return False, error_msg
    
    return True, None
