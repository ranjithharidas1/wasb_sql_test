-- =============================================================================
-- Task 1: Create the EMPLOYEE table
-- =============================================================================
-- Loads employee data from hr/employee_index.csv into the SExI database.
-- employee_id and manager_id are typed as TINYINT per the specification.
-- All other columns retain their natural VARCHAR type.
--
-- DROP TABLE IF EXISTS ensures this script is idempotent and can be re-run
-- without needing to restart the Trino container.
-- =============================================================================

USE memory.default;

DROP TABLE IF EXISTS EMPLOYEE;

CREATE TABLE EMPLOYEE (
    employee_id TINYINT,
    first_name  VARCHAR,
    last_name   VARCHAR,
    job_title   VARCHAR,
    manager_id  TINYINT
);

INSERT INTO EMPLOYEE VALUES
    (CAST(1 AS TINYINT), 'Ian',      'James',     'CEO',           CAST(4 AS TINYINT)),
    (CAST(2 AS TINYINT), 'Umberto',  'Torrielli', 'CSO',           CAST(1 AS TINYINT)),
    (CAST(3 AS TINYINT), 'Alex',     'Jacobson',  'MD EMEA',       CAST(2 AS TINYINT)),
    (CAST(4 AS TINYINT), 'Darren',   'Poynton',   'CFO',           CAST(2 AS TINYINT)),
    (CAST(5 AS TINYINT), 'Tim',      'Beard',     'MD APAC',       CAST(2 AS TINYINT)),
    (CAST(6 AS TINYINT), 'Gemma',    'Dodd',      'COS',           CAST(1 AS TINYINT)),
    (CAST(7 AS TINYINT), 'Lisa',     'Platten',   'CHR',           CAST(6 AS TINYINT)),
    (CAST(8 AS TINYINT), 'Stefano',  'Camisaca',  'GM Activation', CAST(2 AS TINYINT)),
    (CAST(9 AS TINYINT), 'Andrea',   'Ghibaudi',  'MD NAM',        CAST(2 AS TINYINT));
