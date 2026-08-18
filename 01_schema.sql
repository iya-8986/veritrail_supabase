/*========================MASTER TABLES========================*/

CREATE TABLE activity_log (
  activity_id SERIAL PRIMARY KEY,                    -- types: started delivery, request management, submitted dispute, etc. 
  activity_type VARCHAR(100) NOT NULL
);

CREATE TABLE attachment_type (                        -- types: PDF, DOCS,CSV
  attachment_type_id SERIAL PRIMARY KEY,
  attachment_type VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE audit_status (                          --types: success, in progress, completed, failed, cancelled
  audit_status_id SERIAL PRIMARY KEY,
  audit_status VARCHAR(20) NOT NULL
);

CREATE TABLE categories (                            --categories: Electronics, Home & Living, 
  category_id SERIAL PRIMARY KEY,                    -- Apparel, Sports, Stationery, 
  category_name VARCHAR(100) UNIQUE NOT NULL,         --Documents and Records
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE components (
  component_id SERIAL PRIMARY KEY, 
  component_name VARCHAR(50) NOT NULL
);

CREATE TABLE delivery_type(                         --type: internal, third-party 
  delivery_type_id SERIAL PRIMARY KEY,
  delivery_type VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE database_status (
  data_status_id SERIAL PRIMARY KEY,            --types: success, failed, running, recovered
  database_status VARCHAR(20) NOT NULL
);

CREATE TABLE departments (                       -- Administration, Human Resources, Finance
  department_id SERIAL PRIMARY KEY,              --Information Technology, Accounting, Warehouse
  department_name VARCHAR(50) UNIQUE NOT NULL    --Procurement, Operations, Maintenance, Sales
);                                               --Marketing

CREATE TABLE delivery_status (
  delivery_status_id SERIAL PRIMARY KEY,
  delivery_status VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE dispute_status (                    --Open, In Discussion, Escalated, Resolved, 
  status_id SERIAL PRIMARY KEY,                  --Closed
  status_name VARCHAR(20) NOT NULL
);

CREATE TABLE dispute_types (               --Damaged Item, Missing Item, Lost Package,
  dispute_type_id SERIAL PRIMARY KEY,      --Delayed Delivery, Wrong Delivery, Tampered Package
  dispute_type VARCHAR(50) NOT NULL        --Incorrect Shipment, Chain of Custody Issue, Other
);

CREATE TABLE events (                      --
  event_id SERIAL PRIMARY KEY,
  event_name VARCHAR(100) NOT NULL
);

CREATE TABLE incident_types (
  incident_type_id SERIAL PRIMARY KEY,
  incident_type VARCHAR(50) UNIQUE NOT NULL
);



CREATE TABLE issue_description (
  issue_id SERIAL PRIMARY KEY,      --forgot password, account locked, wrong permissions / roles
  issue_type VARCHAR(50) NOT NULL
);

CREATE TABLE issue_status (
  issue_status_id SERIAL PRIMARY KEY,
  issue_status VARCHAR(100) NOT NULL
);

CREATE TABLE notification_types (
  notification_type_id SERIAL PRIMARY KEY,
  type_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE offices (
  office_id SERIAL PRIMARY KEY,
  office_name VARCHAR (100) UNIQUE NOT NULL,
  office_code VARCHAR(20) UNIQUE,
  address TEXT,
  contact_number VARCHAR(20),
  email VARCHAR(255),
  status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE packaging (                       --No Preference (let Handler decide), Box,
  packaging_preference_id SERIAL PRIMARY KEY,  --Bubble Wrap with Box, Bubble Wrap, Plastic Bag,
  packaging_type VARCHAR(50) UNIQUE NOT NULL   --Envelope
);

CREATE TABLE priority (                        --low, normal, high, critical
  priority_id SERIAL PRIMARY KEY,
  priority_category VARCHAR(100) NOT NULL
);

CREATE TABLE quality_control_result (
  quality_control_result_id SERIAL PRIMARY KEY,
  result_name VARCHAR(20) UNIQUE NOT NULL
);


CREATE TABLE request_pipeline(                  --Submitted, Approved, Inventory Collection,
  pipeline_id SERIAL PRIMARY KEY,               --Quality Control, Packing, Ready to Ship,
  pipeline_name VARCHAR(50) UNIQUE NOT NULL,    --In Transit, Arrived, Pending Inspection, 
  pipeline_order INT UNIQUE NOT NULL            --Completed
);

CREATE TABLE roles (                                --Administrator, IT Administration, Requester
  role_id SERIAL PRIMARY KEY,                       --Messenger, Handler, Receiver
  role_name VARCHAR(20) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE severity (                      --types: info, warning, error, critical
  severity_id SERIAL PRIMARY KEY,
  severity VARCHAR(20) NOT NULL
);



CREATE TABLE system_status (
  system_status_id SERIAL PRIMARY KEY,
  system_status VARCHAR (200) NOT NULL
);

CREATE TABLE units(                                 --box, piece/s, 
  unit_id SERIAL PRIMARY KEY,
  unit_name VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE incident_status (
  incident_status_id SERIAL PRIMARY KEY,
  status_name VARCHAR(30) UNIQUE NOT NULL
);


/*
========================EMPLOYEE MODULE========================
+++Employee Module stores the employees' personal information such as name, department id, and employee id (given by the company), veritrail system credentials (user_id, password, username), user roles
+++ table: employees - stores employee personal information
+++ table: users - veritrail user credentials
+++ table: user roles - determines the role of the user
                      - connects the users table and user_roles table through user_id and role_id
*/

CREATE TABLE employees (                                
  employee_id VARCHAR(20) PRIMARY KEY, 
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL, 
  middle_name VARCHAR(50),
  department_id INT NOT NULL,
  office_id INT,
  employment_status VARCHAR(20) DEFAULT 'Active',
  contact_number VARCHAR(20),
  email VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE RESTRICT,
  
  FOREIGN KEY (office_id)
    REFERENCES offices (office_id)
    ON DELETE RESTRICT
);

CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  employee_id VARCHAR(20) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id)
    ON DELETE RESTRICT
);

CREATE TABLE user_roles (
  user_role_id SERIAL PRIMARY KEY,

  user_id INT NOT NULL, 
  role_id INT NOT NULL,

  FOREIGN KEY (role_id)
    REFERENCES roles(role_id)
    ON DELETE RESTRICT,
  
  FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,
  
  UNIQUE (user_id, role_id)
);



/*
========================WAREHOUSE MODULE-========================
+++ Warehouse Module stores inventory related information
+++ table: warehouse_inventory - stores the product name, its stock keeping unit (SKU), quantity, category, and reorder (number of times the user requested products)
+++ table: suppliers - tracks the supplier information of the products
                     - NOTE!! a product can have multiple suppliers
+++ table:  inventory_suppliers - connects the inventory table and suppliers 
+++ table: assets - tracks individual items 

      assets vs warehouse_inventory 
        warehouse_inventory sample - overall description of products
          -----------------------------------------------------
          |inventory_id  | product_name |   SKU    | Quantity |
          -----------------------------------------------------
          |      1       |   Laptop     | LAP-001  |    10    |
          |      2       |  Projector   | PROJ-001 |     5    |
          |      3       |  HDMI Cable  | HDMO-001 |    50    |
          -----------------------------------------------------

        assets sample - describes individual product in inventory
          ---------------------------------------------------------------
          |  asset_id    |   asset_tag  |    inventory_id    |  status   |
          ---------------------------------------------------------------
          |      1       |   LAP-0001   |        1           | Available |
          |      2       |   LAP-0002   |        1           | Available |
          |      3       |  PROJ-0001   |        2           |  In Use   |
          ----------------------------------------------------------------

*/
CREATE TABLE warehouse_inventory (
  inventory_id SERIAL PRIMARY KEY, 
  product_name VARCHAR(100) NOT NULL, 
  sku VARCHAR(30) UNIQUE NOT NULL, 
  quantity_on_hand INT NOT NULL CHECK (quantity_on_hand >= 0),
  category_id INT NOT NULL, 
  reorder_level INT DEFAULT 0,
    CHECK (reorder_level >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


  FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
    ON DELETE RESTRICT
);

CREATE TABLE assets (
  asset_id SERIAL PRIMARY KEY,

  asset_tag VARCHAR(30) UNIQUE NOT NULL,

  inventory_id INT NOT NULL,

  office_id INT,

  status VARCHAR(20) NOT NULL DEFAULT 'Available'
    CHECK (status IN (
      'Available',
      'Reserved',
      'In Use',
      'In Transit',
      'Quarantined',
      'Under Maintenance',
      'Damaged',
      'Retired'
    )),

  condition_notes TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE (asset_id, inventory_id),

  FOREIGN KEY (inventory_id)
    REFERENCES warehouse_inventory(inventory_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (office_id)
    REFERENCES offices(office_id)
    ON DELETE RESTRICT
);


CREATE TABLE suppliers (
  supplier_id SERIAL PRIMARY KEY,
  company_name VARCHAR(100) UNIQUE NOT NULL, 
  contact_person VARCHAR(50) NOT NULL,
  contact_number VARCHAR(20) NOT NULL, 
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory_suppliers (
  inventory_supplier_id SERIAL PRIMARY KEY, 
  inventory_id INT NOT NULL, 
  supplier_id INT NOT NULL, 

  FOREIGN KEY (inventory_id)
    REFERENCES warehouse_inventory(inventory_id)
    ON DELETE CASCADE,
  
  FOREIGN KEY (supplier_id)
    REFERENCES suppliers(supplier_id)
    ON DELETE CASCADE,
  
  UNIQUE (inventory_id, supplier_id)
);



/*
========================REQUEST MODULE========================
+++ Request Module stores information about the requests for products
+++ table: requests - main table of this module. 
                    - houses the most relevant information about the request
+++ table: request_items - items requested by the requester (quantity, product) connected to the inventory
+++ table: request_tracking - determines the chain of custody of the product (when, where, who handled the package)
+++ table: request_tracking_attachments - files uploaded in the system per request
*/


CREATE TABLE requests (
  request_id SERIAL PRIMARY KEY, 
  request_number VARCHAR(20) UNIQUE NOT NULL, 

  parent_request_id INT,
  requester_id INT NOT NULL, 
  pipeline_id INT NOT NULL, 
  packaging_preference_id INT, 
  priority_id INT NOT NULL,
  source_office_id INT NOT NULL,
  destination_office_id INT NOT NULL,
  receiver_id VARCHAR(20),
  recipient_name VARCHAR(50) NOT NULL, 
  delivery_address VARCHAR(100) NOT NULL,
  business_purpose TEXT NOT NULL,

  qc_acknowledgement BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (packaging_preference_id)
    REFERENCES packaging (packaging_preference_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (parent_request_id)
    REFERENCES requests(request_id)
    ON DELETE SET NULL,

  FOREIGN KEY (pipeline_id)
    REFERENCES request_pipeline (pipeline_id)
    ON DELETE RESTRICT, 

  FOREIGN KEY (receiver_id)
    REFERENCES employees (employee_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (requester_id)
    REFERENCES users(user_id)
    ON DELETE RESTRICT,
  
  FOREIGN KEY (priority_id)
    REFERENCES priority (priority_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (source_office_id)
    REFERENCES offices (office_id)
    ON DELETE RESTRICT,
  
  FOREIGN KEY (destination_office_id)
    REFERENCES offices (office_id)
    ON DELETE RESTRICT

);

CREATE TABLE request_items(
  request_item_id SERIAL PRIMARY KEY, 
  request_id INT NOT NULL, 
  inventory_id INT NOT NULL,
  asset_id INT,
  unit_id INT NOT NULL, 
  quantity_requested INT NOT NULL
    CHECK(quantity_requested > 0),

  UNIQUE (request_id, inventory_id),

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id)
    ON DELETE CASCADE, 

  FOREIGN KEY (inventory_id)
    REFERENCES warehouse_inventory (inventory_id)
    ON DELETE RESTRICT, 

  FOREIGN KEY (asset_id, inventory_id)
    REFERENCES assets (asset_id, inventory_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (unit_id)
    REFERENCES units (unit_id)
    ON DELETE RESTRICT
  
);


CREATE TABLE request_tracking (
  tracking_id SERIAL PRIMARY KEY,

  request_id INT NOT NULL, 
  pipeline_id INT NOT NULL, 

  handled_by VARCHAR(20) NOT NULL,

  remarks TEXT, 

  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,

  FOREIGN KEY (handled_by)
    REFERENCES employees(employee_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (pipeline_id)
    REFERENCES request_pipeline(pipeline_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (request_id)
    REFERENCES requests (request_id)
    ON DELETE CASCADE
);

CREATE TABLE request_attachments (
  attachment_id BIGSERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  attachment_type_id INT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  stored_file_name VARCHAR(255) NOT NULL,
  file_path TEXT NOT NULL,
  mime_type VARCHAR(100),
  file_size BIGINT,
  uploaded_by VARCHAR(20) NOT NULL,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id)
    ON DELETE CASCADE,

  FOREIGN KEY (attachment_type_id)
    REFERENCES attachment_type (attachment_type_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (uploaded_by)
    REFERENCES employees(employee_id)
    ON DELETE RESTRICT
);

CREATE TABLE request_history (
  history_id BIGSERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  performed_by VARCHAR(20) NOT NULL,
  action VARCHAR(100) NOT NULL,
  previous_pipeline_id INT,
  new_pipeline_id INT,
  remarks TEXT, 
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY (performed_by)
    REFERENCES employees (employee_id),

  FOREIGN KEY (previous_pipeline_id)
    REFERENCES request_pipeline (pipeline_id),

  FOREIGN KEY (new_pipeline_id)
    REFERENCES request_pipeline (pipeline_id)
);

CREATE TABLE request_assignments (
  assignment_id SERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  employee_id VARCHAR(20) NOT NULL,
  role_id INT NOT NULL,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id),

  FOREIGN KEY (role_id)
    REFERENCES roles(role_id)

);

CREATE TABLE request_timeline (
  timeline_id BIGSERIAL PRIMARY KEY,
  request_id INT,
  event_name VARCHAR(150),
  performed_by VARCHAR(20),
  event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  remarks TEXT,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY (performed_by)
    REFERENCES employees (employee_id)
);



/*==================================ASSET RESERVATION MODULE==================================
  Controls asset allocation to requests.
*/
CREATE TABLE asset_reservations (
  reservation_id BIGSERIAL PRIMARY KEY,
  asset_id INT NOT NULL,
  request_id INT NOT NULL,
  reserved_by VARCHAR(20) NOT NULL,
  reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  released_at TIMESTAMP,
  release_reason TEXT,

  status VARCHAR(20) NOT NULL DEFAULT 'Active'
    CHECK (status IN (
      'Active',
      'Released',
      'Completed',
      'Cancelled'
    )),

  FOREIGN KEY (asset_id)
    REFERENCES assets(asset_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (reserved_by)
    REFERENCES employees(employee_id)
    ON DELETE RESTRICT
);

CREATE UNIQUE INDEX uq_active_asset_reservation
ON asset_reservations(asset_id)
WHERE status = 'Active';

CREATE TABLE asset_reservation_history (
  reservation_history_id BIGSERIAL PRIMARY KEY,
  reservation_id BIGINT NOT NULL,
  action VARCHAR(50) NOT NULL,
  performed_by VARCHAR(20) NOT NULL,
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (reservation_id)
    REFERENCES asset_reservations(reservation_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (performed_by)
    REFERENCES employees(employee_id)
    ON DELETE RESTRICT
);


/*
========================CUSTODY MODULE========================
CUSTODY Module handles the custody of the delivery
+++table: custody_records - records every person who handled the package
+++table: active_custodian - records the current holder of the package
*/

CREATE TABLE custody_records (
  custody_id BIGSERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  asset_id INT NOT NULL,
  released_by VARCHAR(20),
  received_by VARCHAR(20),
  released_role INT,
  received_role INT, 
  transfer_location VARCHAR (255),
  asset_condition TEXT,
  remarks TEXT,
  transferred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 

  FOREIGN KEY (request_id)
    REFERENCES requests (request_id),

  FOREIGN KEY (asset_id)
    REFERENCES assets(asset_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (released_by)
    REFERENCES employees (employee_id),

  FOREIGN KEY (received_by)
    REFERENCES employees (employee_id),

  FOREIGN KEY (released_role)
    REFERENCES roles (role_id),

  FOREIGN KEY (received_role)
    REFERENCES roles (role_id)
);

CREATE TABLE active_custodian (
  request_id INT PRIMARY KEY,
  employee_id VARCHAR(20),
  role_id INT, 
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY (employee_id)
    REFERENCES employees (employee_id),

  FOREIGN KEY (role_id)
    REFERENCES roles (role_id)
);


/*
========================MESSENGER MODULE========================
Messenger Module stores the information for when the package is in the hands of the messenger
                   it ensures that everything that happen to the package is recorded while it is in transit
+++ table: deliveries - preliminary information about the messenger and its transaction
+++ table: internal_messenger - stores information only when the company utlize its own messengers to deliver the products
+++ table: third_party_courier - general detail is stored about the courier
+++ table: land_courier / water_courier / air - a more detail information about the third-party courier
*/

CREATE TABLE deliveries (
  delivery_id SERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  tracking_number VARCHAR(50) UNIQUE NOT NULL,
  
  delivery_type_id INT NOT NULL,
  sender_id INT NOT NULL,
  recipient_id INT NOT NULL,
  status_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (request_id)
    REFERENCES requests (request_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (status_id)
    REFERENCES delivery_status(delivery_status_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (delivery_type_id)
    REFERENCES delivery_type(delivery_type_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (sender_id)
    REFERENCES users(user_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (recipient_id)
    REFERENCES users(user_id)
    ON DELETE RESTRICT
);

CREATE TABLE internal_messenger (
  delivery_id INT PRIMARY KEY,
  messenger_user_id INT NOT NULL,
  pickup_latitude DECIMAL (9,6) NOT NULL,
  pickup_longitude DECIMAL (9,6) NOT NULL,
  dropoff_latitude DECIMAL (9,6) NOT NULL,
  dropoff_longitude DECIMAL (9,6) NOT NULL,
  time_pickup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  time_delivered TIMESTAMP,

  FOREIGN KEY (delivery_id)
    REFERENCES deliveries(delivery_id)
    ON DELETE RESTRICT,
  
  FOREIGN KEY (messenger_user_id)
    REFERENCES users(user_id)
    ON DELETE RESTRICT
);

CREATE TABLE internal_messenger_location (
  location_id BIGSERIAL PRIMARY KEY,
  delivery_id INT NOT NULL,
  latitude DECIMAL (9,6) NOT NULL,
  longitude DECIMAL (9,6) NOT NULL,
  accuracy DECIMAL (10,2) NOT NULL,
  speed DECIMAL (10,2) NOT NULL,
  heading VARCHAR(255),
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (delivery_id)
    REFERENCES deliveries (delivery_id)
    ON DELETE RESTRICT

);

CREATE TABLE courier_companies (
  courier_id SERIAL PRIMARY KEY,
  company_name VARCHAR(250) NOT NULL,
  email TEXT NOT NULL,
  contact_number VARCHAR(20)
);

CREATE TABLE third_party_courier (
  delivery_id INT PRIMARY KEY,
  courier_company_id INT NOT NULL,
  tracking_reference VARCHAR(100) NOT NULL,
  booking_reference VARCHAR(100),
  tracking_url TEXT,
  dispatch_date DATE NOT NULL,
  estimated_arrival DATE NOT NULL,

  FOREIGN KEY (delivery_id)
    REFERENCES deliveries(delivery_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (courier_company_id)
    REFERENCES courier_companies(courier_id)
    ON DELETE RESTRICT
);

CREATE TABLE land_courier (
  delivery_id INT PRIMARY KEY,
  courier_company_id INT NOT NULL,
  vehicle_type VARCHAR(50) NOT NULL,
  plate_number VARCHAR(50) NOT NULL,
  driver_name VARCHAR(100) NOT NULL,
  driver_contact_number VARCHAR(20) NOT NULL,
  pickup_location VARCHAR(100) NOT NULL,
  destination VARCHAR(100) NOT NULL,
  route_description TEXT,

  FOREIGN KEY (delivery_id)
    REFERENCES third_party_courier(delivery_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (courier_company_id)
    REFERENCES courier_companies(courier_id)
    ON DELETE RESTRICT
);

CREATE TABLE air_courier(
  delivery_id INT PRIMARY KEY,
  courier_company_id INT NOT NULL,
  flight_number VARCHAR(50) NOT NULL,
  airway_bill_number VARCHAR(50) UNIQUE NOT NULL,
  departure_airport TEXT NOT NULL,
  arrival_airport TEXT NOT NULL,
  departure_time TIME NOT NULL,
  arrival_time TIME NOT NULL,

  FOREIGN KEY (delivery_id)
    REFERENCES third_party_courier(delivery_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (courier_company_id)
    REFERENCES courier_companies(courier_id)
    ON DELETE RESTRICT
);

CREATE TABLE water_courier (
  delivery_id INT PRIMARY KEY,
  courier_company_id INT NOT NULL,
  vessel_name VARCHAR(50),
  voyage_number VARCHAR(50),
  bill_of_lading VARCHAR(50),
  port_of_loading VARCHAR(50) NOT NULL,
  destination_port VARCHAR(50) NOT NULL,
  departure_date DATE NOT NULL,
  arrival_date DATE NOT NULL,

  FOREIGN KEY (delivery_id)
    REFERENCES third_party_courier(delivery_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (courier_company_id)
    REFERENCES courier_companies(courier_id)
    ON DELETE RESTRICT
);


/*
========================AUDIT MODULE========================
+++Audit Module stores all the activities done by the users
+++ logs - logs the activities done by the user
*/

CREATE TABLE logs (
  log_number SERIAL PRIMARY KEY,
  employee_id VARCHAR(20) NOT NULL,
  department_id INT NOT NULL,
  role_id INT NOT NULL,
  date_of_activity DATE NOT NULL,
  time_of_activity TIME NOT NULL,
  activity_id INT NOT NULL,
  audit_status_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id)
    ON DELETE RESTRICT, 

  FOREIGN KEY (role_id)
    REFERENCES roles (role_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (activity_id)
    REFERENCES activity_log (activity_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (audit_status_id)
    REFERENCES audit_status(audit_status_id)
    ON DELETE RESTRICT
);



/*========================SYSTEM LOGS========================
+++System Logs tells what happens to the system 
+++table: information about the system
*/

CREATE TABLE system_logs (
  system_log_id SERIAL PRIMARY KEY, 
  component_id INT NOT NULL, 
  event_id INT NOT NULL,
  severity_id INT NOT NULL, 
  description TEXT NOT NULL,
  system_status_id INT NOT NULL,
  system_date DATE NOT NULL,
  system_time TIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (component_id)
    REFERENCES components(component_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (event_id)
    REFERENCES events(event_id)
    ON DELETE RESTRICT, 

  FOREIGN KEY (severity_id)
    REFERENCES severity (severity_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (system_status_id)
    REFERENCES system_status(system_status_id)
    ON DELETE RESTRICT
);


/*========================DATABASE MAINTENANCE MODULE========================
+++Database Maintenance tells backup activities of the database 
+++table: database_backups - stores actual history of database backups that were created. 
+++table: backup_schedule - stores the schedule/onfiguration for automatic backups
+++table: database_restores - records every time an existing backup was used to restore the database
*/

CREATE TABLE database_backups (
  backup_id BIGSERIAL PRIMARY KEY, 
  backup_type VARCHAR(20) NOT NULL, 
  file_name VARCHAR(255) NOT NULL, 
  file_path TEXT NOT NULL, 
  backup_size_mb DECIMAL (10,2),
  status VARCHAR(20) NOT NULL,
  started_at TIMESTAMP NOT NULL,
  completed_at TIMESTAMP,
  duration_seconds INT,
  created_by VARCHAR(20),

  FOREIGN KEY (created_by)
    REFERENCES employees(employee_id)
);

CREATE TABLE backup_schedule (
  schedule_id SERIAL PRIMARY KEY,
  frequency VARCHAR(20),
  backup_time TIME, 
  backup_type VARCHAR(20) NOT NULL,
  enabled BOOLEAN DEFAULT TRUE, 
  updated_by VARCHAR (20),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE database_restores (
  restore_id BIGSERIAL PRIMARY KEY,
  backup_id BIGINT,
  restored_by VARCHAR(20),
  restored_at TIMESTAMP,
  status VARCHAR(20),
  notes TEXT,

  FOREIGN KEY (backup_id)
    REFERENCES database_backups(backup_id),

  FOREIGN KEY (restored_by)
    REFERENCES employees(employee_id)
);

/*
ACCOUNT SUPPORT CENTER MODULE - handles the account related problems experienced by the user such as account locked, forgotten password, etc. 
+++table: account_support - generates the ticket id, take note of the employee information that experiencing problem, their role in the system, what is their isssue, priority of the problem, and status. 
*/

CREATE TABLE account_support (
  account_support_id SERIAL PRIMARY KEY,
  ticket_id VARCHAR(100) UNIQUE NOT NULL,
  employee_id VARCHAR(20) NOT NULL,
  role_id INT NOT NULL,
  issue_id INT NOT NULL,
  priority_id INT NOT NULL,
  issue_description TEXT NOT NULL,
  issue_status INT NOT NULL,

  FOREIGN KEY (employee_id)
    REFERENCES employees (employee_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (role_id)
    REFERENCES roles(role_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (issue_id)
    REFERENCES issue_description(issue_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (priority_id)
    REFERENCES priority (priority_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (issue_status)
    REFERENCES issue_status(issue_status_id)
    ON DELETE RESTRICT

);


/*
===================CHAT MODULE===================
+++Chat module handles the chat communication of the system
+++table: chat_threads - take note of every conversation that occurs in every request (1 thread = 1 chat)
+++table: thread_participants - involved users
+++table: chat_messages - the actual messages
+++table: message_attachments - attachments sent through chats 
*/

CREATE TABLE chat_threads (
  thread_id SERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id)
);

CREATE TABLE thread_participants (
  thread_id INT NOT NULL,
  employee_id VARCHAR(20) NOT NULL,

  PRIMARY KEY(thread_id, employee_id),
  
  FOREIGN KEY(thread_id)
    REFERENCES chat_threads(thread_id),

  FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id)
);

CREATE TABLE chat_messages (
  message_id BIGSERIAL PRIMARY KEY,
  thread_id INT NOT NULL,
  sender_id VARCHAR(20) NOT NULL,
  message TEXT NOT NULL,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(thread_id)
    REFERENCES chat_threads(thread_id),

  FOREIGN KEY (sender_id)
    REFERENCES employees(employee_id)
);


CREATE TABLE message_attachments (
  message_attachment_id BIGSERIAL PRIMARY KEY,
  message_id BIGINT NOT NULL,
  attachment_id BIGINT NOT NULL,

  FOREIGN KEY (message_id)
    REFERENCES chat_messages(message_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (attachment_id)
    REFERENCES request_attachments(attachment_id)

);




/*=============================SLA MODULE=============================*/

--SLA MONITORING
CREATE TABLE sla_tracking (
  sla_id SERIAL PRIMARY KEY,
  request_id INT NOT NULL UNIQUE,
  priority_id INT NOT NULL, 
  started_at TIMESTAMP NOT NULL,
  expected_completion TIMESTAMP NOT NULL,
  paused BOOLEAN DEFAULT FALSE, 
  pause_reason TEXT,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY (priority_id)
    REFERENCES priority(priority_id)
);


CREATE TABLE sla_pause_logs (
  pause_id SERIAL PRIMARY KEY,
  sla_id INT,
  approved_by VARCHAR(20),
  reason TEXT NOT NULL,
  started_at TIMESTAMP,
  resumed_at TIMESTAMP,

  FOREIGN KEY (sla_id)
    REFERENCES sla_tracking(sla_id),

  FOREIGN KEY (approved_by)
    REFERENCES employees (employee_id)
);




/*===========================CONFLICT MODULE===========================
Conflict Module records every information in every conflict such as problems during quality control, transit, and package testing after it was received. 
+++ It has 3 sub module (1) quality_control (2) incident (3)dispute
*/

/*=========================QUALITY CONTROL MODULE=========================

*/
CREATE TABLE quality_control (
  quality_control_id SERIAL PRIMARY KEY,
  quality_control_result_id INT NOT NULL,
  request_id INT NOT NULL,
  waiver_reason TEXT,
  waived_by VARCHAR(20),
  waived_at TIMESTAMP,

  FOREIGN KEY (quality_control_result_id)
    REFERENCES quality_control_result(quality_control_result_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (waived_by)
    REFERENCES employees (employee_id)
    ON DELETE RESTRICT
);

CREATE TABLE quality_control_evidence ( --only when quality control failed
  qc_evidence_id BIGSERIAL PRIMARY KEY,
  quality_control_id INT NOT NULL,
  attachment_id BIGINT NOT NULL,
  
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (quality_control_id)
    REFERENCES quality_control (quality_control_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (attachment_id)
    REFERENCES request_attachments (attachment_id)
    ON DELETE RESTRICT
);


/*=========================INCIDENT MODULE=========================

*/
CREATE TABLE incidents (
  incident_id SERIAL PRIMARY KEY,
  incident_number VARCHAR(20) UNIQUE NOT NULL,
  request_id INT NOT NULL,
  reported_by VARCHAR(20) NOT NULL,
  assigned_to VARCHAR(20),
  incident_type_id INT NOT NULL,
  incident_status_id INT NOT NULL,
  current_pipeline_id INT,
  custody_holder VARCHAR(20),
  location VARCHAR(255),
  remarks TEXT,
  resolution TEXT,
  replacement_request_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY (reported_by)
    REFERENCES employees (employee_id),

  FOREIGN KEY (assigned_to)
    REFERENCES employees (employee_id),

  FOREIGN KEY (incident_type_id)
    REFERENCES incident_types (incident_type_id),

  FOREIGN KEY (incident_status_id)
    REFERENCES incident_status (incident_status_id),

  FOREIGN KEY (current_pipeline_id)
    REFERENCES request_pipeline(pipeline_id),

  FOREIGN KEY (replacement_request_id)
    REFERENCES requests(request_id)
);

CREATE TABLE incident_evidence (
  evidence_id BIGSERIAL PRIMARY KEY,
  incident_id INT NOT NULL,
  attachment_id BIGINT NOT NULL,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (incident_id)
    REFERENCES incidents (incident_id),

  FOREIGN KEY (attachment_id)
    REFERENCES request_attachments (attachment_id)
);

CREATE TABLE incident_history (
  history_id BIGSERIAL PRIMARY KEY,
  incident_id INT NOT NULL,
  employee_id VARCHAR(20),
  action VARCHAR(100),
  remarks TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (incident_id)
    REFERENCES incidents (incident_id),

  FOREIGN KEY (employee_id)
    REFERENCES employees (employee_id)
);

CREATE TABLE messenger_incidents (
  incident_id INT PRIMARY KEY,
  last_latitude DECIMAL (9,6),
  last_longitude DECIMAL (9,6),
  courier_remarks TEXT,
  estimated_resume TIMESTAMP,

  FOREIGN KEY (incident_id)
    REFERENCES incidents (incident_id)
);

/*========================DISPUTE MODULE========================
+++ Dispute Module stores the information for the disputes reported by users
+++ table: disputes - stores the main information
+++ table: dispute_attachments - files uploaded to prove why dispute is raised
*/

CREATE TABLE disputes (
  dispute_id SERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  reported_by VARCHAR(20),
  assigned_to VARCHAR(20),

  dispute_type_id INT NOT NULL, 
  status_id INT  NOT NULL,

  title TEXT,

  description TEXT NOT NULL,

  resolution TEXT, 

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP,

  FOREIGN KEY (assigned_to)
    REFERENCES employees (employee_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (dispute_type_id)
    REFERENCES dispute_types(dispute_type_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (reported_by)
    REFERENCES employees (employee_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (request_id)
    REFERENCES requests(request_id)
    ON DELETE RESTRICT,

  FOREIGN KEY (status_id)
    REFERENCES dispute_status(status_id)
);

CREATE TABLE dispute_evidence (
  evidence_id SERIAL PRIMARY KEY,
  dispute_id INT, 
  attachment_id BIGINT,
  evidence_type VARCHAR(50),
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (dispute_id)
    REFERENCES disputes(dispute_id),

  FOREIGN KEY (attachment_id)
    REFERENCES request_attachments(attachment_id)
);


/*==============================NOTIFICATION MODULE==============================*/
CREATE TABLE notifications (
  notification_id BIGSERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  notification_type_id INT,
  title VARCHAR(150),
  message TEXT,
  related_request_id INT,
  related_incident_id INT,
  related_asset_id INT,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(user_id),

  FOREIGN KEY (notification_type_id)
    REFERENCES notification_types(notification_type_id),

  FOREIGN KEY (related_request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY (related_incident_id)
    REFERENCES incidents(incident_id),

  FOREIGN KEY (related_asset_id)
    REFERENCES assets(asset_id)
);

/*====================DIGITAL SIGNATURES===================*/

CREATE TABLE digital_signatures (
  signature_id BIGSERIAL PRIMARY KEY,
  request_id INT NOT NULL,
  employee_id VARCHAR(20) NOT NULL,
  attachment_id BIGINT,
  signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(request_id)
    REFERENCES requests(request_id),

  FOREIGN KEY(employee_id)
    REFERENCES employees (employee_id),

  FOREIGN KEY (attachment_id)
    REFERENCES request_attachments(attachment_id)
);

