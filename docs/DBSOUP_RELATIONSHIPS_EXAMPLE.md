# DBSoup Relationships Definition Example

## Complete Example with Relationships Definition

Here's a comprehensive example showing how the new relationships definition section works in practice:

```dbsoup
@ecommerce-system.dbsoup

=== RELATIONSHIP DEFINITIONS ===
# One-to-One Relationships
User -> UserProfile [1:1] (composition)
Customer -> Address [1:1] (aggregation)

# One-to-Many Relationships
User -> Order [1:M] (composition)
Category -> Product [1:M] (aggregation)
Order -> OrderItem [1:M] (composition)
Product -> ProductImage [1:M] (composition)

# Many-to-Many Relationships
User -> Role [M:N] (association) via UserRole
Product -> Tag [M:N] (association) via ProductTag
Order -> Coupon [M:N] (association) via OrderCoupon

# Inheritance Relationships
User -> Customer [inheritance]
User -> Admin [inheritance]
PaymentMethod -> CreditCard [inheritance]
PaymentMethod -> PayPal [inheritance]

# Composition Relationships
Order -> OrderItem [composition] // OrderItem cannot exist without Order
Invoice -> LineItem [composition] // LineItem lifecycle controlled by Invoice
ShoppingCart -> CartItem [composition] // CartItem deleted when cart is cleared

# Aggregation Relationships
Category -> Product [aggregation] // Product can exist without Category
Department -> Employee [aggregation] // Employee can exist without Department
Warehouse -> Product [aggregation] // Product can exist in multiple warehouses

=== DATABASE SCHEMA ===
+ User Management
+ Product Catalog
+ Order Management
+ Payment Processing

=== User Management ====
User
==========
* _id             : UUID                      [PK]
* ! username      : String(50)               [UK,IX]
* ! email         : String(100)              [UK,IX]
@ password_hash   : String(255)              [ENCRYPTED]
* first_name      : String(50)               
* last_name       : String(50)               
* is_active       : Boolean                  [DEFAULT:true]
- created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]
- updated_at      : DateTime                 [SYSTEM]

UserProfile
/=======/
* _id             : UUID                      [PK]
* user_id         : UUID                      [FK:User._id]
- bio             : Text                      
- avatar_url      : String(500)              
- date_of_birth   : Date                      
- phone           : String(20)               
- preferences     : JSON                      {
    theme: String,
    notifications: Boolean,
    language: String
}
- created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]

Customer
==========
* _id             : UUID                      [PK]
* user_id         : UUID                      [FK:User._id]
- loyalty_points  : Int                       [DEFAULT:0]
- customer_since  : DateTime                 [SYSTEM,DEFAULT:NOW()]
- preferred_payment_method : String          

Address
/=======/
* _id             : UUID                      [PK]
* customer_id     : UUID                      [FK:Customer._id]
* street          : String(255)              
* city            : String(100)              
* state           : String(50)               
* zip_code        : String(20)               
* country         : String(2)                [DEFAULT:'US']
* address_type    : Enum(billing,shipping,both) [DEFAULT:'both']

=== Product Catalog ====
Category
==========
* _id             : UUID                      [PK]
* name            : String(100)              [UK]
* description     : Text                      
- parent_category_id : UUID                  [FK:Category._id]
* is_active       : Boolean                  [DEFAULT:true]
- created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]

Product
==========
* _id             : UUID                      [PK]
* ! sku           : String(50)               [UK,IX]
* name            : String(200)              [IX]
* description     : Text                      
* price           : Decimal(10,2)            [CK:price > 0]
- category_id     : UUID                      [FK:Category._id]
* inventory_count : Int                       [DEFAULT:0]
* is_active       : Boolean                  [DEFAULT:true]
- created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]
- updated_at      : DateTime                 [SYSTEM]

ProductImage
/=======/
* _id             : UUID                      [PK]
* product_id      : UUID                      [FK:Product._id]
* image_url       : String(500)              
* alt_text        : String(255)              
* display_order   : Int                       [DEFAULT:0]
* is_primary      : Boolean                  [DEFAULT:false]

Tag
==========
* _id             : UUID                      [PK]
* name            : String(50)               [UK]
* color           : String(7)                [DEFAULT:'#000000']
- created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]

ProductTag
/=======/
* _id             : UUID                      [PK]
* product_id      : UUID                      [FK:Product._id]
* tag_id          : UUID                      [FK:Tag._id]
- created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]

=== Order Management ====
Order
==========
* _id             : UUID                      [PK]
* ! order_number  : String(20)               [UK,IX]
* customer_id     : UUID                      [FK:Customer._id]
* status          : Enum(pending,processing,shipped,delivered,cancelled) [DEFAULT:'pending']
* subtotal        : Decimal(10,2)            [CK:subtotal >= 0]
* tax_amount      : Decimal(10,2)            [CK:tax_amount >= 0]
* shipping_amount : Decimal(10,2)            [CK:shipping_amount >= 0]
* total_amount    : Decimal(10,2)            [COMPUTED:subtotal + tax_amount + shipping_amount]
* @ order_date    : DateTime                 [SYSTEM,DEFAULT:NOW()]
- shipped_date    : DateTime                 
- delivered_date  : DateTime                 

OrderItem
/=======/
* _id             : UUID                      [PK]
* order_id        : UUID                      [FK:Order._id]
* product_id      : UUID                      [FK:Product._id]
* quantity        : Int                       [CK:quantity > 0]
* unit_price      : Decimal(10,2)            [CK:unit_price > 0]
* total_price     : Decimal(10,2)            [COMPUTED:quantity * unit_price]

ShoppingCart
==========
* _id             : UUID                      [PK]
* customer_id     : UUID                      [FK:Customer._id]
- session_id      : String(255)              
* created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]
* updated_at      : DateTime                 [SYSTEM]

CartItem
/=======/
* _id             : UUID                      [PK]
* cart_id         : UUID                      [FK:ShoppingCart._id]
* product_id      : UUID                      [FK:Product._id]
* quantity        : Int                       [CK:quantity > 0]
* added_at        : DateTime                 [SYSTEM,DEFAULT:NOW()]

=== Payment Processing ====
PaymentMethod
==========
* _id             : UUID                      [PK]
* customer_id     : UUID                      [FK:Customer._id]
* method_type     : Enum(credit_card,paypal,bank_transfer)
* is_default      : Boolean                  [DEFAULT:false]
* is_active       : Boolean                  [DEFAULT:true]
- created_at      : DateTime                 [SYSTEM,DEFAULT:NOW()]

CreditCard
/=======/
* _id             : UUID                      [PK]
* payment_method_id : UUID                   [FK:PaymentMethod._id]
@ card_number     : String(20)               [ENCRYPTED]
@ expiry_month    : Int                       [ENCRYPTED]
@ expiry_year     : Int                       [ENCRYPTED]
@ cvv             : String(4)                [ENCRYPTED]
* cardholder_name : String(100)              
* card_type       : Enum(visa,mastercard,amex,discover)

PayPal
/=======/
* _id             : UUID                      [PK]
* payment_method_id : UUID                   [FK:PaymentMethod._id]
@ paypal_email    : String(255)              [ENCRYPTED]
@ paypal_id       : String(50)               [ENCRYPTED]

Payment
==========
* _id             : UUID                      [PK]
* order_id        : UUID                      [FK:Order._id]
* payment_method_id : UUID                   [FK:PaymentMethod._id]
* amount          : Decimal(10,2)            [CK:amount > 0]
* status          : Enum(pending,processing,completed,failed,refunded) [DEFAULT:'pending']
* ! transaction_id : String(100)             [UK,IX]
* payment_date    : DateTime                 [SYSTEM,DEFAULT:NOW()]
- processed_date  : DateTime                 
* currency        : String(3)                [DEFAULT:'USD']

# RELATIONSHIPS
@ relationships:: User Management module contains core user entities
## User.id -> UserProfile.user_id (1:1 composition)
## User.id -> Customer.user_id (1:1 inheritance)
## Customer.id -> Address.customer_id (1:1 aggregation)

@ relationships:: Product Catalog manages product information
## Category.id -> Product.category_id (1:M aggregation)
## Product.id -> ProductImage.product_id (1:M composition)
## Product.id -> ProductTag.product_id (M:N association via ProductTag)
## Tag.id -> ProductTag.tag_id (M:N association via ProductTag)

@ relationships:: Order Management handles purchase transactions
## Customer.id -> Order.customer_id (1:M composition)
## Order.id -> OrderItem.order_id (1:M composition)
## Product.id -> OrderItem.product_id (1:M aggregation)
## Customer.id -> ShoppingCart.customer_id (1:1 composition)
## ShoppingCart.id -> CartItem.cart_id (1:M composition)

@ relationships:: Payment Processing manages financial transactions
## Customer.id -> PaymentMethod.customer_id (1:M aggregation)
## PaymentMethod.id -> CreditCard.payment_method_id (1:1 inheritance)
## PaymentMethod.id -> PayPal.payment_method_id (1:1 inheritance)
## Order.id -> Payment.order_id (1:M composition)
## PaymentMethod.id -> Payment.payment_method_id (1:M aggregation)
#
```

## What This Example Demonstrates

1. **Global Relationships Overview**: The relationships definition section provides a parsable summary of all entity relationships
2. **Relationship Types**: Shows different cardinalities (1:1, 1:M, M:N) and natures (composition, aggregation, association, inheritance)
3. **Junction Tables**: M:N relationships specify their junction tables using the `via` keyword
4. **Inheritance**: Both composition and inheritance relationships are clearly documented
5. **Lifecycle Dependencies**: Composition relationships indicate parent-child lifecycle dependencies
6. **Parsable Format**: The syntax is designed to be easily parsed by automated tools

## Benefits of the Relationships Definition Section

1. **Complete Overview**: Provides a comprehensive view of all entity relationships in one place
2. **Parsable Format**: Machine-readable syntax enables automated processing and validation
3. **Relationship Classification**: Clearly distinguishes between composition, aggregation, and association
4. **Junction Table Documentation**: M:N relationships explicitly document their junction tables
5. **Inheritance Modeling**: Supports both inheritance and composition patterns
6. **Lifecycle Management**: Composition relationships indicate cascade delete behaviors
7. **Cross-Reference Validation**: Enables validation that relationship definitions match entity definitions

## Usage in AI Systems

AI systems can use this section to:
- Generate ERD diagrams automatically
- Validate relationship consistency
- Create database migration scripts
- Generate API documentation
- Build ORM model relationships
- Identify potential performance issues
- Plan database optimization strategies

## Relationship Types Explained

### Composition Relationships
- Child entities cannot exist without their parent
- When parent is deleted, children are automatically deleted (cascade delete)
- Example: `Order -> OrderItem [composition]` - OrderItems cannot exist without an Order

### Aggregation Relationships
- Child entities can exist independently of their parent
- When parent is deleted, children remain (no cascade delete)
- Example: `Category -> Product [aggregation]` - Products can exist without a Category

### Association Relationships
- Loose coupling between entities, typically many-to-many
- Often implemented through junction tables
- Example: `User -> Role [M:N] (association) via UserRole`

### Inheritance Relationships
- IS-A relationship where child entity inherits from parent
- Child entities share attributes/behavior with parent
- Example: `PaymentMethod -> CreditCard [inheritance]` - CreditCard IS-A PaymentMethod

## Parsing Rules for Tools

When parsing the relationships definition section, tools should:

1. **Section Identification**: Look for `=== RELATIONSHIP DEFINITIONS ===` header
2. **Comment Parsing**: Lines starting with `#` are section headers/comments
3. **Relationship Syntax**: `Entity -> Entity [cardinality] (nature) via JunctionEntity`
4. **Cardinality Values**: `1:1`, `1:M`, `M:N`, `inheritance`, `composition`, `aggregation`
5. **Nature Values**: `composition`, `aggregation`, `association`, `inheritance`, `dependency`
6. **Junction Tables**: Optional `via EntityName` for M:N relationships
7. **Inline Comments**: Lines can end with `//` comments for additional context

## Validation Rules

1. **Syntax Validation**: Each relationship line must follow the defined pattern
2. **Entity Existence**: Referenced entities must exist in the schema definition
3. **Cardinality Consistency**: Relationship cardinality should match entity field definitions
4. **Junction Table Validation**: For M:N relationships, the junction table should exist
5. **Inheritance Validation**: Inheritance relationships should have proper parent-child structure
6. **Lifecycle Consistency**: Composition relationships should have matching cascade behaviors 