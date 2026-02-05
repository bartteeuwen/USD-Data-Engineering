# Data Engineering Labor Market Pipeline

![Build Status](https://github.com/bartteeuwen/USD-Data-Engineering/actions/workflows/daily_pipeline.yml/badge.svg)
![Python](https://img.shields.io/badge/python-3.9-blue)
![GCP](https://img.shields.io/badge/Google_Cloud-BigQuery-green)

An automated **ELT (Extract, Load, Transform)** pipeline that tracks the "Data Engineering" job market in real-time. It ingests job postings daily from the **Adzuna API**, stores them in **Google BigQuery**, and transforms the raw text to identify high-demand technical skills (e.g., Python, SQL, Spark) using a custom O*NET skill-matching algorithm.

---

## 1. Repository Overview

This repository contains all the code required to run the end-to-end data pipeline.

| Folder/File | Description |
| :--- | :--- |
| **`.github/workflows/`** | Contains `daily_pipeline.yml`, the orchestration file that triggers the pipeline every 6 hours via GitHub Actions. |
| **`ingestion/`** | Python scripts for connecting to the Adzuna API, deduplicating records, and loading data into BigQuery (Bronze Layer). |
| **`transformation/`** | SQL scripts for the ELT process. Includes `match_skills.sql` (skill tagging) and `aggregate_counts.sql` (analytics). |
| **`requirements.txt`** | List of Python dependencies (pandas, google-cloud-bigquery, etc.) required to run the project. |
| **`keys/`** | (Local Only) Directory for storing local service account keys. *Note: This folder is git-ignored for security.* |

---

## 2. How to Deploy the Pipeline

This pipeline is designed to run automatically using **GitHub Actions**. You do not need a dedicated server; GitHub's runners handle the execution.

### Step 1: Fork or Clone
Clone this repository to your GitHub account.

### Step 2: Configure Secrets
For the pipeline to access Google Cloud and Adzuna without exposing passwords, you must set up **Repository Secrets**.

1. Go to your GitHub Repository.
2. Navigate to **Settings** > **Secrets and variables** > **Actions**.
3. Click **New repository secret** and add the following:

| Secret Name | Value |
| :--- | :--- |
| `GCP_SA_KEY` | The entire JSON content of your Google Cloud Service Account Key. |
| `ADZUNA_APP_ID` | Your Adzuna Application ID. |
| `ADZUNA_APP_KEY` | Your Adzuna Application Key. |

### Step 3: Activate the Workflow
The pipeline is scheduled to run automatically every 6 hours. To enable it:
1. Go to the **Actions** tab in your repository.
2. Click **I understand my workflows, go ahead and enable them** (if prompted).
3. The `daily_pipeline.yml` will now run on the defined schedule.

---

## 3. How to Monitor the Pipeline

You can monitor the health and status of the pipeline directly from GitHub.

### 🟢 Check Status
1. Navigate to the **Actions** tab in your repository.
2. Select **USD Data Engineering Pipeline** from the left sidebar.
3. You will see a list of runs:
   - **Green Checkmark (✅):** The job completed successfully. Data has been updated in BigQuery.
   - **Red Cross (❌):** The job failed.
   - **Yellow Circle:** The job is currently running or queued.

### Debugging Errors
If a run fails:
1. Click on the failed run title (e.g., "USD Data Engineering Pipeline #45").
2. Click on the **run-data-pipeline** job bubble.
3. Expand the specific step that failed (e.g., "Run Ingestion Script") to view the error logs.

### Manual Trigger
To force the pipeline to run immediately (for testing or demos):
1. Go to the **Actions** tab.
2. Select the pipeline.
3. Click the **Run workflow** button on the right side.
4. Select the `main` branch and click the green **Run workflow** button.

---

## Architecture
The pipeline follows a modern **Medallion Architecture** (Raw $\rightarrow$ Structured $\rightarrow$ Aggregated):

```mermaid
graph LR
    A[Adzuna API] -->|JSON| B(Python Ingestion Script);
    B -->|Upload| C[(BigQuery: Raw Layer)];
    C -->|SQL Transformation| D[(BigQuery: Structured Layer)];
    D -->|SQL Logic| E[(BigQuery: Skills Aggregation)];
    E -->|Analytics| F[Dashboard/Reporting];
