# USD Data Engineering – Labor Market ELT Pipeline

![Build Status](https://github.com/bartteeuwen/USD-Data-Engineering/actions/workflows/daily_pipeline.yml/badge.svg)
![Python](https://img.shields.io/badge/python-3.9-blue)
![BigQuery](https://img.shields.io/badge/Google_Cloud-BigQuery-green)
![Architecture](https://img.shields.io/badge/Architecture-ELT-orange)

---

## Overview

This project implements a production-style **ELT pipeline** that monitors the U.S. technical job market using:

- **Adzuna API** (job postings)
- **Google BigQuery** (data warehouse)
- **O*NET Technology Skills Taxonomy** (government skill reference)
- **GitHub Actions** (automation + scheduling)
- **SQL transformations** (primary business logic)

The pipeline runs automatically every 4 hours and can also be triggered manually.

It enables analysis of:
- Most frequently requested skills
- Trending skills (7-day window)
- Government-defined *Hot Technology* and *In Demand* flags
- Market demand over time

---

## Architecture

This pipeline follows a clean **ELT Medallion Architecture**:

```
Adzuna API
    ↓
Python Ingestion
    ↓
BigQuery (Raw Layer)
    ↓
SQL Transformations
    ↓
Skill Enrichment (O*NET)
    ↓
Aggregation Layer
    ↓
Analytics / Dashboard
```

---

## Data Layers

### Raw Layer (Bronze)
`labor_market.raw_job_postings`

Stores original job data from Adzuna (deduplicated).

---

### Structured Layer (Silver)
`labor_market.jobs_structured`

Cleans and standardizes:
- Salaries
- Contract type
- Work model (Remote / Hybrid / Onsite)
- Timestamps

---

### Skill Matching Layer
`labor_market.skills_in_demand`

Matches job descriptions against O*NET skills and flags:
- `hot_technology`
- `in_demand`

---

### Aggregation Layer (Gold)
`labor_market.skill_counts`

Provides:
- Total skill mentions
- Mentions in last 7 days
- O*NET enrichment indicators

---

## Repository Structure

```
.github/workflows/      # GitHub Actions orchestration
ingestion/              # Python ingestion scripts
transformation/         # SQL ELT logic
data/                   # O*NET skill files
requirements.txt
README.md
```

---

## Deployment

This pipeline runs via **GitHub Actions**.

### Required Repository Secrets

Go to:  
**Settings → Secrets and Variables → Actions**

Add:

| Secret | Description |
|--------|-------------|
| GCP_SA_KEY | Google Cloud Service Account JSON |
| ADZUNA_APP_ID | Adzuna API ID |
| ADZUNA_APP_KEY | Adzuna API Key |

---

## Monitoring

Navigate to:

**GitHub → Actions → USD Data Engineering Pipeline**

| Status | Meaning |
|--------|---------|
| ✅ Green | Successful run |
| ❌ Red | Failed run |
| 🟡 Yellow | Running |

Manual runs are supported via the **Run Workflow** button.

---

## Business Use Case

This pipeline supports a hiring manager who lacks access to proprietary labor analytics tools.

It enables:

- Identifying high-demand technical skills
- Comparing skill demand across job categories
- Tracking emerging technologies
- Improving job description targeting

---

## Tech Stack

- Python 3.9
- Google BigQuery
- SQL (StandardSQL)
- GitHub Actions
- O*NET 29.0 Dataset
- Adzuna API
