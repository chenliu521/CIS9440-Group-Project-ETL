-- models/complaint_type_dimension.sql

{{ config(materialized='table') }}

WITH complaint_type_dim AS (
  SELECT
    descriptor AS complaint_descriptor,
    CASE
        WHEN descriptor IN ('Rodents/Insects/Garbage', 'Food Contaminated', 'Food Worker Illness', 'Milk Not Pasteurized') THEN 'Very Serious'
        WHEN descriptor IN ('Food Spoiled', 'Bare Hands in Contact w/ Food', 'Food Temperature', 'Toxic Chemical/Material', 'Food Contains Foreign Object') THEN 'Serious'
        WHEN descriptor IN ('Ventilation', 'Facility Construction', 'Food Protection', 'Kitchen/Food Prep Area', 'Toilet Facility', 'Handwashing', 'Food Worker Hygiene', 'Food Preparation Location', 'Dishwashing/Utensils', 'Plumbing') THEN 'Moderate'
        WHEN descriptor IN ('Pet/Animal', 'Permit/License/Certificate', 'No Permit or License', 'Odor', 'Lighting', 'Allergy Information', 'Water', 'Sign', 'Sodium Warning', 'Food Worker Illness') THEN 'Less Serious'
        ELSE 'Minimal'
    END AS severity_level,
    CASE
        WHEN descriptor IN ('Rodents/Insects/Garbage', 'Food Contaminated', 'Food Worker Illness', 'Milk Not Pasteurized', 'Food Spoiled', 'Bare Hands in Contact w/ Food', 'Food Temperature', 'Toxic Chemical/Material', 'Food Contains Foreign Object', 'Food Worker Hygiene', 'Handwashing') THEN 1  -- Directly Health-Related
        WHEN descriptor IN ('Ventilation', 'Facility Construction', 'Food Protection', 'Kitchen/Food Prep Area', 'Toilet Facility', 'Food Preparation Location', 'Dishwashing/Utensils', 'Plumbing', 'Pet/Animal', 'Permit/License/Certificate', 'No Permit or License', 'Odor', 'Lighting', 'Allergy Information', 'Water', 'Sign', 'Sodium Warning') THEN 0  -- Not Directly Health-Related
        ELSE 0  -- Unclassified
    END AS health_classification
  FROM `cis9440gp.RawDataset.FoodEstablishment`
  GROUP BY descriptor
)

SELECT
  ROW_NUMBER() OVER() AS complaint_type_dim_id,
  complaint_descriptor,
  health_classification,
  severity_level -- Assuming you want to select this too
FROM complaint_type_dim
