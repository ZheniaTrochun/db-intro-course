-- Logistics Database Schema
-- Author: Antonyk Georgiy, Benedyk Yaroslav, Prasol Maksym - IM-55

-- Create SUPPLIER table
CREATE TABLE SUPPLIER (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL,
    contact_person TEXT NOT NULL,
    phone TEXT,
    email TEXT UNIQUE NOT NULL,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create PRODUCT table
CREATE TABLE PRODUCT (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    unit VARCHAR(50) CHECK (unit IN ('piece', 'kg', 'liter', 'box', 'pallet')),
    min_stock_level INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create WAREHOUSE_LOCATION table
CREATE TABLE WAREHOUSE_LOCATION (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_code VARCHAR(50) UNIQUE NOT NULL,
    zone VARCHAR(50),
    shelf_number VARCHAR(50),
    max_capacity INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create SUPPLY_ORDER table
CREATE TABLE SUPPLY_ORDER (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number TEXT UNIQUE NOT NULL,
    supplier_id UUID NOT NULL REFERENCES SUPPLIER(id) ON DELETE RESTRICT,
    supply_date TIMESTAMP NOT NULL,
    total_cost NUMERIC(12, 2),
    status VARCHAR(50) CHECK (status IN ('draft', 'received', 'cancelled')) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create SUPPLY_ITEM table
CREATE TABLE SUPPLY_ITEM (
    id BIGSERIAL PRIMARY KEY,
    supply_id UUID NOT NULL REFERENCES SUPPLY_ORDER(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES PRODUCT(id) ON DELETE RESTRICT,
    location_id UUID NOT NULL REFERENCES WAREHOUSE_LOCATION(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create INVENTORY_MOVEMENT table
CREATE TABLE INVENTORY_MOVEMENT (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES PRODUCT(id) ON DELETE RESTRICT,
    from_location_id UUID REFERENCES WAREHOUSE_LOCATION(id) ON DELETE SET NULL,
    to_location_id UUID NOT NULL REFERENCES WAREHOUSE_LOCATION(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    movement_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_supply_order_supplier ON SUPPLY_ORDER(supplier_id);
CREATE INDEX idx_supply_order_status ON SUPPLY_ORDER(status);
CREATE INDEX idx_supply_item_supply ON SUPPLY_ITEM(supply_id);
CREATE INDEX idx_supply_item_product ON SUPPLY_ITEM(product_id);
CREATE INDEX idx_supply_item_location ON SUPPLY_ITEM(location_id);
CREATE INDEX idx_inventory_product ON INVENTORY_MOVEMENT(product_id);
CREATE INDEX idx_inventory_from_location ON INVENTORY_MOVEMENT(from_location_id);
CREATE INDEX idx_inventory_to_location ON INVENTORY_MOVEMENT(to_location_id);
CREATE INDEX idx_inventory_date ON INVENTORY_MOVEMENT(movement_date);
