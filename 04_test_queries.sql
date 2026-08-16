/*==============================================================
  test_queries.sql
  VERITRAIL DATABASE TEST QUERIES
  ---------------------------------------------------------------
  Purpose:
  - Verify that schema.sql, seed_data.sql, and sample_data.sql
    were loaded correctly.
  - Test relationships, foreign keys, joins, business rules,
    inventory/asset consistency, requests, QC, custody, incidents,
    SLA, and other modules.
  - These tests are READ-ONLY. They do not INSERT, UPDATE, or DELETE.

  Run this AFTER:
    01_schema.sql
    02_seed_data.sql
    03_sample_data.sql
==============================================================*/


/*==============================================================
  TEST 1 — MASTER TABLE ROW COUNTS
  Expected: each table should contain the seeded master data.
==============================================================*/

SELECT 'activity_log' AS table_name, COUNT(*) AS row_count FROM activity_log
UNION ALL
SELECT 'attachment_type', COUNT(*) FROM attachment_type
UNION ALL
SELECT 'audit_status', COUNT(*) FROM audit_status
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'components', COUNT(*) FROM components
UNION ALL
SELECT 'delivery_type', COUNT(*) FROM delivery_type
UNION ALL
SELECT 'database_status', COUNT(*) FROM database_status
UNION ALL
SELECT 'departments', COUNT(*) FROM departments
UNION ALL
SELECT 'delivery_status', COUNT(*) FROM delivery_status
UNION ALL
SELECT 'dispute_status', COUNT(*) FROM dispute_status
UNION ALL
SELECT 'dispute_types', COUNT(*) FROM dispute_types
UNION ALL
SELECT 'events', COUNT(*) FROM events
UNION ALL
SELECT 'incident_types', COUNT(*) FROM incident_types
UNION ALL
SELECT 'incident_status', COUNT(*) FROM incident_status
UNION ALL
SELECT 'notification_types', COUNT(*) FROM notification_types
UNION ALL
SELECT 'offices', COUNT(*) FROM offices
UNION ALL
SELECT 'packaging', COUNT(*) FROM packaging
UNION ALL
SELECT 'priority', COUNT(*) FROM priority
UNION ALL
SELECT 'quality_control_result', COUNT(*) FROM quality_control_result
UNION ALL
SELECT 'request_pipeline', COUNT(*) FROM request_pipeline
UNION ALL
SELECT 'roles', COUNT(*) FROM roles
UNION ALL
SELECT 'severity', COUNT(*) FROM severity
UNION ALL
SELECT 'system_status', COUNT(*) FROM system_status
UNION ALL
SELECT 'units', COUNT(*) FROM units
ORDER BY table_name;


/*==============================================================
  TEST 2 — REQUEST PIPELINE ORDER
  Expected: pipeline_order is sequential and pipeline names are
  displayed in the intended workflow order.
==============================================================*/

SELECT
    pipeline_id,
    pipeline_order,
    pipeline_name
FROM request_pipeline
ORDER BY pipeline_order;


/*==============================================================
  TEST 3 — USERS + EMPLOYEES + DEPARTMENTS + ROLES
  Expected: every sample user has a valid employee and role.
==============================================================*/

SELECT
    u.user_id,
    u.username,
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    r.role_name
FROM users u
JOIN employees e
    ON e.employee_id = u.employee_id
JOIN departments d
    ON d.department_id = e.department_id
JOIN user_roles ur
    ON ur.user_id = u.user_id
JOIN roles r
    ON r.role_id = ur.role_id
ORDER BY u.user_id;


/*==============================================================
  TEST 4 — CHECK FOR USERS WITHOUT EMPLOYEES
  Expected: 0 rows.
==============================================================*/

SELECT
    u.user_id,
    u.username,
    u.employee_id
FROM users u
LEFT JOIN employees e
    ON e.employee_id = u.employee_id
WHERE e.employee_id IS NULL;


/*==============================================================
  TEST 5 — CHECK FOR USERS WITHOUT ROLES
  Expected: 0 rows.
==============================================================*/

SELECT
    u.user_id,
    u.username
FROM users u
LEFT JOIN user_roles ur
    ON ur.user_id = u.user_id
WHERE ur.user_id IS NULL;


/*==============================================================
  TEST 6 — INVENTORY + CATEGORY
  Expected: all sample inventory rows have valid categories.
==============================================================*/

SELECT
    wi.inventory_id,
    wi.product_name,
    wi.sku,
    wi.quantity_on_hand,
    wi.reorder_level,
    c.category_name
FROM warehouse_inventory wi
JOIN categories c
    ON c.category_id = wi.category_id
ORDER BY wi.inventory_id;


/*==============================================================
  TEST 7 — INVENTORY STOCK / REORDER STATUS
==============================================================*/

SELECT
    inventory_id,
    product_name,
    sku,
    quantity_on_hand,
    reorder_level,
    CASE
        WHEN quantity_on_hand <= reorder_level THEN 'REORDER NEEDED'
        ELSE 'STOCK OK'
    END AS stock_status
FROM warehouse_inventory
ORDER BY inventory_id;


/*==============================================================
  TEST 8 — ASSETS + INVENTORY CONSISTENCY
  IMPORTANT TEST:
  asset.inventory_id must match the inventory item it belongs to.
==============================================================*/

SELECT
    a.asset_id,
    a.asset_tag,
    a.inventory_id AS asset_inventory_id,
    wi.inventory_id AS inventory_id,
    wi.product_name,
    wi.sku,
    a.status,
    CASE
        WHEN a.inventory_id = wi.inventory_id THEN 'PASS'
        ELSE 'FAIL'
    END AS inventory_match
FROM assets a
JOIN warehouse_inventory wi
    ON wi.inventory_id = a.inventory_id
ORDER BY a.asset_id;


/*==============================================================
  TEST 9 — FIND ASSETS WITH INVALID INVENTORY REFERENCES
  Expected: 0 rows.
==============================================================*/

SELECT
    a.asset_id,
    a.asset_tag,
    a.inventory_id
FROM assets a
LEFT JOIN warehouse_inventory wi
    ON wi.inventory_id = a.inventory_id
WHERE wi.inventory_id IS NULL;


/*==============================================================
  TEST 10 — INVENTORY + SUPPLIERS
==============================================================*/

SELECT
    wi.inventory_id,
    wi.sku,
    wi.product_name,
    s.supplier_id,
    s.company_name
FROM warehouse_inventory wi
JOIN inventory_suppliers ins
    ON ins.inventory_id = wi.inventory_id
JOIN suppliers s
    ON s.supplier_id = ins.supplier_id
ORDER BY wi.inventory_id, s.supplier_id;


/*==============================================================
  TEST 11 — REQUEST OVERVIEW
  This is the main request-management JOIN test.
==============================================================*/

SELECT
    r.request_id,
    r.request_number,
    u.username AS requester,
    rp.pipeline_name,
    p.priority_category,
    pkg.packaging_type,
    src.office_name AS source_office,
    dest.office_name AS destination_office,
    r.receiver_id,
    r.recipient_name,
    r.qc_acknowledgement,
    r.created_at
FROM requests r
JOIN users u
    ON u.user_id = r.requester_id
JOIN request_pipeline rp
    ON rp.pipeline_id = r.pipeline_id
JOIN priority p
    ON p.priority_id = r.priority_id
LEFT JOIN packaging pkg
    ON pkg.packaging_preference_id = r.packaging_preference_id
JOIN offices src
    ON src.office_id = r.source_office_id
JOIN offices dest
    ON dest.office_id = r.destination_office_id
ORDER BY r.request_id;


/*==============================================================
  TEST 12 — CHECK REQUESTS WITH INVALID FOREIGN KEYS
  Expected: 0 rows.
==============================================================*/

SELECT
    r.request_id,
    r.request_number
FROM requests r
LEFT JOIN users u
    ON u.user_id = r.requester_id
LEFT JOIN request_pipeline rp
    ON rp.pipeline_id = r.pipeline_id
LEFT JOIN priority p
    ON p.priority_id = r.priority_id
LEFT JOIN offices src
    ON src.office_id = r.source_office_id
LEFT JOIN offices dest
    ON dest.office_id = r.destination_office_id
WHERE u.user_id IS NULL
   OR rp.pipeline_id IS NULL
   OR p.priority_id IS NULL
   OR src.office_id IS NULL
   OR dest.office_id IS NULL;


/*==============================================================
  TEST 13 — REQUEST ITEMS + ASSETS + INVENTORY
  IMPORTANT:
  This verifies the composite FK relationship:
      request_items(asset_id, inventory_id)
      -> assets(asset_id, inventory_id)
==============================================================*/

SELECT
    r.request_number,
    wi.sku,
    wi.product_name,
    a.asset_tag,
    ri.inventory_id,
    ri.asset_id,
    ri.quantity_requested,
    CASE
        WHEN a.inventory_id = ri.inventory_id THEN 'PASS'
        ELSE 'FAIL'
    END AS asset_inventory_consistency
FROM request_items ri
JOIN requests r
    ON r.request_id = ri.request_id
JOIN warehouse_inventory wi
    ON wi.inventory_id = ri.inventory_id
LEFT JOIN assets a
    ON a.asset_id = ri.asset_id
ORDER BY r.request_id;


/*==============================================================
  TEST 14 — FIND BROKEN REQUEST ITEM ASSET REFERENCES
  Expected: 0 rows.
==============================================================*/

SELECT
    ri.request_item_id,
    ri.request_id,
    ri.inventory_id,
    ri.asset_id
FROM request_items ri
LEFT JOIN assets a
    ON a.asset_id = ri.asset_id
   AND a.inventory_id = ri.inventory_id
WHERE ri.asset_id IS NOT NULL
  AND a.asset_id IS NULL;


/*==============================================================
  TEST 15 — REQUESTED QUANTITY VALIDATION
  Expected: 0 rows.
==============================================================*/

SELECT
    request_item_id,
    request_id,
    quantity_requested
FROM request_items
WHERE quantity_requested <= 0;


/*==============================================================
  TEST 16 — REQUESTED QUANTITY VS INVENTORY
  This does not assume that quantity_requested must always be less
  than stock because a business process may reserve stock first.
  It simply identifies potentially problematic requests.
==============================================================*/

SELECT
    r.request_number,
    wi.product_name,
    wi.quantity_on_hand,
    ri.quantity_requested,
    CASE
        WHEN ri.quantity_requested <= wi.quantity_on_hand THEN 'PASS'
        ELSE 'CHECK STOCK'
    END AS stock_check
FROM request_items ri
JOIN requests r
    ON r.request_id = ri.request_id
JOIN warehouse_inventory wi
    ON wi.inventory_id = ri.inventory_id
ORDER BY r.request_id;


/*==============================================================
  TEST 17 — ACTIVE ASSET RESERVATIONS
==============================================================*/

SELECT
    ar.reservation_id,
    ar.asset_id,
    a.asset_tag,
    r.request_number,
    ar.reserved_by,
    e.first_name || ' ' || e.last_name AS reserved_by_name,
    ar.status,
    ar.reserved_at,
    ar.released_at
FROM asset_reservations ar
JOIN assets a
    ON a.asset_id = ar.asset_id
JOIN requests r
    ON r.request_id = ar.request_id
JOIN employees e
    ON e.employee_id = ar.reserved_by
WHERE ar.status = 'Active'
ORDER BY ar.reservation_id;


/*==============================================================
  TEST 18 — CHECK FOR MULTIPLE ACTIVE RESERVATIONS ON ONE ASSET
  Expected: 0 rows.

  This directly checks the issue:
  "uq_active_asset_reservation"
==============================================================*/

SELECT
    asset_id,
    COUNT(*) AS active_reservation_count
FROM asset_reservations
WHERE status = 'Active'
GROUP BY asset_id
HAVING COUNT(*) > 1;


/*==============================================================
  TEST 19 — CHECK ACTIVE RESERVATION REFERENCES
  Expected: 0 rows.
==============================================================*/

SELECT
    ar.reservation_id,
    ar.asset_id,
    ar.request_id,
    ar.reserved_by
FROM asset_reservations ar
LEFT JOIN assets a
    ON a.asset_id = ar.asset_id
LEFT JOIN requests r
    ON r.request_id = ar.request_id
LEFT JOIN employees e
    ON e.employee_id = ar.reserved_by
WHERE a.asset_id IS NULL
   OR r.request_id IS NULL
   OR e.employee_id IS NULL;


/*==============================================================
  TEST 20 — REQUEST TRACKING
==============================================================*/

SELECT
    r.request_number,
    rp.pipeline_name,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS handled_by,
    rt.remarks,
    rt.started_at,
    rt.completed_at
FROM request_tracking rt
JOIN requests r
    ON r.request_id = rt.request_id
JOIN request_pipeline rp
    ON rp.pipeline_id = rt.pipeline_id
JOIN employees e
    ON e.employee_id = rt.handled_by
ORDER BY rt.tracking_id;


/*==============================================================
  TEST 21 — QUALITY CONTROL RESULTS
==============================================================*/

SELECT
    r.request_number,
    qcr.result_name,
    qc.waiver_reason,
    qc.waived_by,
    qc.waived_at
FROM quality_control qc
JOIN requests r
    ON r.request_id = qc.request_id
JOIN quality_control_result qcr
    ON qcr.quality_control_result_id = qc.quality_control_result_id
ORDER BY qc.quality_control_id;


/*==============================================================
  TEST 22 — QC VALIDATION
  Expected: every QC row has a valid request and result.
==============================================================*/

SELECT
    qc.quality_control_id,
    qc.request_id,
    qc.quality_control_result_id
FROM quality_control qc
LEFT JOIN requests r
    ON r.request_id = qc.request_id
LEFT JOIN quality_control_result qcr
    ON qcr.quality_control_result_id = qc.quality_control_result_id
WHERE r.request_id IS NULL
   OR qcr.quality_control_result_id IS NULL;


/*==============================================================
  TEST 23 — CUSTODY CHAIN
  Shows who released and received an asset.
==============================================================*/

SELECT
    r.request_number,
    a.asset_tag,
    re.first_name || ' ' || re.last_name AS released_by,
    rr.first_name || ' ' || rr.last_name AS received_by,
    rr_role.role_name AS received_role,
    cr.transfer_location,
    cr.asset_condition,
    cr.remarks,
    cr.transferred_at
FROM custody_records cr
JOIN requests r
    ON r.request_id = cr.request_id
JOIN assets a
    ON a.asset_id = cr.asset_id
LEFT JOIN employees re
    ON re.employee_id = cr.released_by
LEFT JOIN employees rr
    ON rr.employee_id = cr.received_by
LEFT JOIN roles rr_role
    ON rr_role.role_id = cr.received_role
ORDER BY cr.custody_id;


/*==============================================================
  TEST 24 — ACTIVE CUSTODIAN
==============================================================*/

SELECT
    r.request_number,
    ac.employee_id,
    e.first_name || ' ' || e.last_name AS custodian_name,
    role.role_name,
    ac.updated_at
FROM active_custodian ac
JOIN requests r
    ON r.request_id = ac.request_id
JOIN employees e
    ON e.employee_id = ac.employee_id
JOIN roles role
    ON role.role_id = ac.role_id
ORDER BY r.request_id;


/*==============================================================
  TEST 25 — CUSTODY VS ACTIVE CUSTODIAN
  For requests having both records, compare the latest custody
  receiver with the active custodian.
==============================================================*/

WITH latest_custody AS (
    SELECT DISTINCT ON (request_id)
        request_id,
        received_by
    FROM custody_records
    ORDER BY request_id, transferred_at DESC, custody_id DESC
)
SELECT
    r.request_number,
    lc.received_by AS latest_received_by,
    ac.employee_id AS active_custodian,
    CASE
        WHEN lc.received_by = ac.employee_id THEN 'PASS'
        ELSE 'CHECK'
    END AS custody_match
FROM latest_custody lc
JOIN requests r
    ON r.request_id = lc.request_id
JOIN active_custodian ac
    ON ac.request_id = lc.request_id
ORDER BY r.request_id;


/*==============================================================
  TEST 26 — SLA TRACKING
==============================================================*/

SELECT
    r.request_number,
    p.priority_category,
    s.started_at,
    s.expected_completion,
    s.paused,
    s.pause_reason,
    CASE
        WHEN s.expected_completion > s.started_at THEN 'PASS'
        ELSE 'FAIL'
    END AS sla_time_check
FROM sla_tracking s
JOIN requests r
    ON r.request_id = s.request_id
JOIN priority p
    ON p.priority_id = s.priority_id
ORDER BY s.sla_id;


/*==============================================================
  TEST 27 — SLA DUPLICATES
  request_id is UNIQUE in sla_tracking.
  Expected: 0 rows.
==============================================================*/

SELECT
    request_id,
    COUNT(*) AS sla_count
FROM sla_tracking
GROUP BY request_id
HAVING COUNT(*) > 1;


/*==============================================================
  TEST 28 — INCIDENT OVERVIEW
==============================================================*/

SELECT
    i.incident_id,
    i.incident_number,
    r.request_number,
    it.incident_type,
    ist.status_name AS incident_status,
    rp.pipeline_name AS current_pipeline,
    reporter.first_name || ' ' || reporter.last_name AS reported_by,
    assigned.first_name || ' ' || assigned.last_name AS assigned_to,
    i.custody_holder,
    i.location,
    i.remarks,
    i.resolution,
    i.created_at,
    i.resolved_at
FROM incidents i
JOIN requests r
    ON r.request_id = i.request_id
JOIN incident_types it
    ON it.incident_type_id = i.incident_type_id
JOIN incident_status ist
    ON ist.incident_status_id = i.incident_status_id
LEFT JOIN request_pipeline rp
    ON rp.pipeline_id = i.current_pipeline_id
JOIN employees reporter
    ON reporter.employee_id = i.reported_by
LEFT JOIN employees assigned
    ON assigned.employee_id = i.assigned_to
ORDER BY i.incident_id;


/*==============================================================
  TEST 29 — INCIDENT FOREIGN KEY VALIDATION
  Expected: 0 rows.
==============================================================*/

SELECT
    i.incident_id,
    i.incident_number
FROM incidents i
LEFT JOIN requests r
    ON r.request_id = i.request_id
LEFT JOIN employees reporter
    ON reporter.employee_id = i.reported_by
LEFT JOIN incident_types it
    ON it.incident_type_id = i.incident_type_id
LEFT JOIN incident_status ist
    ON ist.incident_status_id = i.incident_status_id
WHERE r.request_id IS NULL
   OR reporter.employee_id IS NULL
   OR it.incident_type_id IS NULL
   OR ist.incident_status_id IS NULL;


/*==============================================================
  TEST 30 — INCIDENT CUSTODY HOLDER
  Expected: every custody_holder value should reference an employee
  when it is not NULL.
==============================================================*/

SELECT
    i.incident_number,
    i.custody_holder
FROM incidents i
LEFT JOIN employees e
    ON e.employee_id = i.custody_holder
WHERE i.custody_holder IS NOT NULL
  AND e.employee_id IS NULL;


/*==============================================================
  TEST 31 — DELIVERY OVERVIEW
  If there are no deliveries yet, this should simply return 0 rows.
==============================================================*/

SELECT
    d.delivery_id,
    r.request_number,
    d.tracking_number,
    dt.delivery_type,
    ds.delivery_status,
    sender.username AS sender,
    recipient.username AS recipient,
    d.created_at
FROM deliveries d
JOIN requests r
    ON r.request_id = d.request_id
JOIN delivery_type dt
    ON dt.delivery_type_id = d.delivery_type_id
JOIN delivery_status ds
    ON ds.delivery_status_id = d.status_id
JOIN users sender
    ON sender.user_id = d.sender_id
JOIN users recipient
    ON recipient.user_id = d.recipient_id
ORDER BY d.delivery_id;


/*==============================================================
  TEST 32 — DELIVERY FOREIGN KEY VALIDATION
  Expected: 0 rows.
==============================================================*/

SELECT
    d.delivery_id,
    d.tracking_number
FROM deliveries d
LEFT JOIN requests r
    ON r.request_id = d.request_id
LEFT JOIN delivery_type dt
    ON dt.delivery_type_id = d.delivery_type_id
LEFT JOIN delivery_status ds
    ON ds.delivery_status_id = d.status_id
LEFT JOIN users sender
    ON sender.user_id = d.sender_id
LEFT JOIN users recipient
    ON recipient.user_id = d.recipient_id
WHERE r.request_id IS NULL
   OR dt.delivery_type_id IS NULL
   OR ds.delivery_status_id IS NULL
   OR sender.user_id IS NULL
   OR recipient.user_id IS NULL;


/*==============================================================
  TEST 33 — DISPUTES
==============================================================*/

SELECT
    d.dispute_id,
    r.request_number,
    dt.dispute_type,
    ds.status_name,
    reporter.first_name || ' ' || reporter.last_name AS reported_by,
    assigned.first_name || ' ' || assigned.last_name AS assigned_to,
    d.title,
    d.description,
    d.resolution,
    d.created_at,
    d.resolved_at
FROM disputes d
JOIN requests r
    ON r.request_id = d.request_id
JOIN dispute_types dt
    ON dt.dispute_type_id = d.dispute_type_id
JOIN dispute_status ds
    ON ds.status_id = d.status_id
LEFT JOIN employees reporter
    ON reporter.employee_id = d.reported_by
LEFT JOIN employees assigned
    ON assigned.employee_id = d.assigned_to
ORDER BY d.dispute_id;


/*==============================================================
  TEST 34 — NOTIFICATIONS
==============================================================*/

SELECT
    n.notification_id,
    u.username,
    nt.type_name AS notification_type,
    n.title,
    n.message,
    r.request_number,
    i.incident_number,
    a.asset_tag,
    n.is_read,
    n.read_at,
    n.created_at
FROM notifications n
JOIN users u
    ON u.user_id = n.user_id
LEFT JOIN notification_types nt
    ON nt.notification_type_id = n.notification_type_id
LEFT JOIN requests r
    ON r.request_id = n.related_request_id
LEFT JOIN incidents i
    ON i.incident_id = n.related_incident_id
LEFT JOIN assets a
    ON a.asset_id = n.related_asset_id
ORDER BY n.notification_id;


/*==============================================================
  TEST 35 — UNREAD NOTIFICATION COUNT PER USER
==============================================================*/

SELECT
    u.username,
    COUNT(n.notification_id) FILTER (WHERE n.is_read = FALSE) AS unread_count,
    COUNT(n.notification_id) AS total_notifications
FROM users u
LEFT JOIN notifications n
    ON n.user_id = u.user_id
GROUP BY u.user_id, u.username
ORDER BY u.username;


/*==============================================================
  TEST 36 — CHAT THREADS AND MESSAGES
==============================================================*/

SELECT
    ct.thread_id,
    r.request_number,
    COUNT(DISTINCT tp.employee_id) AS participant_count,
    COUNT(DISTINCT cm.message_id) AS message_count
FROM chat_threads ct
LEFT JOIN requests r
    ON r.request_id = ct.request_id
LEFT JOIN thread_participants tp
    ON tp.thread_id = ct.thread_id
LEFT JOIN chat_messages cm
    ON cm.thread_id = ct.thread_id
GROUP BY ct.thread_id, r.request_number
ORDER BY ct.thread_id;


/*==============================================================
  TEST 37 — CHAT MESSAGE SENDERS
  chat_messages.sender_id references employees.employee_id
==============================================================*/

SELECT
    cm.message_id,
    cm.thread_id,
    cm.sender_id,
    e.first_name || ' ' || e.last_name AS sender,
    cm.message,
    cm.sent_at
FROM chat_messages cm
JOIN employees e
    ON e.employee_id = cm.sender_id
ORDER BY cm.message_id;


/*==============================================================
  TEST 38 — CHECK DUPLICATE REQUEST NUMBERS
  Expected: 0 rows.
==============================================================*/

SELECT
    request_number,
    COUNT(*) AS duplicate_count
FROM requests
GROUP BY request_number
HAVING COUNT(*) > 1;


/*==============================================================
  TEST 39 — CHECK DUPLICATE SKUs
  Expected: 0 rows.
==============================================================*/

SELECT
    sku,
    COUNT(*) AS duplicate_count
FROM warehouse_inventory
GROUP BY sku
HAVING COUNT(*) > 1;


/*==============================================================
  TEST 40 — CHECK DUPLICATE ASSET TAGS
  Expected: 0 rows.
==============================================================*/

SELECT
    asset_tag,
    COUNT(*) AS duplicate_count
FROM assets
GROUP BY asset_tag
HAVING COUNT(*) > 1;


/*==============================================================
  TEST 41 — CHECK DUPLICATE ACTIVE CUSTODIANS
  Expected: 0 rows.
==============================================================*/

SELECT
    request_id,
    COUNT(*) AS custodian_count
FROM active_custodian
GROUP BY request_id
HAVING COUNT(*) > 1;


/*==============================================================
  TEST 42 — CHECK INVALID EMPLOYEE REFERENCES IN REQUEST TRACKING
  Expected: 0 rows.
==============================================================*/

SELECT
    rt.tracking_id,
    rt.request_id,
    rt.handled_by
FROM request_tracking rt
LEFT JOIN employees e
    ON e.employee_id = rt.handled_by
WHERE rt.handled_by IS NOT NULL
  AND e.employee_id IS NULL;


/*==============================================================
  TEST 43 — CHECK REQUEST ITEM UNIQUENESS
  request_items has UNIQUE(request_id, inventory_id).
  Expected: 0 rows.
==============================================================*/

SELECT
    request_id,
    inventory_id,
    COUNT(*) AS duplicate_count
FROM request_items
GROUP BY request_id, inventory_id
HAVING COUNT(*) > 1;


/*==============================================================
  TEST 44 — CHECK NULLS IN CRITICAL REQUEST FIELDS
  Expected: 0 rows.
==============================================================*/

SELECT
    request_id,
    request_number
FROM requests
WHERE request_number IS NULL
   OR requester_id IS NULL
   OR pipeline_id IS NULL
   OR priority_id IS NULL
   OR source_office_id IS NULL
   OR destination_office_id IS NULL
   OR recipient_name IS NULL
   OR delivery_address IS NULL
   OR business_purpose IS NULL;


/*==============================================================
  TEST 45 — SAMPLE REQUEST 0001 END-TO-END VIEW
  This combines the major modules for one complete transaction.
==============================================================*/

SELECT
    r.request_number,

    requester.username AS requester,

    rp.pipeline_name AS current_pipeline,
    p.priority_category,

    wi.product_name,
    wi.sku,
    a.asset_tag,
    ri.quantity_requested,

    qcr.result_name AS qc_result,

    custodian.first_name || ' ' || custodian.last_name
        AS current_custodian,

    i.incident_number,
    it.incident_type,
    ist.status_name AS incident_status,

    sla.paused AS sla_paused,
    sla.expected_completion

FROM requests r

JOIN users requester
    ON requester.user_id = r.requester_id

JOIN request_pipeline rp
    ON rp.pipeline_id = r.pipeline_id

JOIN priority p
    ON p.priority_id = r.priority_id

LEFT JOIN request_items ri
    ON ri.request_id = r.request_id

LEFT JOIN warehouse_inventory wi
    ON wi.inventory_id = ri.inventory_id

LEFT JOIN assets a
    ON a.asset_id = ri.asset_id
   AND a.inventory_id = ri.inventory_id

LEFT JOIN quality_control qc
    ON qc.request_id = r.request_id

LEFT JOIN quality_control_result qcr
    ON qcr.quality_control_result_id = qc.quality_control_result_id

LEFT JOIN active_custodian ac
    ON ac.request_id = r.request_id

LEFT JOIN employees custodian
    ON custodian.employee_id = ac.employee_id

LEFT JOIN incidents i
    ON i.request_id = r.request_id

LEFT JOIN incident_types it
    ON it.incident_type_id = i.incident_type_id

LEFT JOIN incident_status ist
    ON ist.incident_status_id = i.incident_status_id

LEFT JOIN sla_tracking sla
    ON sla.request_id = r.request_id

WHERE r.request_number = 'REQ-2026-0001';


/*==============================================================
  TEST 46 — SAMPLE REQUEST 0002 END-TO-END VIEW
  This request is intentionally associated with a QC failure and
  incident in the sample data.
==============================================================*/

SELECT
    r.request_number,

    requester.username AS requester,

    rp.pipeline_name AS current_pipeline,
    p.priority_category,

    wi.product_name,
    wi.sku,
    a.asset_tag,
    ri.quantity_requested,

    qcr.result_name AS qc_result,

    i.incident_number,
    it.incident_type,
    ist.status_name AS incident_status,
    i.location,
    i.custody_holder,
    i.remarks,

    sla.paused AS sla_paused,
    sla.pause_reason,
    sla.expected_completion

FROM requests r

JOIN users requester
    ON requester.user_id = r.requester_id

JOIN request_pipeline rp
    ON rp.pipeline_id = r.pipeline_id

JOIN priority p
    ON p.priority_id = r.priority_id

LEFT JOIN request_items ri
    ON ri.request_id = r.request_id

LEFT JOIN warehouse_inventory wi
    ON wi.inventory_id = ri.inventory_id

LEFT JOIN assets a
    ON a.asset_id = ri.asset_id
   AND a.inventory_id = ri.inventory_id

LEFT JOIN quality_control qc
    ON qc.request_id = r.request_id

LEFT JOIN quality_control_result qcr
    ON qcr.quality_control_result_id = qc.quality_control_result_id

LEFT JOIN incidents i
    ON i.request_id = r.request_id

LEFT JOIN incident_types it
    ON it.incident_type_id = i.incident_type_id

LEFT JOIN incident_status ist
    ON ist.incident_status_id = i.incident_status_id

LEFT JOIN sla_tracking sla
    ON sla.request_id = r.request_id

WHERE r.request_number = 'REQ-2026-0002';


/*==============================================================
  TEST 47 — DATABASE HEALTH SUMMARY
  A quick summary of the major transactional modules.
==============================================================*/

SELECT
    (SELECT COUNT(*) FROM employees)             AS employees,
    (SELECT COUNT(*) FROM users)                 AS users,
    (SELECT COUNT(*) FROM warehouse_inventory)  AS inventory_items,
    (SELECT COUNT(*) FROM assets)                AS assets,
    (SELECT COUNT(*) FROM requests)              AS requests,
    (SELECT COUNT(*) FROM request_items)         AS request_items,
    (SELECT COUNT(*) FROM asset_reservations)    AS reservations,
    (SELECT COUNT(*) FROM request_tracking)      AS request_tracking,
    (SELECT COUNT(*) FROM quality_control)       AS quality_control,
    (SELECT COUNT(*) FROM custody_records)       AS custody_records,
    (SELECT COUNT(*) FROM incidents)             AS incidents,
    (SELECT COUNT(*) FROM disputes)              AS disputes,
    (SELECT COUNT(*) FROM deliveries)            AS deliveries,
    (SELECT COUNT(*) FROM notifications)         AS notifications,
    (SELECT COUNT(*) FROM chat_threads)          AS chat_threads,
    (SELECT COUNT(*) FROM chat_messages)         AS chat_messages,
    (SELECT COUNT(*) FROM sla_tracking)          AS sla_records;


/*==============================================================
  TEST 48 — FINAL PASS/FAIL SUMMARY
  PASS means the basic integrity condition is satisfied.
==============================================================*/

SELECT
    'Requests exist' AS test_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM requests
    ) THEN 'PASS' ELSE 'FAIL' END AS result

UNION ALL

SELECT
    'Users have employees',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM users u
        LEFT JOIN employees e ON e.employee_id = u.employee_id
        WHERE e.employee_id IS NULL
    ) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'Request items have valid asset/inventory pairs',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM request_items ri
        LEFT JOIN assets a
          ON a.asset_id = ri.asset_id
         AND a.inventory_id = ri.inventory_id
        WHERE ri.asset_id IS NOT NULL
          AND a.asset_id IS NULL
    ) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'No duplicate active asset reservations',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM asset_reservations
        WHERE status = 'Active'
        GROUP BY asset_id
        HAVING COUNT(*) > 1
    ) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'All request quantities are positive',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM request_items
        WHERE quantity_requested <= 0
    ) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'No duplicate request numbers',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM requests
        GROUP BY request_number
        HAVING COUNT(*) > 1
    ) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'No duplicate asset tags',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM assets
        GROUP BY asset_tag
        HAVING COUNT(*) > 1
    ) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'No duplicate SKUs',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM warehouse_inventory
        GROUP BY sku
        HAVING COUNT(*) > 1
    ) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'SLA records have valid completion dates',
    CASE WHEN NOT EXISTS (
        SELECT 1
        FROM sla_tracking
        WHERE expected_completion <= started_at
    ) THEN 'PASS' ELSE 'FAIL' END

ORDER BY test_name;


/*==============================================================
  END OF TEST QUERIES
==============================================================*/