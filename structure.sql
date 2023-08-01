drop database if exists transactions ;
create database transactions;

GRANT ALL PRIVILEGES ON transactions.* TO 'cube'@'%' WITH GRANT OPTION;

begin;
-- drop schema if exists public cascade;
create schema if not exists public;
-- set search_path to public;

use transactions;

create table if not exists tenants (
  tenant_id INT AUTO_INCREMENT PRIMARY KEY,
  name text
);

create table if not exists vendors (
  tenant_id INT not null references tenants,
  vendor_id INT AUTO_INCREMENT PRIMARY KEY,
  name text,
  credit_limit DECIMAL,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table if not exists orders (
  tenant_id INT not null,
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id INT references vendors,
  title text,
  budgeted_amount DECIMAL,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table if not exists orders_status (
  record_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  status text,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table if not exists line_items (
  tenant_id INT not null,
  line_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT references orders,
  title text,
  cost DECIMAL,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
commit;

begin;

INSERT IGNORE INTO tenants (tenant_id, name) values
(1, 'A'),
(2, 'B')
;

INSERT IGNORE INTO vendors (tenant_id,vendor_id, name, credit_limit) values
(1, 1, 'Acme', 10230),
(1, 2, 'National', 456.12)  -- this vendor will have no orders
,(1,3, 'Empty', 101.01)
;

INSERT IGNORE INTO orders (tenant_id, order_id, vendor_id, title, budgeted_amount) values
  (1,1,1,'$100 order w/3li', 100.00)
, (1,2,1,'$200 order w/1li', 200.00)
, (1,3,1,'$302 order w/0li', 302.00)
, (1,4,3,'$404 order w/0li', 404.00)
;

INSERT IGNORE INTO line_items (tenant_id, line_item_id, order_id, title, cost) values
(1,1,1,'materials', 20.00),
(1,2,1,'lumber', 340.00),
(1,3,1,'labor', 100.00),
(1,4,2,'labor', 5000.00)
;

-- SCD type 2
INSERT IGNORE INTO orders_status(record_id, order_id, status) values
  (1, 1, 'PAYED')
, (2, 1, 'FULFILLED')
, (3, 2, 'CANCELLED')
, (4, 3, 'FULFILLED')
, (5, 4, 'FULFILLED')
, (6, 5, 'INVALID')
;

commit;


drop database if exists reporting ;
create database reporting;

GRANT ALL PRIVILEGES ON reporting.* TO 'cube'@'%' WITH GRANT OPTION;

begin;

USE reporting;

create schema if not exists public;
set search_path to public;

create table if not exists tenants (
  tenant_id INT AUTO_INCREMENT PRIMARY KEY,
  name text
);

create table if not exists vendors (
  tenant_id INT not null references tenants,
  vendor_id INT AUTO_INCREMENT PRIMARY KEY,
  name text,
  credit_limit DECIMAL,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table if not exists orders (
  tenant_id INT not null,
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id INT references vendors,
  title text,
  budgeted_amount DECIMAL,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table if not exists line_items (
  tenant_id INT not null,
  line_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT references orders,
  title text,
  cost DECIMAL,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

create table if not exists orders_status (
  record_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT references orders,
  status text,
  _updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

commit;

begin;

INSERT IGNORE INTO tenants (tenant_id, name) values
(1, 'A'),
(2, 'B')
;

INSERT IGNORE INTO vendors (tenant_id,vendor_id, name, credit_limit) values
  (1, 1, 'Acme', 10230)
, (1, 2, 'National', 456.12)  -- this vendor will have no orders
, (1, 3, 'Empty', 101.01)
, (2, 4, 'New Vendor', 2000.00)
;

INSERT IGNORE INTO orders (tenant_id, order_id, vendor_id, title, budgeted_amount) values
  (1,1,1,'$100 order w/3li', 100.00)
, (1,2,1,'$200 order w/1li', 200.00)
, (1,3,1,'$302 order w/0li', 302.00)
, (1,4,3,'$404 order w/0li', 404.00)
, (2,5,4,'$404 order w/0li', 404.00)
;

INSERT IGNORE INTO line_items (tenant_id, line_item_id, order_id, title, cost) values
  (1,1,1,'materials', 20.00)
, (1,2,1,'lumber', 340.00)
, (1,3,1,'labor', 100.00)
, (1,4,2,'labor', 5000.00)
, (2,5,5,'labor', 404.00)
;

INSERT IGNORE INTO orders_status(order_id, status) values
  (1, 'FULFILLED')
, (2, 'CANCELLED')
, (3, 'FULFILLED')
, (4, 'FULFILLED')
, (5, 'INVALID')
;

commit;
