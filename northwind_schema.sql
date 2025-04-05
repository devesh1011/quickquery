-- northwind_schema.sql
-- Schema generated based on INSERT statements for SQLite
PRAGMA foreign_keys = OFF;

-- Turn off FKs during initial creation/population
-- customers Table
CREATE TABLE
    customers (
        id INTEGER PRIMARY KEY, -- Assuming auto-increment isn't strictly needed based on inserts
        company TEXT,
        last_name TEXT,
        first_name TEXT,
        email_address TEXT,
        job_title TEXT,
        business_phone TEXT,
        home_phone TEXT,
        mobile_phone TEXT,
        fax_number TEXT,
        address TEXT,
        city TEXT,
        state_province TEXT,
        zip_postal_code TEXT,
        country_region TEXT,
        web_page TEXT,
        notes TEXT,
        attachments BLOB -- Or TEXT if you know it's never binary
    );

-- privileges Table
CREATE TABLE
    privileges (id INTEGER PRIMARY KEY, privilege_name TEXT);

-- employees Table
CREATE TABLE
    employees (
        id INTEGER PRIMARY KEY,
        company TEXT,
        last_name TEXT,
        first_name TEXT,
        email_address TEXT,
        job_title TEXT,
        business_phone TEXT,
        home_phone TEXT,
        mobile_phone TEXT,
        fax_number TEXT,
        address TEXT,
        city TEXT,
        state_province TEXT,
        zip_postal_code TEXT,
        country_region TEXT,
        web_page TEXT,
        notes TEXT,
        attachments BLOB -- Or TEXT
    );

-- employee_privileges Table (Junction Table)
CREATE TABLE
    employee_privileges (
        employee_id INTEGER NOT NULL,
        privilege_id INTEGER NOT NULL,
        PRIMARY KEY (employee_id, privilege_id),
        FOREIGN KEY (employee_id) REFERENCES employees (id),
        FOREIGN KEY (privilege_id) REFERENCES privileges (id)
    );

-- inventory_transaction_types Table
CREATE TABLE
    inventory_transaction_types (id INTEGER PRIMARY KEY, type_name TEXT);

-- purchase_order_status Table
CREATE TABLE
    purchase_order_status (id INTEGER PRIMARY KEY, status TEXT);

-- suppliers Table
CREATE TABLE
    suppliers (
        id INTEGER PRIMARY KEY,
        company TEXT,
        last_name TEXT,
        first_name TEXT,
        email_address TEXT,
        job_title TEXT,
        business_phone TEXT,
        home_phone TEXT,
        mobile_phone TEXT,
        fax_number TEXT,
        address TEXT,
        city TEXT,
        state_province TEXT,
        zip_postal_code TEXT,
        country_region TEXT,
        web_page TEXT,
        notes TEXT,
        attachments BLOB -- Or TEXT
    );

-- purchase_orders Table
CREATE TABLE
    purchase_orders (
        id INTEGER PRIMARY KEY,
        supplier_id INTEGER,
        created_by INTEGER, -- Refers to employees.id
        submitted_date TEXT, -- Storing dates as TEXT for simplicity with ISO format
        creation_date TEXT,
        status_id INTEGER, -- Refers to purchase_order_status.id
        expected_date TEXT,
        shipping_fee NUMERIC DEFAULT 0,
        taxes NUMERIC DEFAULT 0,
        payment_date TEXT,
        payment_amount NUMERIC DEFAULT 0,
        payment_method TEXT,
        notes TEXT,
        approved_by INTEGER, -- Refers to employees.id
        approved_date TEXT,
        submitted_by INTEGER, -- Refers to employees.id
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
        FOREIGN KEY (created_by) REFERENCES employees (id),
        FOREIGN KEY (status_id) REFERENCES purchase_order_status (id),
        FOREIGN KEY (approved_by) REFERENCES employees (id),
        FOREIGN KEY (submitted_by) REFERENCES employees (id)
    );

-- products Table
CREATE TABLE
    products (
        supplier_ids TEXT, -- Storing list as TEXT
        id INTEGER PRIMARY KEY,
        product_code TEXT,
        product_name TEXT,
        description TEXT,
        standard_cost NUMERIC,
        list_price NUMERIC,
        reorder_level INTEGER,
        target_level INTEGER,
        quantity_per_unit TEXT,
        discontinued INTEGER, -- 0 or 1, so INTEGER
        minimum_reorder_quantity INTEGER,
        category TEXT,
        attachments BLOB -- Or TEXT
    );

-- inventory_transactions Table
CREATE TABLE
    inventory_transactions (
        id INTEGER PRIMARY KEY,
        transaction_type INTEGER NOT NULL, -- Refers to inventory_transaction_types.id
        transaction_created_date TEXT,
        transaction_modified_date TEXT,
        product_id INTEGER,
        quantity INTEGER,
        purchase_order_id INTEGER,
        customer_order_id INTEGER, -- Needs orders table
        comments TEXT,
        FOREIGN KEY (transaction_type) REFERENCES inventory_transaction_types (id),
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id)
        -- FOREIGN KEY (customer_order_id) REFERENCES orders (id) -- Add later when orders table exists
    );

-- purchase_order_details Table
CREATE TABLE
    purchase_order_details (
        id INTEGER PRIMARY KEY,
        purchase_order_id INTEGER,
        product_id INTEGER,
        quantity NUMERIC, -- Can be fractional in purchasing sometimes
        unit_cost NUMERIC,
        date_received TEXT,
        posted_to_inventory INTEGER, -- 0 or 1
        inventory_id INTEGER, -- Refers to inventory_transactions.id
        FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (inventory_id) REFERENCES inventory_transactions (id)
    );

-- orders_status Table
CREATE TABLE
    orders_status (id INTEGER PRIMARY KEY, status_name TEXT);

-- orders_tax_status Table
CREATE TABLE
    orders_tax_status (id INTEGER PRIMARY KEY, tax_status_name TEXT);

-- shippers Table
CREATE TABLE
    shippers (
        id INTEGER PRIMARY KEY,
        company TEXT,
        last_name TEXT,
        first_name TEXT,
        email_address TEXT,
        job_title TEXT,
        business_phone TEXT,
        home_phone TEXT,
        mobile_phone TEXT,
        fax_number TEXT,
        address TEXT,
        city TEXT,
        state_province TEXT,
        zip_postal_code TEXT,
        country_region TEXT,
        web_page TEXT,
        notes TEXT,
        attachments BLOB -- Or TEXT
    );

-- orders Table
CREATE TABLE
    orders (
        id INTEGER PRIMARY KEY,
        employee_id INTEGER,
        customer_id INTEGER,
        order_date TEXT,
        shipped_date TEXT,
        shipper_id INTEGER,
        ship_name TEXT,
        ship_address TEXT,
        ship_city TEXT,
        ship_state_province TEXT,
        ship_zip_postal_code TEXT,
        ship_country_region TEXT,
        shipping_fee NUMERIC DEFAULT 0,
        taxes NUMERIC DEFAULT 0,
        payment_type TEXT,
        paid_date TEXT,
        notes TEXT,
        tax_rate NUMERIC DEFAULT 0,
        tax_status_id INTEGER, -- Refers to orders_tax_status.id
        status_id INTEGER, -- Refers to orders_status.id
        FOREIGN KEY (employee_id) REFERENCES employees (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id),
        FOREIGN KEY (shipper_id) REFERENCES shippers (id),
        FOREIGN KEY (tax_status_id) REFERENCES orders_tax_status (id),
        FOREIGN KEY (status_id) REFERENCES orders_status (id)
    );

-- Add missing FK constraint to inventory_transactions now that 'orders' table exists
ALTER TABLE inventory_transactions
ADD COLUMN temp_customer_order_id INTEGER;

UPDATE inventory_transactions
SET
    temp_customer_order_id = customer_order_id;

ALTER TABLE inventory_transactions
DROP COLUMN customer_order_id;

ALTER TABLE inventory_transactions
RENAME COLUMN temp_customer_order_id TO customer_order_id;

-- Note: Recreating the table is often easier in SQLite to add FKs after the fact
-- If the above ALTERs fail, you might need a more complex migration or skip this FK.
-- A simpler approach during creation is to define inventory_transactions *after* orders.
-- order_details_status Table
CREATE TABLE
    order_details_status (id INTEGER PRIMARY KEY, status_name TEXT);

-- order_details Table
CREATE TABLE
    order_details (
        id INTEGER PRIMARY KEY,
        order_id INTEGER NOT NULL,
        product_id INTEGER,
        quantity NUMERIC NOT NULL DEFAULT 0,
        unit_price NUMERIC DEFAULT 0,
        discount NUMERIC NOT NULL DEFAULT 0,
        status_id INTEGER, -- Refers to order_details_status.id
        date_allocated TEXT,
        purchase_order_id INTEGER,
        inventory_id INTEGER, -- Refers to inventory_transactions.id
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (status_id) REFERENCES order_details_status (id),
        FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
        FOREIGN KEY (inventory_id) REFERENCES inventory_transactions (id)
    );

-- invoices Table
CREATE TABLE
    invoices (
        id INTEGER PRIMARY KEY,
        order_id INTEGER,
        invoice_date TEXT,
        due_date TEXT,
        tax NUMERIC DEFAULT 0,
        shipping NUMERIC DEFAULT 0,
        amount_due NUMERIC DEFAULT 0,
        FOREIGN KEY (order_id) REFERENCES orders (id)
    );

-- sales_reports Table (Seems like metadata)
CREATE TABLE
    sales_reports (
        group_by TEXT PRIMARY KEY, -- Assuming this is unique identifier
        display TEXT,
        title TEXT,
        filter_row_source TEXT,
        default_report INTEGER -- Renamed 'default' as it's a keyword
    );

-- strings Table (Utility table)
CREATE TABLE
    strings (string_id INTEGER PRIMARY KEY, string_data TEXT);

-- Re-enable Foreign Key checks if they were turned off (optional, good practice)
PRAGMA foreign_keys = ON;