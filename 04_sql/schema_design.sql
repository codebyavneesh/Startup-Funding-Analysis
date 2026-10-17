-- ===================
-- Database Creation
-- ===================
CREATE DATABASE IF NOT EXISTS startup_funding;
USE startup_funding;

-- ================
-- Table Creation
-- ================
CREATE TABLE IF NOT EXISTS startup_funding (
    Sr_No INT,
    Date DATE,
    Startup_Name VARCHAR(255),
    Industry_Vertical VARCHAR(255),
    SubVertical VARCHAR(255),
    City_Location VARCHAR(255),
    Investors_Name VARCHAR(255),
    Investment_Type VARCHAR(255),
    Amount DECIMAL(15,2)
);
