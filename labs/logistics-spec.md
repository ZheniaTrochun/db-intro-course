# Logistics Database Specification

## Overview
This document specifies the design of a logistics management system database.

## System Requirements
- Track suppliers and their information
- Manage supply orders and order items
- Maintain product catalog
- Track warehouse locations and capacity
- Record inventory movements between locations

## Database Tables

### SUPPLIER
- Stores information about supply sources
- Fields: ID, company name, contact person, phone, email, address

### SUPPLY_ORDER
- Tracks purchase orders from suppliers
- Fields: ID, order number, supplier ID, supply date, total cost, status

### SUPPLY_ITEM
- Individual items within supply orders
- Fields: ID, supply order ID, product ID, location ID, quantity, unit price

### PRODUCT
- Product catalog and specifications
- Fields: ID, SKU code, name, description, unit type, minimum stock level

### WAREHOUSE_LOCATION
- Physical warehouse locations
- Fields: ID, location code, zone, shelf number, maximum capacity

### INVENTORY_MOVEMENT
- Tracks all product movements
- Fields: ID, product ID, from location, to location, quantity, date

## Constraints
- UUID primary keys for main entities
- Unique constraints on critical fields
- Foreign key relationships for referential integrity
- Enum types for status and unit fields
