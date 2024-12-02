-- models/complaints_fact_table.sql
{{ config(materialized="table") }}

WITH complaints_fact_table AS (
    SELECT
        complaints.unique_key,  -- Ensuring unique keys if not already present
        ctd.complaint_type_dim_id,
        dd.date_dim_id,
        jd.junk_dim_id,
        ld.location_dim_id
    FROM `cis9440gp.RawDataset.FoodEstablishment` complaints
    LEFT JOIN `cis9440gp.dbt_cliu.complaint_type_dimension` ctd
        ON complaints.descriptor = ctd.complaint_descriptor
    LEFT JOIN `cis9440gp.dbt_qlin.date_dimension` dd
        ON DATE(complaints.created_date) = dd.date
    LEFT JOIN `cis9440gp.dbt_cliu.junk_dimension` jd
        ON CASE
            WHEN complaints.location_type IN ('Cafeteria - College/University', 'Cafeteria - Private School', 'Cafeteria - Public School') THEN 'Educational Cafeteria'
            WHEN complaints.location_type IN ('Food Cart Vendor', 'Mobile Food Vendor', 'Street Vendor', 'Street Fair Vendor') THEN 'Mobile Food Service'
            WHEN complaints.location_type IN ('Restaurant', 'Restaurant/Bar/Deli/Bakery') THEN 'Restaurant Types'
            WHEN complaints.location_type IN ('Catering Service', 'Catering Hall') THEN 'Catering Operations'
            ELSE 'Other Types'
           END = jd.food_establishment_types
           AND jd.resolution_status = complaints.status
    LEFT JOIN `cis9440gp.dbt_qlin.location_dimension` ld
        ON ld.community_board = CASE complaints.community_board
            WHEN '01 MANHATTAN' THEN '101'
            WHEN '02 MANHATTAN' THEN '102'
            WHEN '03 MANHATTAN' THEN '103'
            WHEN '04 MANHATTAN' THEN '104'
            WHEN '05 MANHATTAN' THEN '105'
            WHEN '06 MANHATTAN' THEN '106'
            WHEN '07 MANHATTAN' THEN '107'
            WHEN '08 MANHATTAN' THEN '108'
            WHEN '09 MANHATTAN' THEN '109'
            WHEN '10 MANHATTAN' THEN '110'
            WHEN '11 MANHATTAN' THEN '111'
            WHEN '12 MANHATTAN' THEN '112'
            WHEN 'Unspecified MANHATTAN' THEN '100'
            WHEN '01 BRONX' THEN '201'
            WHEN '02 BRONX' THEN '202'
            WHEN '03 BRONX' THEN '203'
            WHEN '04 BRONX' THEN '204'
            WHEN '05 BRONX' THEN '205'
            WHEN '06 BRONX' THEN '206'
            WHEN '07 BRONX' THEN '207'
            WHEN '08 BRONX' THEN '208'
            WHEN '09 BRONX' THEN '209'
            WHEN '10 BRONX' THEN '210'
            WHEN '11 BRONX' THEN '211'
            WHEN '12 BRONX' THEN '212'
            WHEN 'Unspecified BRONX' THEN '200'
            WHEN '01 BROOKLYN' THEN '301'
            WHEN '02 BROOKLYN' THEN '302'
            WHEN '03 BROOKLYN' THEN '303'
            WHEN '04 BROOKLYN' THEN '304'
            WHEN '05 BROOKLYN' THEN '305'
            WHEN '06 BROOKLYN' THEN '306'
            WHEN '07 BROOKLYN' THEN '307'
            WHEN '08 BROOKLYN' THEN '308'
            WHEN '09 BROOKLYN' THEN '309'
            WHEN '10 BROOKLYN' THEN '310'
            WHEN '11 BROOKLYN' THEN '311'
            WHEN '12 BROOKLYN' THEN '312'
            WHEN '13 BROOKLYN' THEN '313'
            WHEN '14 BROOKLYN' THEN '314'
            WHEN '15 BROOKLYN' THEN '315'
            WHEN '16 BROOKLYN' THEN '316'
            WHEN '17 BROOKLYN' THEN '317'
            WHEN '18 BROOKLYN' THEN '318'
            WHEN 'Unspecified BROOKLYN' THEN '300' 
            WHEN '01 QUEENS' THEN '401'
            WHEN '02 QUEENS' THEN '402'
            WHEN '03 QUEENS' THEN '403'
            WHEN '04 QUEENS' THEN '404'
            WHEN '05 QUEENS' THEN '405'
            WHEN '06 QUEENS' THEN '406'
            WHEN '07 QUEENS' THEN '407'
            WHEN '08 QUEENS' THEN '408'
            WHEN '09 QUEENS' THEN '409'
            WHEN '10 QUEENS' THEN '410'
            WHEN '11 QUEENS' THEN '411'
            WHEN '12 QUEENS' THEN '412'
            WHEN '13 QUEENS' THEN '413'
            WHEN '14 QUEENS' THEN '414'
            WHEN 'Unspecified QUEENS' THEN '400' 
            WHEN '01 STATEN ISLAND' THEN '501'
            WHEN '02 STATEN ISLAND' THEN '502'
            WHEN '03 STATEN ISLAND' THEN '503'
            WHEN 'Unspecified STATEN ISLAND' THEN '500'
            -- Continue for other boroughs and unspecified cases
            ELSE '999'
        END
        AND complaints.street_name = ld.street_address
        And complaints.incident_zip = ld.zipcode
        And complaints.borough = ld.city_borough -- Assuming street_name matches directly with street_address in location_dimension
)
SELECT *
FROM complaints_fact_table
