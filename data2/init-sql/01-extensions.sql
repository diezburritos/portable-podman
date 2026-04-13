-- Enable PostGIS (always available in postgis/postgis image)
CREATE EXTENSION IF NOT EXISTS postgis;

-- H3 is optional — only available in the postgres-h3 variant
-- https://github.com/postgis/h3-pg
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS h3;
    CREATE EXTENSION IF NOT EXISTS h3_postgis CASCADE;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'H3 extensions not available — skipping (use make up-postgres-h3 for H3 support)';
END
$$;
