/*==============================================================
  SAMPLE / TRANSACTIONAL DATA
  Run AFTER all master-table seed data.
==============================================================*/


/*==============================================================
  1. EMPLOYEES
==============================================================*/

INSERT INTO employees (
  employee_id,
  first_name,
  last_name,
  middle_name,
  department_id,
  office_id,
  employment_status,
  contact_number,
  email
)
VALUES
(
  'EMP-001',
  'Maria',
  'Santos',
  'Reyes',
  3, -- Information Technology
  3, -- Information Technology Office
  'Active',
  '09171234567',
  'maria.santos@veritrail.local'
),
(
  'EMP-002',
  'James',
  'Dela Cruz',
  'M.',
  8, -- Operations
  5, -- Operations Office
  'Active',
  '09181234567',
  'james.delacruz@veritrail.local'
),
(
  'EMP-003',
  'Serenity',
  'Garcia',
  'L.',
  7, -- Warehouse
  4, -- Warehouse
  'Active',
  '09191234567',
  'serenity.garcia@veritrail.local'
),
(
  'EMP-004',
  'Mark',
  'Reyes',
  'A.',
  8, -- Operations
  5, -- Operations Office
  'Active',
  '09201234567',
  'mark.reyes@veritrail.local'
),
(
  'EMP-005',
  'John',
  'Mendoza',
  'P.',
  8, -- Operations
  5, -- Operations Office
  'Active',
  '09211234567',
  'john.mendoza@veritrail.local'
),
(
  'EMP-006',
  'Marie',
  'Torres',
  'C.',
  3, -- Information Technology
  3, -- Information Technology Office
  'Active',
  '09221234567',
  'marie.torres@veritrail.local'
);


/*==============================================================
  2. USER ACCOUNTS
==============================================================*/

INSERT INTO users (
  employee_id,
  username,
  password_hash
)
VALUES
(
  'EMP-001',
  'maria.requester',
  '$2b$12$SAMPLE_HASH_REQUESTER'
),
(
  'EMP-002',
  'james.supervisor',
  '$2b$12$SAMPLE_HASH_SUPERVISOR'
),
(
  'EMP-003',
  'serenity.handler',
  '$2b$12$SAMPLE_HASH_HANDLER'
),
(
  'EMP-004',
  'mark.messenger',
  '$2b$12$SAMPLE_HASH_MESSENGER'
),
(
  'EMP-005',
  'john.receiver',
  '$2b$12$SAMPLE_HASH_RECEIVER'
),
(
  'EMP-006',
  'marie.admin',
  '$2b$12$SAMPLE_HASH_ADMIN'
);


/*==============================================================
  3. USER ROLES
==============================================================*/

INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u
JOIN roles r ON r.role_name = 'Requester'
WHERE u.username = 'maria.requester';

INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u
JOIN roles r ON r.role_name = 'Supervisor'
WHERE u.username = 'james.supervisor';

INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u
JOIN roles r ON r.role_name = 'Handler'
WHERE u.username = 'serenity.handler';

INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u
JOIN roles r ON r.role_name = 'Messenger'
WHERE u.username = 'mark.messenger';

INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u
JOIN roles r ON r.role_name = 'Receiver'
WHERE u.username = 'john.receiver';

INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u
JOIN roles r ON r.role_name = 'IT Admin'
WHERE u.username = 'marie.admin';


/*==============================================================
  4. WAREHOUSE INVENTORY
==============================================================*/

INSERT INTO warehouse_inventory (
  product_name,
  sku,
  quantity_on_hand,
  category_id,
  reorder_level
)
VALUES
(
  'Business Laptop',
  'LAP-001',
  10,
  1, -- Electronics
  2
),
(
  'Office Projector',
  'PROJ-001',
  5,
  1, -- Electronics
  1
),
(
  'HDMI Cable',
  'HDMI-001',
  50,
  1, -- Electronics
  10
),
(
  'Document Scanner',
  'SCAN-001',
  4,
  1, -- Electronics
  1
);


/*==============================================================
  5. SUPPLIERS
==============================================================*/

INSERT INTO suppliers (
  company_name,
  contact_person,
  contact_number,
  email
)
VALUES
(
  'TechSource Philippines',
  'Daniel Lim',
  '09170000001',
  'sales@techsource.local'
),
(
  'Office Equipment Solutions',
  'Anna Cruz',
  '09170000002',
  'sales@officeequipment.local'
);


/*==============================================================
  6. INVENTORY-SUPPLIER RELATIONSHIPS
==============================================================*/

INSERT INTO inventory_suppliers (inventory_id, supplier_id)
VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 2);


/*==============================================================
  7. INDIVIDUAL ASSETS
==============================================================*/

INSERT INTO assets (
  asset_tag,
  inventory_id,
  office_id,
  status,
  condition_notes
)
VALUES
(
  'LAP-0001',
  1,
  4,
  'Available',
  'Good working condition'
),
(
  'LAP-0002',
  1,
  4,
  'Available',
  'Good working condition'
),
(
  'LAP-0003',
  1,
  4,
  'Quarantined',
  'Screen damage discovered during QC'
),
(
  'PROJ-0001',
  2,
  4,
  'In Use',
  'Currently assigned to warehouse operations'
),
(
  'SCAN-0001',
  4,
  4,
  'Available',
  'Good working condition'
);


/*==============================================================
  8. REQUEST #1
  NORMAL SUCCESSFUL TRANSFER
==============================================================*/

INSERT INTO requests (
  request_number,
  requester_id,
  pipeline_id,
  packaging_preference_id,
  priority_id,
  source_office_id,
  destination_office_id,
  receiver_id,
  recipient_name,
  delivery_address,
  business_purpose,
  qc_acknowledgement
)
VALUES
(
  'REQ-2026-0001',
  (SELECT user_id FROM users WHERE username = 'maria.requester'),
  (SELECT pipeline_id
   FROM request_pipeline
   WHERE pipeline_name = 'Approved'),
  (SELECT packaging_preference_id
   FROM packaging
   WHERE packaging_type = 'Bubble Wrap with Box'),
  (SELECT priority_id
   FROM priority
   WHERE priority_category = 'High'),
  4, -- Warehouse
  3, -- IT Office
  'EMP-005',
  'John Mendoza',
  'Information Technology Office, Main Building',
  'Transfer laptop equipment to the Information Technology Office.',
  TRUE
);


/*==============================================================
  9. REQUEST #1 ITEM
==============================================================*/

INSERT INTO request_items (
  request_id,
  inventory_id,
  asset_id,
  unit_id,
  quantity_requested
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  (SELECT inventory_id
   FROM warehouse_inventory
   WHERE sku = 'LAP-001'),

  (SELECT asset_id
   FROM assets
   WHERE asset_tag = 'LAP-0001'),

  (SELECT unit_id
   FROM units
   WHERE unit_name = 'Piece'),

  1
);


/*==============================================================
  10. REQUEST #1 ASSIGN HANDLER
==============================================================*/

INSERT INTO request_assignments (
  request_id,
  employee_id,
  role_id
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  'EMP-003',

  (SELECT role_id
   FROM roles
   WHERE role_name = 'Handler')
);


/*==============================================================
  11. REQUEST #1 RESERVATION
==============================================================*/

INSERT INTO asset_reservations (
  asset_id,
  request_id,
  reserved_by,
  status
)
VALUES
(
  (SELECT asset_id
   FROM assets
   WHERE asset_tag = 'LAP-0001'),

  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  'EMP-003',

  'Active'
);


/* Update physical asset status */

UPDATE assets
SET status = 'Reserved',
    updated_at = CURRENT_TIMESTAMP
WHERE asset_tag = 'LAP-0001';


/*==============================================================
  12. RESERVATION HISTORY
==============================================================*/

INSERT INTO asset_reservation_history (
  reservation_id,
  action,
  performed_by,
  remarks
)
SELECT
  ar.reservation_id,
  'Reserved',
  'EMP-003',
  'Asset reserved during inventory collection.'
FROM asset_reservations ar
JOIN assets a
  ON a.asset_id = ar.asset_id
JOIN requests r
  ON r.request_id = ar.request_id
WHERE a.asset_tag = 'LAP-0001'
  AND r.request_number = 'REQ-2026-0001';


/*==============================================================
  13. REQUEST #1 TRACKING
==============================================================*/

INSERT INTO request_tracking (
  request_id,
  pipeline_id,
  handled_by,
  remarks
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  (SELECT pipeline_id
   FROM request_pipeline
   WHERE pipeline_name = 'Inventory Collection'),

  'EMP-003',

  'Handler started inventory collection.'
);


/*==============================================================
  14. REQUEST #1 QC - PASSED
==============================================================*/

INSERT INTO quality_control (
  quality_control_result_id,
  request_id
)
VALUES
(
  (SELECT quality_control_result_id
   FROM quality_control_result
   WHERE result_name = 'Pass'),

  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001')
);


/*==============================================================
  15. REQUEST #1 CUSTODY
  Handler → Messenger
==============================================================*/

INSERT INTO custody_records (
  request_id,
  asset_id,
  released_by,
  received_by,
  released_role,
  received_role,
  transfer_location,
  asset_condition,
  remarks
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  (SELECT asset_id
   FROM assets
   WHERE asset_tag = 'LAP-0001'),

  'EMP-003',
  'EMP-004',

  (SELECT role_id FROM roles WHERE role_name = 'Handler'),
  (SELECT role_id FROM roles WHERE role_name = 'Messenger'),

  'Warehouse',
  'Good condition',
  'Asset handed over to Messenger for delivery.'
);


/*==============================================================
  16. ACTIVE CUSTODIAN
==============================================================*/

INSERT INTO active_custodian (
  request_id,
  employee_id,
  role_id
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  'EMP-004',

  (SELECT role_id
   FROM roles
   WHERE role_name = 'Messenger')
);


/*==============================================================
  17. REQUEST #1 SLA
==============================================================*/

INSERT INTO sla_tracking (
  request_id,
  priority_id,
  started_at,
  expected_completion,
  paused
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  (SELECT priority_id
   FROM priority
   WHERE priority_category = 'High'),

  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP + INTERVAL '2 days',
  FALSE
);


/*==============================================================
  18. REQUEST #1 DIGITAL SIGNATURE
==============================================================*/

INSERT INTO digital_signatures (
  request_id,
  employee_id
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0001'),

  'EMP-005'
);


/*==============================================================
  19. REQUEST #2
  QC FAILURE / INCIDENT SCENARIO
==============================================================*/

INSERT INTO requests (
  request_number,
  requester_id,
  pipeline_id,
  packaging_preference_id,
  priority_id,
  source_office_id,
  destination_office_id,
  receiver_id,
  recipient_name,
  delivery_address,
  business_purpose,
  qc_acknowledgement
)
VALUES
(
  'REQ-2026-0002',

  (SELECT user_id
   FROM users
   WHERE username = 'maria.requester'),

  (SELECT pipeline_id
   FROM request_pipeline
   WHERE pipeline_name = 'Quality Control'),

  (SELECT packaging_preference_id
   FROM packaging
   WHERE packaging_type = 'Box'),

  (SELECT priority_id
   FROM priority
   WHERE priority_category = 'Normal'),

  4,
  3,

  'EMP-005',
  'John Mendoza',

  'Information Technology Office, Main Building',

  'Transfer laptop equipment for replacement deployment.',

  FALSE
);


/*==============================================================
  20. REQUEST #2 ITEM
==============================================================*/

INSERT INTO request_items (
  request_id,
  inventory_id,
  asset_id,
  unit_id,
  quantity_requested
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0002'),

  (SELECT inventory_id
   FROM warehouse_inventory
   WHERE sku = 'LAP-001'),

  (SELECT asset_id
   FROM assets
   WHERE asset_tag = 'LAP-0003'),

  (SELECT unit_id
   FROM units
   WHERE unit_name = 'Piece'),

  1
);


/*==============================================================
  21. REQUEST #2 QC - FAILED
==============================================================*/

INSERT INTO quality_control (
  quality_control_result_id,
  request_id
)
VALUES
(
  (SELECT quality_control_result_id
   FROM quality_control_result
   WHERE result_name = 'Failed'),

  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0002')
);


/*==============================================================
  22. QUARANTINE FAILED ASSET
==============================================================*/

UPDATE assets
SET status = 'Quarantined',
    condition_notes = 'QC failed: damaged screen discovered during inspection.',
    updated_at = CURRENT_TIMESTAMP
WHERE asset_tag = 'LAP-0003';


/*==============================================================
  23. INCIDENT FOR QC FAILURE
==============================================================*/

INSERT INTO incidents (
  incident_number,
  request_id,
  reported_by,
  assigned_to,
  incident_type_id,
  incident_status_id,
  current_pipeline_id,
  custody_holder,
  location,
  remarks
)
VALUES
(
  'INC-2026-0001',

  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0002'),

  'EMP-003',
  'EMP-002',

  (SELECT incident_type_id
   FROM incident_types
   WHERE incident_type = 'Lost Package'),

  (SELECT incident_status_id
   FROM incident_status
   WHERE status_name = 'Reported'),

  (SELECT pipeline_id
   FROM request_pipeline
   WHERE pipeline_name = 'Quality Control'),

  'EMP-003',

  'Warehouse',

  'QC failure recorded. Asset quarantined pending investigation.'
);


/*==============================================================
  24. INCIDENT HISTORY
==============================================================*/

INSERT INTO incident_history (
  incident_id,
  employee_id,
  action,
  remarks
)
VALUES
(
  (SELECT incident_id
   FROM incidents
   WHERE incident_number = 'INC-2026-0001'),

  'EMP-003',

  'Incident Reported',

  'Handler reported QC failure and placed asset under quarantine.'
);


/*==============================================================
  25. REQUEST #2 SLA
==============================================================*/

INSERT INTO sla_tracking (
  request_id,
  priority_id,
  started_at,
  expected_completion,
  paused,
  pause_reason
)
VALUES
(
  (SELECT request_id
   FROM requests
   WHERE request_number = 'REQ-2026-0002'),

  (SELECT priority_id
   FROM priority
   WHERE priority_category = 'Normal'),

  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP + INTERVAL '3 days',
  TRUE,

  'Paused due to QC failure and incident investigation.'
);


/*==============================================================
  26. SLA PAUSE LOG
==============================================================*/

INSERT INTO sla_pause_logs (
  sla_id,
  approved_by,
  reason,
  started_at
)
SELECT
  sla_id,
  'EMP-002',
  'QC failure requires incident investigation.',
  CURRENT_TIMESTAMP
FROM sla_tracking
WHERE request_id = (
  SELECT request_id
  FROM requests
  WHERE request_number = 'REQ-2026-0002'
);


/*==============================================================
  27. NOTIFICATION - SUPERVISOR
==============================================================*/

INSERT INTO notifications (
  user_id,
  notification_type_id,
  title,
  message,
  related_request_id,
  related_incident_id
)
SELECT
  u.user_id,

  (SELECT notification_type_id
   FROM notification_types
   WHERE type_name = 'Incident'),

  'QC Failure',

  'QC inspection failed and an incident has been created.',

  r.request_id,

  i.incident_id

FROM users u
JOIN requests r
  ON r.request_number = 'REQ-2026-0002'
JOIN incidents i
  ON i.request_id = r.request_id
WHERE u.username = 'james.supervisor';


/*==============================================================
  28. SAMPLE CHAT THREAD
==============================================================*/

INSERT INTO chat_threads (request_id)
SELECT request_id
FROM requests
WHERE request_number = 'REQ-2026-0002';


INSERT INTO thread_participants (
  thread_id,
  employee_id
)
SELECT
  ct.thread_id,
  e.employee_id
FROM chat_threads ct
CROSS JOIN employees e
WHERE ct.request_id = (
  SELECT request_id
  FROM requests
  WHERE request_number = 'REQ-2026-0002'
)
AND e.employee_id IN ('EMP-002', 'EMP-003');


INSERT INTO chat_messages (
  thread_id,
  sender_id,
  message
)
SELECT
  ct.thread_id,
  'EMP-003',
  'QC failed. The laptop has visible screen damage and has been quarantined.'
FROM chat_threads ct
WHERE ct.request_id = (
  SELECT request_id
  FROM requests
  WHERE request_number = 'REQ-2026-0002'
);


/*==============================================================
  END SAMPLE DATA
==============================================================*/
