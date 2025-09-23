.databases
-- This shows all attached databases

-- Detach each database (except main which cannot be detached)
-- Note: We're not using IF EXISTS since your SQLite version may not support it
DETACH DATABASE staging_db;
DETACH DATABASE intermediate_db;
DETACH DATABASE marts_db;

-- Check if they're detached
.databases

-- Now re-attach them
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_staging.db' AS staging_db;
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_intermediate.db' AS intermediate_db;
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_marts.db' AS marts_db;

-- Verify attachments
.databases
