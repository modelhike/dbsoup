# DBSoup: Database-as-Code for the AI-First Era

## 1. What is DBSoup?

**DBSoup** is a database-as-code format that represents your database schema as plaintext files. It's designed to be:

- **Human-Readable:** Clean, consistent syntax that's easy to read and understand
- **Git-Friendly:** Plaintext format perfect for version control and diffing
- **Review-Friendly:** Changes are clear and easy to review in pull requests
- **Machine-Parsable:** Structured format that tools can validate and transform
- **AI-Ready:** Structured format that LLMs and developer tools can parse, validate, and transform

From SQL to NoSQL, DBSoup captures modern database complexity in a single source of truth—one that's easy to understand for both developers and AI systems.

Unlike SQL dumps or ORM files, DBSoup puts readability and reviewability first. Compare these approaches:

```sql
-- Traditional SQL
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

```dbsoup
# DBSoup - Clear, concise, and review-friendly
User
==========
* id         : UUID                         [PK,AUTO:uuid()]
* email      : String(255)                  [UK]
- created_at : DateTime                     [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
```

### Modern Database Development

DBSoup brings modern software development practices to database schema management:

- **Version Control:** Store your database schema in Git alongside application code
- **Code Review:** Review schema changes through pull requests like any other code change
- **CI/CD Integration:** Validate schema changes in your CI pipeline using DBSoup's formal grammar
- **Infrastructure as Code:** Use DBSoup files as source of truth for automated database provisioning
- **Schema Migration:** Generate migration scripts by diffing DBSoup versions
- **Documentation:** Auto-generate API docs and ERD diagrams from DBSoup files
- **Testing:** Use DBSoup files to set up test databases with correct schema

Here's how a schema change looks in practice:

```dbsoup
# Example: Version-controlled schema change
User
==========
* id           : UUID                       [PK]
* @ username   : String(50)                 [UK,IX]
# password_hash : String(255)               [ENCRYPTED]
- profile_data : JSON                       
- created_at   : DateTime                   [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
+ last_login   : DateTime                   [AUDIT]  # New field added in PR #123
```

### Purpose and Goals

DBSoup was designed to capture the complexity of modern databases—from SQL to NoSQL—in a consistent plain-text format. It creates a "single source of truth" that works equally well for:

- **Developers:** Review and understand schema changes in pull requests
- **DevOps:** Automate database provisioning and migrations
- **AI Systems:** Analyze and modify schemas programmatically
- **Documentation:** Generate ERD diagrams and API documentation
- **Architects:** Design and evolve data models
- **Teams:** Collaborate on schema changes with clear version control

### Quick Example

At a glance, a simple `users` table might look like this in DBSoup:

```dbsoup
User
==========
* _id          : UUID                       [PK]
* @ username   : String(50)                 [UK,IX]
# password_hash : String(255)               [ENCRYPTED]
- profile_data : JSON                       
- created_at   : DateTime                   [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
```

This simple notation tells us:
- The `User` entity has 5 fields.
- `_id` is the primary key (`*`, `[PK]`).
- `username` is required, unique, and indexed (`*`, `@`, `[UK,IX]`).
- `password_hash` is encrypted (`#`).
- `profile_data` is an optional JSON blob (`-`).
- `created_at` is a system-generated timestamp (`-` with `[SYSTEM]` attribute).

### DBSoup File Anatomy

A DBSoup document is intentionally minimalistic. Each entity (table/collection) is defined in a **block** with three simple parts:

1. **Entity Header** – the canonical name of the table or collection.
2. **Rule Fence** – a line of `=` or `─` characters that visually separates the header from the fields.
3. **Field List** – one line per field with a leading symbol, name, type, and optional attributes.

```dbsoup
Order
==========
* id           : UUID                       [PK,AUTO]
@ order_no     : String(32)                 [UK,IX]
- customer_id  : UUID                       [FK:Customer.id]
# payment_token : String(255)               [ENCRYPTED]
~ credit_card  : String(19)                 [MASK:XXXX-XXXX-XXXX-####]
> tenant_id    : UUID                       [PARTITION:hash]
- created_at   : DateTime                   [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
$ audit_trail  : JSON                       [AUDIT:full]
- total_amount : Decimal(10,2)              [COMPUTED:price*quantity]
```

Legend:
- `*` → **Required / Primary** field  
- `@` → **Indexed** field  
- `-` → **Optional** field  
- `#` → **Sensitive** (encrypted/PII) field
- `~` → **Masked** field (data masking patterns)
- `>` → **Partitioned** field (sharding/partitioning keys)
- `$` → **Audit** field (compliance logging)

### Multi-Dimensional Information

Each prefix conveys **multiple layers of meaning** that inform different stakeholders:

- **Data Requirements** (required vs optional) - What's essential vs supplementary
- **Performance Characteristics** (indexed, partitioned) - How data is optimized for access
- **Security Posture** (sensitive, masked, audit) - What needs protection or tracking  
- **Business Criticality** (primary vs supplementary) - Core business data vs metadata

This semantic richness enables automated compliance checking, performance optimization, and security auditing directly from the schema definition.

### Core Prefixes

| Prefix | Semantic Meaning | Technical Purpose | Business Impact |
|--------|------------------|-------------------|------------------|
| `*` | **Required/Primary** | Cannot be null, essential to entity | Core business data |
| `-` | **Optional** | Nullable, supplementary | Nice-to-have data |
| `!` | **Indexed** | Performance-critical lookup | Query optimization |
| `@` | **Sensitive/Encrypted** | PII or encrypted data | Security/compliance |
| `~` | **Masked** | Data masking patterns | Privacy protection |
| `>` | **Partitioned** | Sharding/partitioning keys | Scalability strategy |
| `$` | **Audit** | Compliance logging | Regulatory tracking |

## Why This Prefix System Matters

### 1. Immediate Visual Scanning

The prefix system enables **at-a-glance comprehension** of complex schemas:

```dbsoup
User
==========
* user_id      : UUID                       [PK]           # Primary - can't be null
@ email        : String(255)                [UK,PII]       # Sensitive - needs encryption
! username     : String(50)                 [IX]           # Indexed - fast lookups
- phone        : String(20)                                # Optional - can be null
~ ssn          : String(11)                 [MASK:XXX-XX-####] # Masked - privacy
> tenant_id    : UUID                       [PARTITION:hash]   # Partitioned - scalability
$ audit_log    : JSON                       [AUDIT:full]       # Audit - compliance
```

Each field's **business purpose**, **technical requirements**, and **governance needs** are immediately visible.

### 2. Compliance & Governance

The prefixes enable **automated compliance** by making sensitive data immediately identifiable:

```dbsoup
Customer
==========
* id           : UUID           [PK,AUTO:uuid()]
@ email        : String(255)    [PII,ENCRYPTED,UK]        # GDPR-relevant
@ full_name    : String(100)    [PII]                     # GDPR-relevant  
~ credit_card  : String(19)     [PII,MASK:XXXX-XXXX-XXXX-####] # PCI-DSS
$ access_log   : JSON           [AUDIT:gdpr_required]     # Compliance tracking
- preferences  : JSON                                     # Non-sensitive
```

Automated tools can immediately identify:
- **PII fields** for GDPR compliance (`@` + `[PII]`)
- **Sensitive financial data** for PCI-DSS (`~` + masking patterns)
- **Audit requirements** for SOC-2 compliance (`$` + `[AUDIT]`)

### 3. Performance Planning

Operational characteristics are **visually obvious** for database optimization:

```dbsoup
OrderMetrics
==========
! order_id     : UUID           [IX:clustered,FK:Order.id]     # High-performance lookup
! customer_id  : UUID           [IX:btree]                     # Frequent joins
> region_code  : String(10)     [PARTITION:range]             # Horizontal scaling
@ created_date : Date           [IX:btree,AUDIT]              # Time-series queries
- metadata     : JSON                                         # Flexible storage
```

Database architects can instantly see:
- **Query optimization** strategy (`!` for indexes)
- **Scaling patterns** (`>` for partitioning)
- **Access patterns** (clustered vs standard indexes)

### 4. Integration with Constraint Annotations

The prefixes work **in combination** with bracket annotations `[...]` to provide complete field semantics:

```dbsoup
Account
==========
* id           : UUID           [PK,AUTO:uuid()]                    # Primary + auto-generated
@ email        : String(255)    [UK,PII,IX,ENCRYPTED:aes256]       # Sensitive + unique + indexed  
! account_no   : String(20)     [IX:btree,GENERATED:sequence]      # Indexed + generated sequence
- phone        : String(20)     [MASK:XXX-XXX-####]               # Optional + masked
> shard_key    : String(10)     [PARTITION:range,FK:Region.id]     # Partitioned + foreign key
$ created_at   : DateTime       [AUDIT,SYSTEM,DEFAULT:CURRENT_TIMESTAMP] # Audit + system-generated
```

This dual-layer approach provides:
- **Visual semantics** through prefixes (quick scanning)
- **Technical precision** through annotations (automation-ready)

### 5. Visual Design Philosophy  

The prefix system follows **intuitive visual hierarchy principles**:

| Prefix | Visual Metaphor | Business Meaning | Technical Implication |
|--------|----------------|------------------|----------------------|
| `*` | "Star/Important" | Critical business data | Cannot be null |
| `@` | "Address/Identity" | Personal/sensitive data | Needs encryption/indexing |  
| `!` | "Attention/Alert" | Performance-critical | Database index required |
| `-` | "Optional/Dash" | Supplementary data | Nullable field |
| `~` | "Approximate/Wave" | Hidden/obfuscated | Data masking applied |
| `>` | "Arrow/Direction" | Distribution key | Partitioning/sharding |
| `$` | "Value/Money" | Valuable for tracking | Audit trail required |

This makes DBSoup schemas **scannable at a glance** while maintaining precise technical meaning for automated tools.

System-generated or computed fields are indicated by the `[SYSTEM]`, `[AUTO]`, or `[COMPUTED:expr]` attributes inside the brackets rather than by a separate prefix.

Attributes in square brackets capture constraints, defaults, relationships, and even security hints—making DBSoup self-describing and automation-ready.

## 2. Why Use DBSoup?

- **Clarity & Standardization:** A single, consistent format ends the confusion of switching between SQL DDL, MongoDB JSON schemas, and messy Word documents.
- **AI & Automation Friendly:** Its structured nature is designed for machines. This enables automated schema analysis, visualization, code generation, and even guided migrations.
- **Rich Semantics:** DBSoup goes beyond basic types. It captures indexes, constraints, security properties (like encryption and PII), and performance patterns (like caching and partitioning).
- **VCS-Friendly:** Since it's just text, you can version your schema in Git, review changes in pull requests, and track its evolution alongside your application code.

### DBSoup vs. Traditional ER Diagrams

While Entity-Relationship (ER) diagrams have long been the de-facto way to visualize database structure, they are often **static pictures** that fall short in modern, iterative workflows. DBSoup addresses these shortcomings:

| Advantage | ER Diagrams | DBSoup |
|-----------|-------------|--------|
| **Version Control & Diffing** | Images or PDFs don't diff well and are hard to review in pull requests. | Pure text—every change is line-by-line, commentable, and merge-friendly. |
| **Single Source of Truth** | Diagram can drift out of sync with actual DDL or migrations. | DBSoup _is_ the schema; it can be parsed to generate DDL and diagrams, eliminating drift. |
| **Automation & Tooling** | Limited machine readability; requires manual updates. | Formal grammar makes it easy for linters, generators, and AI agents to consume. |
| **Expressiveness** | Typically shows tables & relationships only. | Captures constraints, indexes, security flags (PII, encryption), computed fields, and more. |
| **Collaboration** | Requires specialized software; not ideal for code-review culture. | Works in any code editor; collaborative reviews happen in the same Git workflow as code. |
| **Scalability** | Large schemas become unreadable or require multiple pages. | Text scales naturally; you can navigate by search, split into modules, or generate focused diagrams on demand. |
| **CI/CD Integration** | Hard to validate automatically. | DBSoup files can be linted and validated in CI to prevent bad schema changes. |
| **AI Readiness** | Images require OCR or manual interpretation. | Plain-text grammar is immediately consumable by LLMs for analysis, generation, and refactoring. |

In short, DBSoup retains all the **visualization possibilities** of ER diagrams—because diagrams can still be generated from DBSoup—while adding the power of a text-based, Git-native, AI-friendly workflow.

### DBSoup vs. Other Database-as-Code Tools

A growing ecosystem of "schema-as-code" tools exists—each with its own focus, assumptions, and trade-offs. DBSoup was designed to be the **human- and AI-readable source of truth** that sits at the very start of the workflow, generating migrations, diagrams, and docs rather than being generated by them.

| Criteria | DBSoup | DBML | Atlas (Ariga) | Prisma Schema | Liquibase / Flyway |
|----------|--------|------|---------------|---------------|--------------------|
| **Primary Goal** | Authoritative, review-friendly schema DSL | Quick ER diagrams & docs | Drift-free migrations & automated DDL | Type-safe ORM model for JS/TS | Imperative/Diff-based migrations |
| **File Format** | Plain-text DSL (one entity per block) | Markdown-like DSL | SQL + JSON/HCL config | TypeScript-style DSL | XML / YAML / SQL |
| **Supported DBs** | Relational **and** NoSQL (vision) | Relational | Relational (MySQL, Postgres, SQLite, MariaDB) | Relational (Postgres, MySQL, SQL Server, SQLite) | Relational |
| **Metadata Depth** | Constraints, indexes, security, lifecycle, partitioning | Tables & relations only | Full DDL, limited higher-level metadata | Columns & relations, limited constraints | Migrations only (no holistic view) |
| **Git Diff-ability** | ✅ Single file, line-diff friendly | ✅ | ⚠️ SQL churn, generated code | ⚠️ Generated client code | ⚠️ Long SQL scripts |
| **Diagram Generation** | ✅ (via tooling) | ✅ built-in | ⚠️ external | ⚠️ external | ❌ |
| **AI/LLM Readiness** | Designed for deterministic parsing | Simple grammar | Needs SQL parser | Custom parser | Hard for LLMs to reason about |

**Why DBSoup Stands Out**

1. **Poly-glot Reach:** Aims to capture both relational and emerging NoSQL/document stores in a unified grammar.
2. **Metadata-Rich:** Encodes security flags (e.g., PII, encryption), performance hints, and lifecycle rules—information most tools ignore.
3. **AI-First Design:** A concise, regular grammar makes it trivial for language models to read, validate, and even generate DBSoup.
4. **Source-of-Truth Philosophy:** You write DBSoup once; diagrams, migrations, seed data, and docs are generated from it—never the other way around.
5. **Seamless Collaboration:** Entire schema lives in plain text, so pull-request reviews feel just like code reviews, with no proprietary IDE required.

### Metadata Model Deep Dive

Most schema-as-code tools stop at column definitions and simple relations. DBSoup layers **business, security, and operational metadata** directly onto each field so that one file can drive migrations, docs, and governance.

| Metadata Category | Why It Matters | DBSoup Example Attribute |
|-------------------|----------------|--------------------------|
| **Security & PII** | Identify sensitive data for encryption or masking. | `[PII]`, `[ENCRYPTED]` |
| **Constraints** | Enforce uniqueness, foreign keys, or check rules. | `[UK]`, `[FK:Orders.id]`, `[CHECK:amount>0]` |
| **Lifecycle** | Model soft-deletes, TTL, or archival policies. | `[META:soft_delete]`, `[TTL:90d]` |
| **Performance** | Hint indexes, partitions, or caching strategies. | `[IX]`, `[PARTITION:monthly]`, `[CACHE]` |
| **Auditing** | Track who/when changed data. | `[AUDIT]` |
| **Business Semantics** | Capture domain-specific flags (e.g., loyalty tier). | `[DOMAIN:crm.loyalty]` |

Illustrative snippet:

```dbsoup
Customer
==========
* id         : UUID                         [PK,AUTO]
* @ email    : String(255)                  [UK,PII,IX]
- name       : String(100)                  [PII]
- tier       : Enum('FREE','PRO','ENT')     [DEFAULT:'FREE',IX]
- created_at : DateTime                     [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- deleted_at : DateTime                     [META:soft_delete]
```

From a single DBSoup file you can now:
1. **Generate migration SQL** that adds the unique index on `email`, foreign keys, and check constraints.
2. **Produce compliance reports** highlighting PII columns (`email`, `name`).
3. **Configure automatic masking** or encryption policies for sensitive fields.
4. **Drive lifecycle jobs** that purge rows where `deleted_at` is older than 30 days.
5. **Feed API generators** that expose `tier` as a typed enum.

Competing tools typically require **multiple configuration files**—or don't capture this information at all—making DBSoup a uniquely comprehensive yet readable single source of truth.

## 3. Documentation

To get started with DBSoup, refer to the following documents based on your needs:

| Document | Audience | Purpose |
|---|---|---|
| 📄 **[Main Guide](docs/DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md)** | **Everyone** (Developers & AI) | **Your starting point.** This is the complete guide to the core DBSoup notation, the decision framework for converting any schema, and best practices. |
| ⚠️ **[Error Prevention Checklist](docs/DBSOUP_ERROR_PREVENTION_CHECKLIST.md)** | **Everyone** (Developers & AI) | **CRITICAL:** Quick reference checklist to avoid common mistakes, especially the #1 error of using `_` prefix for system fields. Use this before, during, and after conversions. |
| 🚀 **[Extras & Advanced Guide](docs/DATABASE_SCHEMA_TO_DBSOUP_EXTRAS.md)** | **Specialists & AI** | Covers less-common database engines (e.g., Snowflake, Neo4j), advanced enterprise patterns, versioning, and tooling strategies. Check here if the main guide doesn't cover your specific use case. |
| 📐 **[Technical Specifications](docs/DBSOUP_SPECIFICATIONS.md)** | **Developers & AI** | Complete technical specifications including syntax, validation rules, and tooling integration. |
| 🔗 **[Relationships Example](docs/DBSOUP_RELATIONSHIPS_EXAMPLE.md)** | **Developers & AI** | Comprehensive examples of complex relationship modeling patterns including one-to-many, many-to-many, inheritance, and junction tables. |
| 🎨 **[SVG Interactive Features](docs/10_SVG_INTERACTIVE_FEATURES.md)** | **Developers & AI** | Guide to interactive SVG features including **instant hover tooltips**, **module-based organization with descriptions**, clickable foreign key navigation, and enhanced visual styling. |
| 🌈 **[SVG Color Reference](docs/09_SVG_COLOR_REFERENCE.md)** | **Developers & AI** | Complete color reference for SVG diagrams including field types, entity styles, and embedded entity highlighting. |
| 🔧 **[Formal Grammar](docs/DBSOUP_GRAMMAR.ebnf)** | **Tool Builders & AI** | The strict, formal EBNF grammar for the DBSoup language. Use this to build linters, validators, parsers, or any other automated tooling. |

## 4. Getting Started

### ⚠️ CRITICAL: Error Prevention First

**Before doing any conversion, avoid the #1 mistake:**

❌ **NEVER use `_` prefix for system fields:**
```dbsoup
_ created_at : DateTime                     [SYSTEM]  # WRONG
_ updated_at : DateTime                     [SYSTEM]  # WRONG
```

✅ **CORRECT - Use regular prefixes with constraint annotations:**
```dbsoup
- created_at : DateTime                     [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- updated_at : DateTime                     [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
```

**Always check the [Error Prevention Checklist](docs/DBSOUP_ERROR_PREVENTION_CHECKLIST.md) before starting any conversion.**

### For Developers

1. **START HERE:** Review the **[Error Prevention Checklist](docs/DBSOUP_ERROR_PREVENTION_CHECKLIST.md)** to avoid common mistakes.
2. Read the **[Main Guide](docs/DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md)** to understand the philosophy and syntax.
3. Reference the **[Technical Specifications](docs/DBSOUP_SPECIFICATIONS.md)** for complete syntax details and validation rules.
4. Try documenting one of your existing database schemas using the DBSoup format.
5. If you hit an advanced or uncommon database feature, consult the **[Extras Guide](docs/DATABASE_SCHEMA_TO_DBSOUP_EXTRAS.md)**.
6. View the **[Relationships Example](docs/DBSOUP_RELATIONSHIPS_EXAMPLE.md)** to understand complex relationship modeling.

### For AI Systems

Your goal is to parse, understand, and generate DBSoup documents.

1. **CRITICAL FIRST STEP:** Ingest the **[Error Prevention Checklist](docs/DBSOUP_ERROR_PREVENTION_CHECKLIST.md)** to avoid the most common conversion errors.
2. **Primary Knowledge Source:** Ingest the **[Main Guide](docs/DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md)**. It contains the core rules, mappings, and decision logic you need to perform conversions.
3. **Technical Reference:** Use the **[Technical Specifications](docs/DBSOUP_SPECIFICATIONS.md)** for complete syntax specifications and validation rules.
4. **Secondary Knowledge Source:** Use the **[Extras Guide](docs/DATABASE_SCHEMA_TO_DBSOUP_EXTRAS.md)** to handle database engines and patterns not covered in the main guide.
5. **Relationship Modeling:** Review the **[Relationships Example](docs/DBSOUP_RELATIONSHIPS_EXAMPLE.md)** for complex relationship patterns.
6. **For Strict Validation:** Use the **[Formal Grammar](docs/DBSOUP_GRAMMAR.ebnf)** to validate the syntax of any DBSoup file you read or write. This ensures your output is compliant with the formal specification.

**Always check the [Error Prevention Checklist](docs/DBSOUP_ERROR_PREVENTION_CHECKLIST.md) before starting any conversion.**

### Example Prompt Template

You can use the following template to instruct another AI:

"Hello, your task is to act as a database documentation specialist. I need you to convert the database schema I provide into the **DBSoup** format.

To do this, you MUST follow the rules and conventions defined in the document `DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md`. This guide is your primary source of truth for all syntax, data type mappings, and decision-making logic. It will be provided as context.

For any advanced or non-standard database features (like those in Snowflake, Neo4j, or with specific compliance needs), refer to the supplemental `DATABASE_SCHEMA_TO_DBSOUP_EXTRAS.md` document, which will also be provided.

Now, please convert the following schema into a complete and valid `.dbsoup` document:

```
<-- PASTE YOUR SOURCE SCHEMA HERE (e.g., SQL CREATE TABLE statements, JSON, etc.) -->
```
---

By using this structured prompt, you ensure the AI has the necessary instructions and reference material to create an accurate and high-quality DBSoup document. 

### Why Database-as-Code Now?

The way we build applications has changed dramatically:

1. **Microservices & Polyglot Persistence:** A single product may rely on PostgreSQL, Redis, and a cloud data warehouse—all with different schema paradigms.
2. **DevOps & CI/CD:** Schemas evolve daily. Database changes need to flow through the same review and automation pipelines as code.
3. **AI-Driven Engineering:** Language models can write boilerplate, review pull-requests, and even refactor code—but only when the source material is machine-readable.
4. **Compliance & Security:** Regulations like GDPR and SOC-2 require auditable, version-controlled definitions of sensitive data.
5. **Remote Collaboration:** Screenshots of ER diagrams don't cut it for distributed teams working across time zones.

A database-as-code approach turns your schema into **text**—the lingua franca of modern development—so it can be linted, diffed, tested, and understood by both humans and AI.

From SQL to NoSQL, DBSoup captures modern database complexity in a single source of truth—one that's easy to understand for both developers and AI systems. 