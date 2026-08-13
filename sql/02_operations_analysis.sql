/*
Supply Chain Performance Analysis
File: 02_operations_analysis.sql

Purpose:
Analyze logistics performance, disruption risk, delivery delays,
operational bottlenecks, and cost patterns across the supply chain.

This script evaluates how operational conditions relate to
delivery performance and supply chain efficiency.
*/

/*
Analysis Query 1: Calculate overall supply chain performance metrics

AVG calculates the average value of key operational measures
across all 32,065 records.

These results create a baseline that later queries can use
for comparison.

The metrics include disruption likelihood, delay probability,
delivery deviation, shipping cost, lead time, supplier reliability,
and congestion levels.
*/

SELECT
    ROUND(AVG(disruption_likelihood_score), 4) AS avg_disruption_likelihood,
    ROUND(AVG(delay_probability), 4) AS avg_delay_probability,
    ROUND(AVG(delivery_time_deviation), 4) AS avg_delivery_time_deviation,
    ROUND(AVG(shipping_costs), 2) AS avg_shipping_cost,
    ROUND(AVG(lead_time_days), 2) AS avg_lead_time_days,
    ROUND(AVG(supplier_reliability_score), 4) AS avg_supplier_reliability,
    ROUND(AVG(port_congestion_level), 4) AS avg_port_congestion,
    ROUND(AVG(traffic_congestion_level), 4) AS avg_traffic_congestion
FROM supply_chain;

/*
Analysis Query 2: Compare operational performance by disruption level

CASE converts the continuous disruption likelihood score into
three operational groups:

Low Disruption:
Score below 0.30.

Moderate Disruption:
Score from 0.30 up to 0.70.

High Disruption:
Score 0.70 or greater.

AVG then compares delivery deviation, shipping cost, lead time,
supplier reliability, and congestion across the three groups.

This helps identify which operational metrics change as
disruption likelihood increases.
*/

SELECT
    CASE
        WHEN disruption_likelihood_score < 0.30
            THEN 'Low Disruption'

        WHEN disruption_likelihood_score < 0.70
            THEN 'Moderate Disruption'

        ELSE 'High Disruption'
    END AS disruption_level,

    COUNT(*) AS record_count,

    ROUND(AVG(delivery_time_deviation), 4)
        AS avg_delivery_time_deviation,

    ROUND(AVG(shipping_costs), 2)
        AS avg_shipping_cost,

    ROUND(AVG(lead_time_days), 2)
        AS avg_lead_time_days,

    ROUND(AVG(supplier_reliability_score), 4)
        AS avg_supplier_reliability,

    ROUND(AVG(port_congestion_level), 4)
        AS avg_port_congestion,

    ROUND(AVG(traffic_congestion_level), 4)
        AS avg_traffic_congestion

FROM supply_chain

GROUP BY
    CASE
        WHEN disruption_likelihood_score < 0.30
            THEN 'Low Disruption'

        WHEN disruption_likelihood_score < 0.70
            THEN 'Moderate Disruption'

        ELSE 'High Disruption'
    END

ORDER BY
    CASE disruption_level
        WHEN 'Low Disruption' THEN 1
        WHEN 'Moderate Disruption' THEN 2
        WHEN 'High Disruption' THEN 3
    END;
	
/*
Analysis Query 3: Compare operations by delivery deviation level

CASE groups delivery time deviation into four bands:

On Target:
Deviation of 2 hours or less.

Minor Deviation:
More than 2 hours and up to 5 hours.

Moderate Deviation:
More than 5 hours and up to 8 hours.

Major Deviation:
More than 8 hours.

AVG compares shipping cost, lead time, congestion,
supplier reliability, and delay probability across
the four delivery-performance groups.

This helps identify operational conditions associated
with larger delivery time deviations.
*/

SELECT
    CASE
        WHEN delivery_time_deviation <= 2
            THEN 'On Target'

        WHEN delivery_time_deviation <= 5
            THEN 'Minor Deviation'

        WHEN delivery_time_deviation <= 8
            THEN 'Moderate Deviation'

        ELSE 'Major Deviation'
    END AS delivery_deviation_level,

    COUNT(*) AS record_count,

    ROUND(
        AVG(delivery_time_deviation),
        2
    ) AS avg_delivery_time_deviation,

    ROUND(
        AVG(delay_probability),
        4
    ) AS avg_delay_probability,

    ROUND(
        AVG(shipping_costs),
        2
    ) AS avg_shipping_cost,

    ROUND(
        AVG(lead_time_days),
        2
    ) AS avg_lead_time_days,

    ROUND(
        AVG(supplier_reliability_score),
        4
    ) AS avg_supplier_reliability,

    ROUND(
        AVG(port_congestion_level),
        4
    ) AS avg_port_congestion,

    ROUND(
        AVG(traffic_congestion_level),
        4
    ) AS avg_traffic_congestion

FROM supply_chain

GROUP BY
    CASE
        WHEN delivery_time_deviation <= 2
            THEN 'On Target'

        WHEN delivery_time_deviation <= 5
            THEN 'Minor Deviation'

        WHEN delivery_time_deviation <= 8
            THEN 'Moderate Deviation'

        ELSE 'Major Deviation'
    END

ORDER BY
    CASE delivery_deviation_level
        WHEN 'On Target' THEN 1
        WHEN 'Minor Deviation' THEN 2
        WHEN 'Moderate Deviation' THEN 3
        WHEN 'Major Deviation' THEN 4
    END;
	
/*
Analysis Query 4: Examine early and late delivery deviations

CASE separates delivery performance based on the sign
of delivery_time_deviation.

Early Delivery:
Negative deviation.

Exact Target:
Deviation equals zero.

Late Delivery:
Positive deviation.

COUNT(*) shows how many records fall into each group.

AVG calculates the average delivery deviation within
each group.

MIN and MAX show the range of values.

This helps determine how delivery_time_deviation should
be interpreted before creating additional delay metrics.
*/

SELECT
    CASE
        WHEN delivery_time_deviation < 0
            THEN 'Early Delivery'

        WHEN delivery_time_deviation = 0
            THEN 'Exact Target'

        ELSE 'Late Delivery'
    END AS delivery_status,

    COUNT(*) AS record_count,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM supply_chain),
        1
    ) AS percentage_of_records,

    ROUND(
        AVG(delivery_time_deviation),
        2
    ) AS avg_delivery_time_deviation,

    ROUND(
        MIN(delivery_time_deviation),
        2
    ) AS minimum_deviation,

    ROUND(
        MAX(delivery_time_deviation),
        2
    ) AS maximum_deviation

FROM supply_chain

GROUP BY
    CASE
        WHEN delivery_time_deviation < 0
            THEN 'Early Delivery'

        WHEN delivery_time_deviation = 0
            THEN 'Exact Target'

        ELSE 'Late Delivery'
    END

ORDER BY avg_delivery_time_deviation;

/*
Analysis Query 5: Calculate yearly late-delivery performance

strftime extracts the year from the timestamp.

COUNT(*) counts all supply chain records within each year.

SUM with CASE counts records where delivery_time_deviation
is greater than zero.

The percentage calculation measures the share of records
with positive delivery deviation in each year.

AVG calculates the average delivery deviation for each year.

This helps determine whether delivery performance improved
or worsened over time.
*/

SELECT
    strftime('%Y', timestamp) AS year,

    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN delivery_time_deviation > 0
                THEN 1
            ELSE 0
        END
    ) AS late_delivery_records,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN delivery_time_deviation > 0
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS late_delivery_percentage,

    ROUND(
        AVG(delivery_time_deviation),
        2
    ) AS avg_delivery_time_deviation,

    ROUND(
        AVG(shipping_costs),
        2
    ) AS avg_shipping_cost

FROM supply_chain

GROUP BY strftime('%Y', timestamp)

ORDER BY year;

/*
Analysis Query 6: Analyze monthly delivery performance and change over time

The CTE first calculates monthly performance metrics.

strftime('%Y-%m', timestamp) groups records by year and month.

The late-delivery percentage measures the share of records
with positive delivery deviation.

AVG calculates the monthly average delivery deviation
and shipping cost.

LAG() retrieves the previous month's value.

Subtracting the previous month's value from the current month
shows month-over-month change in late-delivery percentage.

This introduces a window function without collapsing the
monthly rows.
*/

WITH monthly_performance AS (

    SELECT
        strftime('%Y-%m', timestamp) AS month,

        COUNT(*) AS total_records,

        ROUND(
            100.0 *
            SUM(
                CASE
                    WHEN delivery_time_deviation > 0
                        THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            1
        ) AS late_delivery_percentage,

        ROUND(
            AVG(delivery_time_deviation),
            2
        ) AS avg_delivery_time_deviation,

        ROUND(
            AVG(shipping_costs),
            2
        ) AS avg_shipping_cost

    FROM supply_chain

    GROUP BY strftime('%Y-%m', timestamp)
)

SELECT
    month,
    total_records,
    late_delivery_percentage,
    avg_delivery_time_deviation,
    avg_shipping_cost,

    ROUND(
        late_delivery_percentage -
        LAG(late_delivery_percentage) OVER (
            ORDER BY month
        ),
        1
    ) AS month_over_month_change

FROM monthly_performance

ORDER BY month;

/*
Analysis Query 7: Rank monthly delivery performance

The CTE calculates monthly late-delivery performance.

RANK() assigns a performance rank based on late-delivery percentage.

A lower late-delivery percentage receives a better rank.

A second RANK() identifies the worst-performing months by ranking
late-delivery percentage from highest to lowest.

This allows us to identify the strongest and weakest months
without manually scanning the entire time series.
*/

WITH monthly_performance AS (

    SELECT
        strftime('%Y-%m', timestamp) AS month,

        COUNT(*) AS total_records,

        ROUND(
            100.0 *
            SUM(
                CASE
                    WHEN delivery_time_deviation > 0
                        THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            1
        ) AS late_delivery_percentage,

        ROUND(
            AVG(delivery_time_deviation),
            2
        ) AS avg_delivery_time_deviation,

        ROUND(
            AVG(shipping_costs),
            2
        ) AS avg_shipping_cost

    FROM supply_chain

    GROUP BY strftime('%Y-%m', timestamp)
)

SELECT
    month,
    total_records,
    late_delivery_percentage,
    avg_delivery_time_deviation,
    avg_shipping_cost,

    RANK() OVER (
        ORDER BY late_delivery_percentage ASC
    ) AS best_performance_rank,

    RANK() OVER (
        ORDER BY late_delivery_percentage DESC
    ) AS worst_performance_rank

FROM monthly_performance

ORDER BY late_delivery_percentage DESC;

/*
Analysis Query 8: Compare operational conditions for early and late deliveries

CASE separates records into Early Delivery and Late Delivery
based on the sign of delivery_time_deviation.

AVG compares important operational factors across the two groups.

This helps identify which variables differ between early
and late delivery performance.
*/

SELECT
    CASE
        WHEN delivery_time_deviation < 0
            THEN 'Early Delivery'
        ELSE 'Late Delivery'
    END AS delivery_status,

    COUNT(*) AS record_count,

    ROUND(AVG(shipping_costs), 2) AS avg_shipping_cost,

    ROUND(AVG(lead_time_days), 2) AS avg_lead_time_days,

    ROUND(AVG(supplier_reliability_score), 4) AS avg_supplier_reliability,

    ROUND(AVG(port_congestion_level), 4) AS avg_port_congestion,

    ROUND(AVG(traffic_congestion_level), 4) AS avg_traffic_congestion,

    ROUND(AVG(weather_condition_severity), 4) AS avg_weather_severity,

    ROUND(AVG(customs_clearance_time), 2) AS avg_customs_clearance_time,

    ROUND(AVG(loading_unloading_time), 2) AS avg_loading_unloading_time,

    ROUND(AVG(fuel_consumption_rate), 2) AS avg_fuel_consumption_rate

FROM supply_chain

GROUP BY
    CASE
        WHEN delivery_time_deviation < 0
            THEN 'Early Delivery'
        ELSE 'Late Delivery'
    END;

	/*
Analysis Query 9: Compare late-delivery rates by port congestion level

CASE groups the continuous port congestion score into
three operational bands.

Low Congestion:
Score below 4.

Moderate Congestion:
Score from 4 up to 7.

High Congestion:
Score 7 or greater.

SUM with CASE counts late deliveries within each group.

The percentage calculation shows the late-delivery rate
for each congestion level.

AVG calculates average delivery deviation and shipping cost.

This helps determine whether extreme port congestion is
associated with poorer delivery performance.
*/

SELECT
    CASE
        WHEN port_congestion_level < 4
            THEN 'Low Congestion'

        WHEN port_congestion_level < 7
            THEN 'Moderate Congestion'

        ELSE 'High Congestion'
    END AS port_congestion_group,

    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN delivery_time_deviation > 0
                THEN 1
            ELSE 0
        END
    ) AS late_delivery_records,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN delivery_time_deviation > 0
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS late_delivery_percentage,

    ROUND(
        AVG(delivery_time_deviation),
        2
    ) AS avg_delivery_time_deviation,

    ROUND(
        AVG(shipping_costs),
        2
    ) AS avg_shipping_cost

FROM supply_chain

GROUP BY
    CASE
        WHEN port_congestion_level < 4
            THEN 'Low Congestion'

        WHEN port_congestion_level < 7
            THEN 'Moderate Congestion'

        ELSE 'High Congestion'
    END

ORDER BY
    CASE port_congestion_group
        WHEN 'Low Congestion' THEN 1
        WHEN 'Moderate Congestion' THEN 2
        WHEN 'High Congestion' THEN 3
    END;
	
/*
Analysis Query 10: Compare late-delivery performance across
combined supplier reliability and traffic congestion conditions

CASE creates two supplier reliability groups:

Lower Reliability:
Supplier reliability score below 0.50.

Higher Reliability:
Supplier reliability score 0.50 or greater.

A second CASE creates two traffic congestion groups:

Lower Traffic:
Traffic congestion score below 5.

Higher Traffic:
Traffic congestion score 5 or greater.

Grouping by both conditions allows us to test whether combinations
of operational factors reveal patterns that were hidden when each
factor was analyzed separately.

The late-delivery percentage measures delivery performance
within each combined operating condition.
*/

SELECT
    CASE
        WHEN supplier_reliability_score < 0.50
            THEN 'Lower Reliability'
        ELSE 'Higher Reliability'
    END AS supplier_group,

    CASE
        WHEN traffic_congestion_level < 5
            THEN 'Lower Traffic'
        ELSE 'Higher Traffic'
    END AS traffic_group,

    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN delivery_time_deviation > 0
                THEN 1
            ELSE 0
        END
    ) AS late_delivery_records,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN delivery_time_deviation > 0
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS late_delivery_percentage,

    ROUND(
        AVG(delivery_time_deviation),
        2
    ) AS avg_delivery_time_deviation,

    ROUND(
        AVG(shipping_costs),
        2
    ) AS avg_shipping_cost

FROM supply_chain

GROUP BY
    CASE
        WHEN supplier_reliability_score < 0.50
            THEN 'Lower Reliability'
        ELSE 'Higher Reliability'
    END,

    CASE
        WHEN traffic_congestion_level < 5
            THEN 'Lower Traffic'
        ELSE 'Higher Traffic'
    END

ORDER BY late_delivery_percentage DESC;

/*
Analysis Query 11: Examine the distribution of shipping costs

MIN identifies the lowest shipping cost.

AVG calculates the average shipping cost.

MAX identifies the highest shipping cost.

The CASE expressions count records in several cost bands.

This creates a baseline for analyzing high-cost logistics
records in later queries.
*/

SELECT
    ROUND(MIN(shipping_costs), 2) AS minimum_shipping_cost,

    ROUND(AVG(shipping_costs), 2) AS average_shipping_cost,

    ROUND(MAX(shipping_costs), 2) AS maximum_shipping_cost,

    SUM(
        CASE
            WHEN shipping_costs < 250 THEN 1
            ELSE 0
        END
    ) AS records_below_250,

    SUM(
        CASE
            WHEN shipping_costs >= 250
             AND shipping_costs < 500 THEN 1
            ELSE 0
        END
    ) AS records_250_to_499,

    SUM(
        CASE
            WHEN shipping_costs >= 500
             AND shipping_costs < 750 THEN 1
            ELSE 0
        END
    ) AS records_500_to_749,

    SUM(
        CASE
            WHEN shipping_costs >= 750 THEN 1
            ELSE 0
        END
    ) AS records_750_and_above

FROM supply_chain;

/*
Analysis Query 12: Compare operational performance by shipping cost band

CASE groups shipping costs into four cost levels:

Low Cost:
Below $250.

Moderate Cost:
$250 to less than $500.

High Cost:
$500 to less than $750.

Very High Cost:
$750 or more.

The query compares late-delivery percentage, delivery deviation,
lead time, fuel consumption, and disruption likelihood across
the four cost groups.

This helps determine whether higher logistics spending is
associated with better or worse operational performance.
*/

SELECT
    CASE
        WHEN shipping_costs < 250
            THEN 'Low Cost'

        WHEN shipping_costs < 500
            THEN 'Moderate Cost'

        WHEN shipping_costs < 750
            THEN 'High Cost'

        ELSE 'Very High Cost'
    END AS shipping_cost_group,

    COUNT(*) AS total_records,

    ROUND(
        AVG(shipping_costs),
        2
    ) AS avg_shipping_cost,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN delivery_time_deviation > 0
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS late_delivery_percentage,

    ROUND(
        AVG(delivery_time_deviation),
        2
    ) AS avg_delivery_time_deviation,

    ROUND(
        AVG(lead_time_days),
        2
    ) AS avg_lead_time_days,

    ROUND(
        AVG(fuel_consumption_rate),
        2
    ) AS avg_fuel_consumption,

    ROUND(
        AVG(disruption_likelihood_score),
        4
    ) AS avg_disruption_likelihood

FROM supply_chain

GROUP BY
    CASE
        WHEN shipping_costs < 250
            THEN 'Low Cost'

        WHEN shipping_costs < 500
            THEN 'Moderate Cost'

        WHEN shipping_costs < 750
            THEN 'High Cost'

        ELSE 'Very High Cost'
    END

ORDER BY avg_shipping_cost;

/*
Analysis Query 13: Create an overall supply chain performance scorecard

This query summarizes the most important operational KPIs
identified during the analysis.

COUNT(*) shows total records analyzed.

The late-delivery percentage measures the share of records
with positive delivery time deviation.

AVG summarizes delivery deviation, shipping cost, lead time,
disruption likelihood, and supplier reliability.

SUM with CASE also counts very-high-cost records where
shipping costs are $750 or greater.

This creates a management-level summary of supply chain
performance in a single query.
*/

SELECT
    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN delivery_time_deviation > 0
                THEN 1
            ELSE 0
        END
    ) AS late_delivery_records,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN delivery_time_deviation > 0
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS late_delivery_percentage,

    ROUND(
        AVG(delivery_time_deviation),
        2
    ) AS avg_delivery_time_deviation,

    ROUND(
        AVG(shipping_costs),
        2
    ) AS avg_shipping_cost,

    SUM(
        CASE
            WHEN shipping_costs >= 750
                THEN 1
            ELSE 0
        END
    ) AS very_high_cost_records,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN shipping_costs >= 750
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS very_high_cost_percentage,

    ROUND(
        AVG(lead_time_days),
        2
    ) AS avg_lead_time_days,

    ROUND(
        AVG(disruption_likelihood_score),
        4
    ) AS avg_disruption_likelihood,

    ROUND(
        AVG(supplier_reliability_score),
        4
    ) AS avg_supplier_reliability

FROM supply_chain;