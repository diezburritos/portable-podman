-- MariaDB spatial setup
-- MariaDB has built-in spatial support (no extension needed)

CREATE TABLE IF NOT EXISTS sample_locations (
    entity_id VARCHAR(255) PRIMARY KEY,
    entity_type VARCHAR(255) NOT NULL,
    category VARCHAR(50),
    location POINT NOT NULL,
    SPATIAL INDEX(location)
) ENGINE=InnoDB;
