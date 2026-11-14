-- =====================================================================
-- Landing Page A/B Test — analysis
--
-- Question: does the new sign-up page (B) get more free-trial sign-ups
--           than the current page (A)?
--
-- Metric:   sign-up rate = visitors who signed up / all visitors
--
-- Decision rule (set BEFORE looking at the results):
--   Switch to page B if its sign-up rate is higher and the difference
--   is statistically significant at the 95% level (|z| > 1.96).
-- =====================================================================
USE ab_test;

-- Q1. A first look: how many visitors, and over what dates?
SELECT
    COUNT(*)        AS visitors,
    MIN(visit_date) AS first_day,
    MAX(visit_date) AS last_day
FROM ab_test_visitors;

-- Q2. Is the split fair? With 10,000 visitors, each group should get very close
-- to 50% (within about 1 point). A bigger gap would mean something went wrong
-- with the random assignment, and the results could not be trusted.
SELECT
    test_group,
    COUNT(*)                                                           AS visitors,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM ab_test_visitors), 1) AS pct_of_visitors
FROM ab_test_visitors
GROUP BY test_group
ORDER BY test_group;

-- Q3. Results: sign-up rate for each group.
SELECT
    test_group,
    COUNT(*)                        AS visitors,
    SUM(signed_up)                  AS sign_ups,
    ROUND(100 * AVG(signed_up), 2)  AS signup_rate_pct
FROM ab_test_visitors
GROUP BY test_group
ORDER BY test_group;

-- Q4. Is the difference real, or just luck? (two-proportion z-test)
--   lift      = B's rate minus A's rate, in percentage points
--   z_score   = the lift divided by its standard error
--   95% CI    = the range the true lift most likely falls in
--   |z| > 1.96 means the result is significant at the 95% level (p < 0.05)
SELECT
    ROUND(100 * rate_a, 2)                          AS rate_a_pct,
    ROUND(100 * rate_b, 2)                          AS rate_b_pct,
    ROUND(100 * (rate_b - rate_a), 2)               AS lift_pts,
    ROUND(100 * (rate_b - rate_a) / rate_a, 1)      AS relative_lift_pct,
    ROUND(z_score, 2)                               AS z_score,
    ROUND(100 * (rate_b - rate_a - 1.96 * se), 2)   AS ci_low_pts,
    ROUND(100 * (rate_b - rate_a + 1.96 * se), 2)   AS ci_high_pts,
    CASE
        WHEN z_score > 1.96  THEN 'B wins: switch to the new page'
        WHEN z_score < -1.96 THEN 'A wins: keep the current page'
        ELSE 'No clear winner'
    END AS decision
FROM (
    SELECT
        rate_a,
        rate_b,
        -- pooled standard error, used for the z-test
        (rate_b - rate_a) / SQRT(rate_all * (1 - rate_all) * (1 / n_a + 1 / n_b)) AS z_score,
        -- unpooled standard error, used for the confidence interval
        SQRT(rate_a * (1 - rate_a) / n_a + rate_b * (1 - rate_b) / n_b)          AS se
    FROM (
        SELECT
            SUM(test_group = 'A')                                         AS n_a,
            SUM(test_group = 'B')                                         AS n_b,
            SUM(CASE WHEN test_group = 'A' THEN signed_up END) / SUM(test_group = 'A') AS rate_a,
            SUM(CASE WHEN test_group = 'B' THEN signed_up END) / SUM(test_group = 'B') AS rate_b,
            AVG(signed_up)                                                AS rate_all
        FROM ab_test_visitors
    ) AS counts
) AS test;

-- Q5. Does the new page work on both mobile and desktop?
SELECT
    device,
    ROUND(100 * AVG(CASE WHEN test_group = 'A' THEN signed_up END), 2) AS rate_a_pct,
    ROUND(100 * AVG(CASE WHEN test_group = 'B' THEN signed_up END), 2) AS rate_b_pct,
    ROUND(100 * (AVG(CASE WHEN test_group = 'B' THEN signed_up END)
               - AVG(CASE WHEN test_group = 'A' THEN signed_up END)), 2) AS lift_pts
FROM ab_test_visitors
GROUP BY device
ORDER BY device;

-- Q6. Was the result steady over time? Sign-up rate by group, per day.
-- A winner that only appears on one or two days would be a warning sign.
SELECT
    visit_date,
    ROUND(100 * AVG(CASE WHEN test_group = 'A' THEN signed_up END), 1) AS rate_a_pct,
    ROUND(100 * AVG(CASE WHEN test_group = 'B' THEN signed_up END), 1) AS rate_b_pct
FROM ab_test_visitors
GROUP BY visit_date
ORDER BY visit_date;
