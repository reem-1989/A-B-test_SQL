-- =====================================================================
-- Landing Page A/B Test — database setup
-- A fictional meal-kit company, "FreshBox"
-- Works with MySQL 5.7, MySQL 8.x and MariaDB
-- =====================================================================

DROP DATABASE IF EXISTS ab_test;
CREATE DATABASE ab_test CHARACTER SET utf8mb4;
USE ab_test;

-- One row per visitor who saw the sign-up page during the test
CREATE TABLE ab_test_visitors (
    visitor_id  INT PRIMARY KEY,
    test_group  CHAR(1)     NOT NULL,   -- 'A' = current page, 'B' = new page
    device      VARCHAR(10) NOT NULL,   -- Mobile, Desktop
    visit_date  DATE        NOT NULL,
    signed_up   TINYINT(1)  NOT NULL    -- 1 = started a free trial
);
