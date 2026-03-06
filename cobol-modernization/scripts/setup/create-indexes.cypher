// LegacyCobolInsights — Performance Indexes
// Run after create-neo4j-schema.cypher to add additional performance indexes

// Program property indexes
CREATE INDEX program_has_goto IF NOT EXISTS
FOR (p:Program) ON (p.has_goto);

CREATE INDEX program_has_alter IF NOT EXISTS
FOR (p:Program) ON (p.has_alter);

CREATE INDEX program_has_redefines IF NOT EXISTS
FOR (p:Program) ON (p.has_redefines);

CREATE INDEX program_line_count IF NOT EXISTS
FOR (p:Program) ON (p.line_count);

CREATE INDEX program_author IF NOT EXISTS
FOR (p:Program) ON (p.author);

// Paragraph indexes
CREATE INDEX paragraph_line_start IF NOT EXISTS
FOR (para:Paragraph) ON (para.line_start);

CREATE INDEX paragraph_decision_points IF NOT EXISTS
FOR (para:Paragraph) ON (para.decision_points);

// DataItem indexes
CREATE INDEX data_item_has_redefines IF NOT EXISTS
FOR (d:DataItem) ON (d.has_redefines);

CREATE INDEX data_item_has_occurs IF NOT EXISTS
FOR (d:DataItem) ON (d.has_occurs);

CREATE INDEX data_item_level IF NOT EXISTS
FOR (d:DataItem) ON (d.level);

// Composite index for migration queries
CREATE INDEX program_category_score IF NOT EXISTS
FOR (p:Program) ON (p.migration_category, p.migration_score);

// Verify all indexes
SHOW INDEXES YIELD name, state, type, labelsOrTypes, properties
WHERE state = 'ONLINE'
RETURN name, type, labelsOrTypes, properties
ORDER BY labelsOrTypes, properties;
