// LegacyCobolInsights — Constraints Reference
// These are the same constraints as SCHEMA.cypher, listed here for reference

// Node key constraints (uniqueness)
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

// To drop all constraints (reset database):
// DROP CONSTRAINT program_id_unique IF EXISTS;
// DROP CONSTRAINT copybook_name_unique IF EXISTS;
// DROP CONSTRAINT data_item_fqn_unique IF EXISTS;
// DROP CONSTRAINT paragraph_fqn_unique IF EXISTS;
// DROP CONSTRAINT file_logical_unique IF EXISTS;
// DROP CONSTRAINT jcl_job_name_unique IF EXISTS;
