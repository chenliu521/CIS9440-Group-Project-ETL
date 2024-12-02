-- models/junk_dimension.sql

{{ config(materialized='table') }}

WITH location AS(
    SELECT DISTINCT(location_type) AS food_establishment_type,
    FROM `cis9440gp.RawDataset.FoodEstablishment`
),
location_change AS(
    SELECT food_establishment_type,
    CASE
        WHEN food_establishment_type IN ('Cafeteria - College/University', 'Cafeteria - Private School', 'Cafeteria - Public School') THEN 'Educational Cafeteria'
        WHEN food_establishment_type IN ('Food Cart Vendor', 'Mobile Food Vendor', 'Street Vendor', 'Street Fair Vendor') THEN 'Mobile Food Service'
        WHEN food_establishment_type IN ('Restaurant', 'Restaurant/Bar/Deli/Bakery') THEN 'Restaurant Types'
        WHEN food_establishment_type IN ('Catering Service', 'Catering Hall') THEN 'Catering Operations'
        ELSE 'Other Types'
    END AS food_establishment_types
    FROM location
),
status_check AS(
SELECT DISTINCT(status)AS resolution_status
FROM `cis9440gp.RawDataset.FoodEstablishment`
),
crossjoin AS(
SELECT DISTINCT(food_establishment_types), resolution_status
FROM location_change
CROSS JOIN status_check
)
SELECT ROW_NUMBER() OVER() AS junk_dim_id,
        *
FROM crossjoin