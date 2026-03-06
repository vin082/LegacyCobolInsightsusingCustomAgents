// LegacyCobolInsights — Schema Initialisation
// Run once before first ingestion

// Uniqueness constraints (also create indexes automatically)
CREATE CONSTRAINT program_id_unique IF NOT EXISTS
FOR (p:Program) REQUIRE p.program_id IS UNIQUE;

CREATE CONSTRAINT copybook_name_unique IF NOT EXISTS
FOR (c:Copybook) REQUIRE c.name IS UNIQUE;

CREATE CONSTRAINT data_item_fqn_unique IF NOT EXISTS
FOR (d:DataItem) REQUIRE d.fqn IS UNIQUE;

CREATE CONSTRAINT paragraph_fqn_unique IF NOT EXISTS
FOR (para:Paragraph) REQUIRE para.fqn IS UNIQUE;

CREATE CONSTRAINT file_logical_unique IF NOT EXISTS
FOR (f:CobolFile) REQUIRE f.logical_name IS UNIQUE;

CREATE CONSTRAINT jcl_job_name_unique IF NOT EXISTS
FOR (j:JCLJob) REQUIRE j.job_name IS UNIQUE;

// Additional indexes for common query patterns
CREATE INDEX program_complexity IF NOT EXISTS
FOR (p:Program) ON (p.estimated_complexity);

CREATE INDEX program_migration_category IF NOT EXISTS
FOR (p:Program) ON (p.migration_category);

CREATE INDEX program_migration_score IF NOT EXISTS
FOR (p:Program) ON (p.migration_score);

CREATE INDEX paragraph_name IF NOT EXISTS
FOR (para:Paragraph) ON (para.name);
