{{ config(materialized='table') }}

SELECT
    distinct(location_type),
    CASE
        WHEN location_type IN ('Cafeteria - College/University', 'Cafeteria - Private School', 'Cafeteria - Public School') THEN 'Educational Cafeteria'
        WHEN location_type IN ('Food Cart Vendor', 'Mobile Food Vendor', 'Street Vendor', 'Street Fair Vendor') THEN 'Mobile Food Service'
        WHEN location_type IN ('Restaurant', 'Restaurant/Bar/Deli/Bakery') THEN 'Restaurant Types'
        WHEN location_type IN ('Catering Service', 'Catering Hall') THEN 'Catering Operations'
        ELSE 'Other Types'
    END AS detailed_category
    
FROM cis9440gp.RawDataset.FoodEstablishment