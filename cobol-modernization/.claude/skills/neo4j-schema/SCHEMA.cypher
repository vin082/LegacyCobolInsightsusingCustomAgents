// LegacyCobolInsights — Full Schema Creation Script
// Run once before first ingestion to set up all constraints and indexes

// ============================================================
// UNIQUENESS CONSTRAINTS
// (Automatically create backing indexes)
// ============================================================

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

// ============================================================
// PERFORMANCE INDEXES
// ============================================================

// Program lookups by analysis properties
CREATE INDEX program_complexity IF NOT EXISTS
FOR (p:Program) ON (p.estimated_complexity);

CREATE INDEX program_migration_category IF NOT EXISTS
FOR (p:Program) ON (p.migration_category);

CREATE INDEX program_migration_score IF NOT EXISTS
FOR (p:Program) ON (p.migration_score);

CREATE INDEX program_has_goto IF NOT EXISTS
FOR (p:Program) ON (p.has_goto);

CREATE INDEX program_has_alter IF NOT EXISTS
FOR (p:Program) ON (p.has_alter);

// Paragraph lookups
CREATE INDEX paragraph_name IF NOT EXISTS
FOR (para:Paragraph) ON (para.name);

// DataItem lookups
CREATE INDEX data_item_name IF NOT EXISTS
FOR (d:DataItem) ON (d.name);

// ============================================================
// VERIFY
// ============================================================
// After running, verify with:
// SHOW CONSTRAINTS
// SHOW INDEXES
