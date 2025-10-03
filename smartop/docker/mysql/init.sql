-- Initial database setup for SmartOP
CREATE DATABASE IF NOT EXISTS smartop;
CREATE DATABASE IF NOT EXISTS smartop_test;

-- Create user for the application
CREATE USER IF NOT EXISTS 'smartop'@'%' IDENTIFIED BY 'smartop_password';
GRANT ALL PRIVILEGES ON smartop.* TO 'smartop'@'%';
GRANT ALL PRIVILEGES ON smartop_test.* TO 'smartop'@'%';

-- Performance optimizations
SET GLOBAL innodb_buffer_pool_size = 268435456; -- 256MB
SET GLOBAL max_connections = 200;
SET GLOBAL query_cache_size = 67108864; -- 64MB
SET GLOBAL query_cache_type = 1;

-- Enable binary logging for replication
SET GLOBAL log_bin = 1;
SET GLOBAL binlog_format = 'ROW';

-- Set timezone
SET GLOBAL time_zone = '+03:00';

FLUSH PRIVILEGES;