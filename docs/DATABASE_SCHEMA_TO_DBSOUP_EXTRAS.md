# Database Schema to DBSoup Format – Extras

> This addendum extends the primary **Database Schema to DBSoup Format Guide** with advanced coverage areas that were intentionally left out of the core document for the sake of focus and length.
>
> • **Who should read this?** Teams facing less-common database engines, complex source artefacts (ORMs, data-lake formats, etc.), or enterprise requirements beyond the mainstream SQL/Mongo scope.
>
> • **How to use it?** Treat each section as a plug-in. Most conversion flows will need only a subset of what follows.

---

## Table of Contents  
1. Additional Database Engines  
   1.1 MySQL / MariaDB  
   1.2 Snowflake, BigQuery, Redshift  
   1.3 Neo4j & Graph DBs  
   1.4 Cassandra, DynamoDB, Cosmos DB  
2. Additional Schema Source Formats  
3. Embedded Entity Patterns  
4. Versioning & Change Management  
5. Validation & Tooling  
6. Examples & Edge Cases  
7. Performance & Cost Optimisation  
8. Security Certifications & Compliance  
9. Internationalisation (i18n)  
10. End-to-End Walk-through Example  

---

## 1  Additional Database Engines

### 1.1  MySQL / MariaDB

| Recognition Pattern | DBSoup Mapping / Note |
|---------------------|------------------------|
| `AUTO_INCREMENT`    | `[AUTO_INCREMENT]` (already covered, but note unsigned PKs and 64-bit overflow) |
| `GENERATED ALWAYS` / `VIRTUAL` / `STORED` | Use `[COMPUTED:expr]` vs `[STORED:expr]` constraint notation |
| `FULLTEXT` index    | `! field : Text [IX:fulltext]` |
| `ENUM` / `SET`      | `Enum(values)` / `Set(values)` |
| Engine hints (`ENGINE=InnoDB`) | Capture only if semantics differ (row-store vs column-store) |
| Partition clauses (`PARTITION BY HASH`) | `- field : Type [PARTITION:hash]` |

> **Processing Steps**
> 1. Extract table definition (watch for `PRIMARY KEY USING BTREE` nuances).  
> 2. Map `UNSIGNED` ints to DBSoup comment `[UNSIGNED]` if business-critical.  
> 3. Convert generated columns with care—MySQL `GENERATED` columns can be *virtual* (not persisted) or *stored*.  
>

### 1.2  Snowflake / BigQuery / Redshift

| Engine | Feature | DBSoup Annotation |
|--------|---------|-------------------|
| Snowflake | `VARIANT`, `OBJECT`, `ARRAY` | `JSON` / `Array<Type>` |
| Snowflake | Time-Travel / Fail-Safe | `@ dbsoup::snowflake::time_travel(days)` (*comment only*) |
| BigQuery | `STRUCT<...>` | `JSON` |
| BigQuery | Clustering Keys | `@ field : Type [CLUSTER]` |
| Redshift | `DISTKEY`, `SORTKEY` | `@ field : Type [DISTKEY]`, `[SORTKEY]` |

> Because these are **column-store** systems, also record compression/encoding hints in comments, e.g. `[ENCODING:zstd]`.

### 1.3  Neo4j & Graph DBs

| Concept | DBSoup Mapping |
|---------|---------------|
| Node    | Entity (prefix with module `Graph::` for clarity) |
| Relationship | Separate entity with `_from` and `_to` foreign keys or use `@ relationships::` with `(N:M)` cardinality |
| Property Keys | Fields under the node entity |
| Labels | Treat as Enum tag list or separate boolean flags |

> **Example**
> ```
> Graph::Person
> ==========
> * _id        : ID                           [PK]
> * name       : String                       
> - born       : Int                          
>
> Graph::ACTED_IN
> ==========
> * _id        : ID                           [PK]
> * _from      : ID                           [FK:Graph::Person._id]
> * _to        : ID                           [FK:Graph::Movie._id]
> - roles      : Array<String>                
> ```

### 1.4  Cassandra / DynamoDB / Cosmos DB

| Engine | Recognition Pattern | DBSoup Mapping |
|--------|---------------------|----------------|
| Cassandra | `PRIMARY KEY ((pk), ck1, ck2)` | `* pk : Type [PK,PARTITION]`, `@ ck1 : Type [CLUSTER]` |
| Cassandra | `WITH CLUSTERING ORDER BY` | Use `[ORDER:ASC]` / `[ORDER:DESC]` comment |
| DynamoDB | Partition & Sort Keys | `* pk : Type [PARTITION]`, `@ sk : Type [SORT]` |
| DynamoDB | TTL attribute          | `@ expires_at : DateTime [TTL]` |
| Cosmos DB | `/_ts`, `_etag`       | System fields (`_` prefix) |

---

## 2  Additional Schema Source Formats

| Source Artefact | Detection Heuristic | Conversion Tips |
|-----------------|---------------------|-----------------|
| **ORM Models** (Sequelize, TypeORM, Prisma) | Presence of `define('table', { … })`, decorators like `@Column()` | Parse JSON‐like model metadata, then map to DBSoup fields/constraints |
| **Avro / Parquet Schemas** | `.avsc` files, `type": "record"` | Map records → entities, fields → Avro types table, note `logicalType` (e.g., `timestamp-millis`) |
| **OpenAPI / JSON-Schema** | `components.schemas` section | Treat each schema as an entity; mark `required` list with `*` prefix |
| **ERD PDFs** | OCR + heuristic parsing | May require human-assisted field extraction; record data confidence levels |

---

## 3 Enterprise Features and Patterns

### Security and Compliance Patterns

#### GDPR Compliant Data Structure
```
PersonalData
==========
* _id             : ID                       [PK]
* user_id         : ID                       [FK:User._id]
@ first_name      : String                   [ENCRYPT:AES256,GDPR]
@ last_name       : String                   [ENCRYPT:AES256,GDPR]
@ email           : String                   [ENCRYPT:AES256,GDPR,UK]
@ phone           : String                   [ENCRYPT:AES256,GDPR]
~ ssn             : String                   [MASK:XXX-XX-####,GDPR]
- consent_date    : DateTime                 [AUDIT:gdpr,DEFAULT:NOW()]
- data_retention_date : DateTime             [AUDIT:gdpr]
+ is_deleted      : Boolean                  [IMMUTABLE,DEFAULT:false]
$ audit_trail     : JSON                     [AUDIT:full]

# GDPR Compliance
* right_to_erasure : Boolean                 [DEFAULT:false]
* data_processing_consent : Boolean          [DEFAULT:false]
* marketing_consent : Boolean                [DEFAULT:false]
- consent_withdrawal_date : DateTime         
```

#### Row-Level Security Pattern
```
SecureDocument
==========
* _id            : ID                        [PK]
* title          : String                    
* content        : Text                      
* owner_id       : ID                        [FK:User._id]
* classification : Enum(public,confidential,secret,top_secret) [RLS:classification_policy]
* access_list    : Array<ID>                 [RLS:access_control]
$ security_audit : SecurityAudit             [AUDIT:security]

SecurityAudit
/=======/
* _id            : ID                        [PK]
* secure_doc_id  : ID                        [FK:SecureDocument._id]
* created_by     : ID                        [FK:User._id]
* created_at     : DateTime                  
* last_accessed  : DateTime                  
* access_count   : Int                       
- failed_attempts : FailedAccessAttempt[0..*]

FailedAccessAttempt
/=======/
* _id            : ID                        [PK]
* security_audit_id : ID                     [FK:SecurityAudit._id]
* user_id        : ID                        [FK:User._id]
* attempted_at   : DateTime                  
* reason         : String                    
@ encrypted_content : Text                   [ENCRYPT:AES256]
```

#### Data Masking and Anonymization
```
UserProfile
==========
* _id             : ID                       [PK]
* user_id         : ID                       [FK:User._id]
~ full_name       : String                   [MASK:FirstName L.]
~ email           : String                   [MASK:f***@example.com]
~ phone           : String                   [MASK:(***) ***-####]
~ address         : String                   [MASK:*** Street, City, **]
~ credit_card     : String                   [MASK:****-****-****-1234]
~ ip_address      : String                   [MASK:***.***.***.***]
- anonymized_data : AnonymizedData           

AnonymizedData
/=======/
* _id             : ID                       [PK]
* user_profile_id : ID                       [FK:UserProfile._id]
* age_range       : String                   
* location_city   : String                   
* interests       : Array<String>            
```

### High Availability and Disaster Recovery

#### Master-Slave Replication Pattern
```
CriticalData
==========
* _id             : ID                       [PK]
* data_id         : UUID                     [UK]
* content         : Text                     
& replicated_content : Text                  [REPLICATE:master-slave,SYNC:async]
& backup_content  : Text                     [REPLICATE:backup,SYNC:sync]
% cached_summary  : String                   [CACHED:redis,TTL:3600]
* backup_hash     : String                   [BACKUP:incremental]
@ cluster_key     : String                   [SHARD:consistent-hash]
- replication_lag : Int                      [MONITOR:replication-delay]
$ replication_audit : JSON                   [AUDIT:replication]
```

#### Disaster Recovery Metadata
```
BackupMetadata
==========
* _id             : ID                       [PK]
* backup_id       : UUID                     [UK]
* source_table    : String                   
* backup_date     : DateTime                 
* backup_size     : BigInt                   
* backup_type     : Enum(full,incremental,differential)
* recovery_point  : DateTime                 [RTO:4hours]
* backup_location : String                   [BACKUP:offsite]
* encryption_key_id : String                 [ENCRYPT:backup-key]
* checksum        : String                   [MONITOR:integrity]
* retention_period : Int                     [DEFAULT:2555] # 7 years in days
$ disaster_recovery : DisasterRecoveryAudit  [AUDIT:dr]

DisasterRecoveryAudit
/=======/
* _id             : ID                       [PK]
* backup_metadata_id : ID                   [FK:BackupMetadata._id]
* last_test_date  : DateTime                 
* recovery_time_actual : Int                 
* recovery_point_actual : DateTime           
* test_result     : String                   
```

### Performance Optimization Patterns

#### Heavily Optimized Table
```
HighPerformanceEntity
==========
* _id             : ID                       [PK,CLUSTER]
! tenant_id       : ID                       [FK:Tenant._id,IX:1,PARTITION:tenant_id]
! created_date    : DateTime                 [IX:1,PARTITION:monthly]
! status          : Enum(active,inactive,archived) [IX:1]
! priority        : Int                      [IX:1,CK:priority BETWEEN 1 AND 5]
! category_id     : ID                       [FK:Category._id,CIX:(tenant_id,category_id,created_date)]
% search_index    : Text                     [CACHED:elasticsearch]
^ computed_score  : Float                    [COMPUTED:priority * 0.3 + category_weight * 0.7]
< large_content   : Text                     [COMPRESS:lz4]
> partition_key   : String                   [PARTITION:hash(tenant_id)]

# Performance Monitoring
- query_count     : BigInt                   [MONITOR:query-frequency]
- avg_response_time : Float                  [MONITOR:performance,THRESHOLD:200ms]
- cache_hit_ratio : Float                    [MONITOR:cache-efficiency]
```

#### Time Series Optimization
```
TimeSeriesData
==========
* _id             : ID                       [PK]
* timestamp       : DateTime                 [TIMESERIES:timeField,PARTITION:daily]
* device_id       : String                   [TIMESERIES:metaField,IX:hash]
* metric_name     : String                   [TIMESERIES:metaField]
* value           : Double                   [TIMESERIES:measurement]
* quality         : Float                    [TIMESERIES:measurement,CK:quality BETWEEN 0 AND 1]
* metadata        : TimeSeriesMetadata       [TIMESERIES:metadata]

TimeSeriesMetadata
/=======/
* _id             : ID                       [PK]
* timeseries_data_id : ID                   [FK:TimeSeriesData._id]
* location        : String                   
* building        : String                   
* floor           : Int                      
* sensor_type     : String                   
* calibration_date : DateTime                
@ timestamp,device_id : DateTime,String      [CIX:(covering)]
< historical_data : Buffer                   [COMPRESS:zstd,ARCHIVE:cold-storage]
% aggregated_hourly : HourlyAggregation      [CACHED:aggregation]

HourlyAggregation
/=======/
* _id             : ID                       [PK]
* timeseries_data_id : ID                   [FK:TimeSeriesData._id]
* avg             : Double                   
* min             : Double                   
* max             : Double                   
* count           : Int                      
```

### Advanced Indexing Strategies

#### Composite and Specialized Indexes
```
SearchOptimizedEntity
==========
* _id             : ID                       [PK]
! title : String [FIX:gin(to_tsvector('english', title))]
! content : Text [FIX:gin(to_tsvector('english', content))]
! tags : Array<String> [IX:gin,MULTIKEY]
! created_date : DateTime [IX:btree]
! location : Geography [IX:gist]
! price_range : NumRange [IX:gist]
! metadata : JSONB [FIX:gin(metadata)]
! status,priority : Enum,Int [CIX:(covering,id,title,created_date)]
! customer_id,order_date : ID,DateTime [CIX:(customer_orders)]
! active_status : Boolean [PIX:(WHERE active_status = true)]

# Specialized Indexes
! search_vector : TSVector [FIX:gin] [COMPUTED:to_tsvector('english', title || ' ' || content)]
! geohash : String [FIX:btree] [COMPUTED:ST_GeoHash(location, 8)]
! normalized_name : String [FIX:btree] [COMPUTED:lower(trim(title))]
```

### File and Media Handling

#### GridFS Advanced Pattern (MongoDB)
```
GridFS_Files
==========
* _id            : ObjectId                  [PK]
* length         : Long                      
* chunk_size     : Int                       [DEFAULT:261120]
* upload_date    : DateTime                  [IX:1]
* filename       : String                    [IX:text]
* content_type   : String                    [IX:1]
* metadata       : FileMetadata              [VALIDATE:required]

FileMetadata
/=======/
* _id : ObjectId [PK]
* file_id : ObjectId [FK:GridFS_Files._id]
* original_name : String [VALIDATE:required]
* uploaded_by : ObjectId [VALIDATE:required]
* file_hash : String [VALIDATE:required]
* tags : Array<String> [IX:multikey]
* categories : Array<String> [IX:multikey]
- virus_scan : VirusScanResult
- image_metadata : ImageMetadata
- video_metadata : VideoMetadata
- processing : ProcessingStatus
- access_control : AccessControl

VirusScanResult
/=======/
* _id : ObjectId [PK]
* file_metadata_id : ObjectId [FK:FileMetadata._id]
* status : String [VALIDATE:enum:('pending','clean','infected','error')]
* scanned_at : DateTime
* scanner_version : String
* scan_result : String

ImageMetadata
/=======/
* _id : ObjectId [PK]
* file_metadata_id : ObjectId [FK:FileMetadata._id]
* width : Int
* height : Int
* format : String
* color_space : String
* has_transparency : Boolean
* exif : JSON  # Keep as JSON for unstructured EXIF data

VideoMetadata
/=======/
* _id : ObjectId [PK]
* file_metadata_id : ObjectId [FK:FileMetadata._id]
* duration : Int
* codec : String
* resolution : String
* frame_rate : Float
* bitrate : Int

ProcessingStatus
/=======/
* _id : ObjectId [PK]
* file_metadata_id : ObjectId [FK:FileMetadata._id]
* status : String [VALIDATE:enum:('pending','processing','completed','failed')]
- thumbnails : ProcessingThumbnail[0..*]
- transcodes : ProcessingTranscode[0..*]

ProcessingThumbnail
/=======/
* _id : ObjectId [PK]
* processing_status_id : ObjectId [FK:ProcessingStatus._id]
* size : String
* url : String
* file_id : ObjectId

ProcessingTranscode
/=======/
* _id : ObjectId [PK]
* processing_status_id : ObjectId [FK:ProcessingStatus._id]
* format : String
* quality : String
* url : String
* file_id : ObjectId

AccessControl
/=======/
* _id : ObjectId [PK]
* file_metadata_id : ObjectId [FK:FileMetadata._id]
* public : Boolean [DEFAULT:false]
* allowed_users : Array<ObjectId>
* allowed_roles : Array<String>
* expiry_date : DateTime
@ filename,content_type : String [CIX]
@ metadata.uploaded_by : ObjectId [IX:1]
@ metadata.tags : Array<String> [IX:multikey]
@ metadata.virus_scan.status : String [IX:1]
@ metadata.processing.status : String [IX:1]
# Note: Above indexes reference embedded entity fields

GridFS_Chunks
==========
* _id            : ObjectId                  [PK]
* files_id       : ObjectId                  [FK:GridFS_Files._id,IX:1]
* n              : Int                       [IX:1]
* data           : BinData                   
@ files_id,n     : ObjectId,Int              [CIX:(unique)]
```

#### Cloud File Storage Pattern
```
CloudFileMetadata
==========
* _id             : ID                       [PK]
* file_id         : UUID                     [UK]
* storage_provider : Enum(aws_s3,azure_blob,gcs,local) [IX]
* bucket_name     : String                   
* object_key      : String                   [UK]
* file_size       : BigInt                   
* content_type    : String                   [IX]
* etag            : String                   
* version_id      : String                   
* storage_class   : Enum(standard,reduced_redundancy,glacier,deep_archive)
- encryption      : CloudEncryption          
- access_control  : CloudAccessControl       
- cdn_config      : CloudCDNConfig           
$ file_audit      : CloudFileAudit           [AUDIT:file-access]

CloudEncryption
/=======/
* _id : ID [PK]
* cloud_file_id : ID [FK:CloudFileMetadata._id]
* algorithm : String
* key_id : String
* server_side : Boolean

CloudAccessControl
/=======/
* _id : ID [PK]
* cloud_file_id : ID [FK:CloudFileMetadata._id]
* public_read : Boolean [DEFAULT:false]
* signed_url_expiry : Int [DEFAULT:3600]
* cors_allowed_origins : Array<String>
* allowed_methods : Array<String>

CloudCDNConfig
/=======/
* _id : ID [PK]
* cloud_file_id : ID [FK:CloudFileMetadata._id]
* enabled : Boolean [DEFAULT:false]
* distribution_id : String
* cache_ttl : Int [DEFAULT:86400]
* edge_locations : Array<String>

CloudFileAudit
/=======/
* _id : ID [PK]
* cloud_file_id : ID [FK:CloudFileMetadata._id]
* upload_date : DateTime
* last_accessed : DateTime
* access_count : Int [DEFAULT:0]
* download_count : Int [DEFAULT:0]
* last_modified : DateTime
@ storage_provider,bucket_name : Enum,String [CIX]
@ content_type,file_size : String,BigInt [CIX]
```

This expanded section provides comprehensive enterprise-grade patterns while maintaining the AI-friendly structure and decision-making frameworks.

---

## 4  Versioning & Change Management

1. **In-File Version Header**  
   ```
   @dbsoup-version: 1.2.0
   @schema-source: mysql-ddl-dump-2024-07-01.sql
   ```
2. **Git Diff Workflow**  
   • Store DBSoup files in VCS; pull requests show semantic diffs.  
3. **Migration Generation**  
   • Use tooling (`dbsoup diff --to=sql`) to emit Liquibase/Flyway scripts.  
   • Mark **breaking** vs **non-breaking** changes by inline comment `[BREAKING]`.

---

## 5  Validation & Tooling

• **Reference JSON Schema** ➜ `/schema/dbsoup.schema.json` (suggested path)  
• **CLI Commands**  
  ```bash
  dbsoup lint my_schema.dbsoup       # structural & logical checks
  dbsoup diff old.dbsoup new.dbsoup  # migration plan
  dbsoup render my_schema.dbsoup --format=erd
  ```
• **CI Integration** – fail pipeline if `dbsoup lint` exits non-zero.  

---

## 6  Examples & Edge Cases

| Scenario | Mini-Snippet |
|----------|-------------|
| **Composite PK** | `* order_id,product_id : ID [PK]` |
| **Polymorphic FK** | `- parent_id : ID [POLY:User,Account]` |
| **Circular FK** | Use separate relationships section with note `# CIRCULAR` |
| **Self-Reference** | `- manager_id : ID [FK:Employee._id]` |
| **Multi-Tenant Row-Level** | `> tenant_id : ID [PARTITION:tenant]` |

---

## 7  Performance & Cost Optimisation

1. **Storage Tiering** – use `<` prefix with `[ARCHIVE:cold]` to signal S3 Glacier-like storage.  
2. **Column-Store Hints** – annotate compression and encoding (`[ENCODING:zstd]`).  
3. **Materialised Views** – document as entities with `_is_view : Boolean [DEFAULT:true]` + `[REFRESH:hourly]`.

---

## 8  Security Certifications & Compliance

| Standard | Typical DBSoup Annotations |
|----------|---------------------------|
| **HIPAA** | `~ phi_data : JSON [HIPAA:sensitive]` |
| **PCI-DSS** | `@ card_number : String [ENCRYPT:AES256,PCI]` |
| **SOC 2** | `$ audit_log : JSON [AUDIT:soc2]` |
| **FedRAMP** | Tag tables with `@fedramp::impact_level:moderate` comment block |

Add a small **Compliance Matrix** appendix summarising which prefixes satisfy which controls.

---

## 9  Internationalisation (i18n)

| Concern | DBSoup Technique |
|---------|-----------------|
| Collation / Char-set | `[COLLATE:utf8mb4_unicode_ci]`, `[CHARSET:utf8mb4]` |
| Multi-Lingual Text Search | `@ search_vector : TSVector [LANG:'ja']` |
| Localised Fields | Store as `JSON` map `{ "en": "Name", "fr": "Nom" }` |

---

## 10  End-to-End Walk-through Example

1. **Input** – a 3-table MySQL snippet (see `/examples/invoices.sql`).  
2. **Step-by-Step** – run through the AI workflow (parse → apply rules → structure → validate).  
3. **Output** – final DBSoup found in `/examples/invoices.dbsoup` plus linter report.  

> _Having a living example in the repo serves as a regression test: future rule changes must not break the diff._

---

### Contributing to This Extras File

* Open a PR targeting `docs/extras` with the section tag (e.g., `[Snowflake]`) in the title.
* Update the Table of Contents if you add a top-level section.
* Run `dbsoup lint` on all sample DBSoup snippets.

---

© 2024 – DBSoup project contributors.  Licensed under the Apache 2.0 License. 