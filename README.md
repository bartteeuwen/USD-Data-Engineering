# USD Data Engineering – Labor Market ELT Pipeline

![Build Status](https://github.com/bartteeuwen/USD-Data-Engineering/actions/workflows/daily_pipeline.yml/badge.svg)

## Overview

This project is an automated ELT pipeline that monitors the U.S. technical job market using:

- Adzuna API for job postings  
- Google BigQuery for storage and transformations  
- O*NET Technology Skills data for skill enrichment  
- GitHub Actions for scheduling and automation  

The pipeline runs every 4 hours (or manually) and helps analyze:

- Most requested technical skills  
- Trending skills over time  
- Hot technologies from O*NET  
- Labor market demand signals  

## Architecture

```text
Adzuna API
   ↓
Python ingestion
   ↓
BigQuery raw tables
   ↓
SQL transformations
   ↓
O*NET enrichment
   ↓
Aggregated tables
   ↓
Looker Studio dashboard
```

## Core Tables

### Raw
`labor_market.raw_job_postings`

Raw job postings from Adzuna.

### Structured
`labor_market.jobs_structured`

Standardized job records with:

- Salary fields  
- Work model (remote / hybrid / onsite)  
- Contract type  
- Fortune 500 matching  

### Skills
`labor_market.skills_in_demand`

Matches job descriptions to O*NET skills and adds:

- `hot_technology`
- `in_demand` (currently nullable)

### Aggregated
`labor_market.skill_counts`

Used by the dashboard for:

- Skill mention counts  
- 7-day trend counts  
- O*NET indicators  

## O*NET Reference Data

The pipeline uses:

- `O_Net_Technology_Skills`
- `O_Net_Technology_Skills_normalized`

The normalized view standardizes source field names and protects downstream SQL from source schema changes.

## Reliability Notes

The pipeline includes:

- BigQuery location set to `US`
- SQL assertions for validation
- Deduplication during ingestion
- Schema normalization for reference data
- GitHub Actions scheduling

## Repository Structure

```text
.github/workflows/
ingestion/
transformation/
data/
requirements.txt
README.md
```

## Required Secrets

Configure these in:

**Settings → Secrets and Variables → Actions**

- GCP_SA_KEY  
- ADZUNA_APP_ID  
- ADZUNA_APP_KEY  

## Dashboard Use Case

This project supports labor market analysis such as:

- Tracking high-demand skills  
- Monitoring emerging technologies  
- Improving job description targeting  
- Exploring hiring demand trends  

## Tech Stack

- Python  
- BigQuery  
- SQL  
- GitHub Actions  
- Looker Studio  
- O*NET  
