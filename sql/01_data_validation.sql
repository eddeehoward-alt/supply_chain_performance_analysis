/* 
Query 1: Count the total number of supply chain records

This query counts every row in the logistics dataset.

The result should equal 32,065 records if the CSV was imported successfully without missing or duplicated ROWS

*/
SELECT
	COUNT(*) AS total_records
FROM supply_chain;

/*
Query 2: Check for missing values in important supply chain fields

Count(*) counts all records in table.

Count(column_name) counts only records where that column contains a vailue.

Subtracting the two tells us how many NULL values exist in each important field.

This helps identify missing data before we begin analysis.

*/

SELECT
	COUNT(*) - COUNT(timestamp) AS missing_timestamp,
	COUNT(*) - COUNT(shipping_costs) AS missing_shipping_costs,
	COUNT(*) - COUNT(supplier_reliability_score) AS missing_supplier_reliability,
	COUNT(*) - COUNT(lead_time_days) AS missing_lead_time,
	COUNT(*) - COUNT(delay_probability) AS missing_delay_probability,
	COUNT(*) - COUNT(risk_classification) AS missing_risk_classification,
	COUNT(*) - COUNT(delivery_time_deviation) AS missing_delivery_time_deviation
FROM supply_chain;

/*
Query 3: Review risk classification categories

GROUP BY creates on group for each risk classification.

COUNT(*) shows how many records belong to each category.

ORDER BY places the largest category first.

This helps us understand how shipment risk is distributed before we begin deeper anlysis.

*/
SELECT
	risk_classification,
	COUNT(*) AS record_count
FROM supply_chain
GROUP BY risk_classification
ORDER BY record_count DESC;

/*
Query 4: Review order fulfillment status categories

GROUP BY creates one group for each fulfillment status.

COUNT(*) shows how many records belong to each status.

ORDER BY places the most common fulfillment status first.

This helps us understand how orders are distributed across different fulfillment outcomes.

*/
SELECT
	order_fulfillment_status,
	COUNT(*) AS record_count
FROM supply_chain
GROUP BY order_fulfillment_status
ORDER BY record_count DESC;

/*
Query 4.2: Summarize order fulfillment status values 

MIN shows the lowest fulfillment status value.

MAX shows the highest fulfillment status value.

AVG calculates the average fulfillment status value.

This is more appropriate than grouping because order_fulfillment_status is a continuous numeric field.

*/
SELECT
	ROUND(MIN(order_fulfillment_status), 4) AS minimum_fulfillment_status,
	ROUND(AVG(order_fulfillment_status), 4) AS average_fulfillment_status,
	ROUND(MAX(order_fulfillment_status), 4) AS maximum_fulfillment_status
FROM supply_chain;

/*
Query 5: Review route risk level categories

GROUP BY creates one group for each route risk level.

COUNT(*) counts how many supply chain records belong
to each category.

The percentage calculation shows the share of the total
dataset represented by each route risk level.

ORDER BY places the most common category first.
*/

SELECT
    route_risk_level,
    COUNT(*) AS record_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM supply_chain),
        1
    ) AS percentage_of_records
FROM supply_chain
GROUP BY route_risk_level
ORDER BY record_count DESC;

/*
Query 5: Summarize route risk level

MIN shows the lowest route risk value.

AVG calculates the average route risk value.

MAX shows the highest route risk value.

This helps us understand the numeric range of route risk
before we use it in later performance analysis.
*/
SELECT
    ROUND(MIN(route_risk_level), 4) AS minimum_route_risk,
    ROUND(AVG(route_risk_level), 4) AS average_route_risk,
    ROUND(MAX(route_risk_level), 4) AS maximum_route_risk
FROM supply_chain;

/*
Query 6: Compare route risk levels by risk classification

GROUP BY creates one group for each risk classification.

AVG calculates the average route risk level within each group.

MIN and MAX show the range of route risk values found
within each risk classification.

This helps determine whether higher route risk scores are
associated with higher overall risk classifications.
*/

SELECT
    risk_classification,
    COUNT(*) AS record_count,
    ROUND(AVG(route_risk_level), 4) AS average_route_risk,
    ROUND(MIN(route_risk_level), 4) AS minimum_route_risk,
    ROUND(MAX(route_risk_level), 4) AS maximum_route_risk
FROM supply_chain
GROUP BY risk_classification
ORDER BY average_route_risk DESC;

/*
Query 7: Compare delay probability by risk classification

GROUP BY creates one group for each overall risk classification.

AVG calculates the average delay probability within each group.

MIN and MAX show the range of delay probabilities.

This helps determine whether records classified as High Risk
also tend to have higher estimated delay probabilities.
*/

SELECT
    risk_classification,
    COUNT(*) AS record_count,
    ROUND(AVG(delay_probability), 4) AS average_delay_probability,
    ROUND(MIN(delay_probability), 4) AS minimum_delay_probability,
    ROUND(MAX(delay_probability), 4) AS maximum_delay_probability
FROM supply_chain
GROUP BY risk_classification
ORDER BY average_delay_probability DESC;

/*
Query 8: Compare operational metrics by risk classification

GROUP BY creates one group for each risk classification.

AVG calculates the average value of several operational
metrics within each risk group.

This helps identify which variables show meaningful differences
between High Risk, Moderate Risk, and Low Risk records.

Comparing several metrics at once is more efficient than
testing each variable individually.
*/

SELECT
    risk_classification,
    COUNT(*) AS record_count,

    ROUND(AVG(delay_probability), 4) AS avg_delay_probability,

    ROUND(AVG(disruption_likelihood_score), 4) AS avg_disruption_likelihood,

    ROUND(AVG(supplier_reliability_score), 4) AS avg_supplier_reliability,

    ROUND(AVG(port_congestion_level), 4) AS avg_port_congestion,

    ROUND(AVG(traffic_congestion_level), 4) AS avg_traffic_congestion,

    ROUND(AVG(weather_condition_severity), 4) AS avg_weather_severity,

    ROUND(AVG(driver_behavior_score), 4) AS avg_driver_behavior,

    ROUND(AVG(fatigue_monitoring_score), 4) AS avg_fatigue_score,

    ROUND(AVG(delivery_time_deviation), 4) AS avg_delivery_time_deviation

FROM supply_chain

GROUP BY risk_classification

ORDER BY risk_classification;

/*
Query 9: Examine disruption likelihood by risk classification

This query calculates the minimum, average, and maximum
disruption likelihood score for each risk classification.

The goal is to determine whether the High, Moderate, and Low
Risk categories correspond to specific disruption-score ranges.

If the ranges separate cleanly, risk_classification may be
derived directly from disruption_likelihood_score.
*/

SELECT
    risk_classification,
    COUNT(*) AS record_count,

    ROUND(
        MIN(disruption_likelihood_score),
        4
    ) AS minimum_disruption_score,

    ROUND(
        AVG(disruption_likelihood_score),
        4
    ) AS average_disruption_score,

    ROUND(
        MAX(disruption_likelihood_score),
        4
    ) AS maximum_disruption_score

FROM supply_chain

GROUP BY risk_classification

ORDER BY minimum_disruption_score;

/*
Query 10: Check the date range of the supply chain dataset

MIN identifies the earliest timestamp in the dataset.

MAX identifies the latest timestamp.

COUNT(DISTINCT DATE(timestamp)) counts the number of unique
calendar dates represented.

This tells us the time period covered by the data and whether
time-based trend analysis will be useful later in the project.
*/

SELECT
    MIN(timestamp) AS earliest_timestamp,
    MAX(timestamp) AS latest_timestamp,
    COUNT(DISTINCT DATE(timestamp)) AS unique_dates
FROM supply_chain;