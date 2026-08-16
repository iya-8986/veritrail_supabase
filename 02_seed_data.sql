/*========================MASTER TABLES========================*/





/*ACTIVITY LOG*/
INSERT INTO activity_log (activity_type)
VALUES
  ('Created Administrator Account'),
  ('Created Employee Account'),
  ('Updated User Profile'),
  ('Changed User Role'),
  ('Reset User Password'),
  ('Locked User Account'),
  ('Unlocked User Account'),
  ('Disabled User Account'),
  ('Enabled User Account'),
  ('Deleted User Account'),

  ('Logged In'),
  ('Logged Out'),
  ('Changed Password'),
  ('Updated Security Settings'),

  ('Created Request'),
  ('Edited Request'),
  ('Cancelled Request'),
  ('Approved Request'),
  ('Rejected Request'),
  ('Assigned Handler'),
  ('Reassigned Handler'),

  ('Accepted Request'),
  ('Declined Request'),
  ('Started Processing Request'),
  ('Completed Processing Request'),

  ('Updated Package Information'),
  ('Updated Package Status'),
  ('Packed Item'),
  ('Completed Quality Check'),
  ('Generated QR Code'),
  ('Printed Shipping Label'),

  ('Assigned Messenger'),
  ('Started Delivery'),
  ('Updated Delivery Location'),
  ('Marked Packaged In Transit'),
  ('Arrived at Destination'),
  ('Delivered Package'),
  ('Confirmed Delivery'),

  ('Received Package'),
  ('Confirmed Package Receipt'),
  ('Rejected Package'),
  ('Reported Missing Package'),
  ('Reported Damaged Package'),

  ('Submitted Dispute'),
  ('Updated Dispute'),
  ('Reviewed Dispute'),
  ('Resolved Dispute'),
  ('Closed Dispute'),

  ('Uploaded Attachment'),
  ('Deleted Attachment'),
  ('Downloaded Attachment'),

  ('Changed System Name'),
  ('Changed System Logo'),
  ('Updated System Settings'),
  ('Updated Department List'),
  ('Updated Categories'),
  ('Updated Delivery Types'),
  ('Updated Packaging Types'),
  ('Updated Request Status'),
  ('Updated Dispute Status'),

  ('Created Backup'),
  ('Restored Database Backup'),
  ('Exported Audit Logs'),
  ('Cleared System Cache'),
  ('Performed Database Maintenance'),

  ('Viewed Dashboard'),
  ('Viewed Reports'),
  ('Generated Monthly Report'),
  ('Exported Report'),

  ('Registered Third-Party Courier'),
  ('Updated Courier Information'),
  ('Removed Courier'),

  ('Granted User Permission'),
  ('Revoked User Permission'),

  ('Updated GPS Location'),
  ('Verified Chain of Custody'),
  ('Transferred Package Responsibility'),
  ('Completed Transaction');

/*ATTACHMENT TYPE*/
INSERT INTO attachment_type (attachment_type)
VALUES 
  ('PDF'),
  ('DOC'),
  ('DOCX'),
  ('PNG'),
  ('JPEG'),
  ('JPG'),
  ('WEBP'),
  ('XLS'),
  ('XLSX'),
  ('CSV');

/*Audit Status*/
INSERT INTO audit_status(audit_status)
VALUES
  ('Success'),
  ('Failed'),
  ('Pending'),
  ('Cancelled'),
  ('In Progress');

/*Categories*/
INSERT INTO categories(category_name)
VALUES
  ('Electronics'),
  ('Home & Living'),
  ('Apparel'),
  ('Sports'),
  ('Stationery'),
  ('Documents & Records'),
  ('Tools & Kits');

INSERT INTO components(component_name)
VALUES
  ('Authentication'),
  ('User Management'),
  ('Request Management'),
  ('Delivery Management'),
  ('GPS Tracking Device'),
  ('Dispute Management'),
  ('Inventory'),
  ('File Storage'),
  ('Notification Service'),
  ('Database'),
  ('API Services'),
  ('System Settings');

INSERT INTO delivery_type(delivery_type)
VALUES
  ('Internal Messenger'),
  ('Third-Party Land Courier'),
  ('Third-Party Water Courier'),
  ('Third-Party Air Courier');


INSERT INTO database_status(database_status)
VALUES
  ('Running'),
  ('Offline'),
  ('Recovering'),
  ('Maintenance'),
  ('Failed');

/*Departments*/
INSERT INTO departments(department_name)
VALUES
  ('Administration'),
  ('Human Resources'),
  ('Information Technology'),
  ('Finance'),
  ('Accounting'),
  ('Procurement'),
  ('Warehouse'),
  ('Operations'),
  ('Maintenance'),
  ('Sales'),
  ('Marketing');

INSERT INTO delivery_status (delivery_status)
VALUES
  ('Awaiting Pickup'),
  ('Picked Up'),
  ('In Transit'),
  ('Delayed'),
  ('Delivered'),
  ('Completed'),
  ('Lost');

INSERT INTO dispute_status(status_name)
VALUES 
  ('Open'),
  ('In Discussion'),
  ('Escalated'),
  ('Resolved'),
  ('Closed');

INSERT INTO dispute_types(dispute_type)
VALUES
  ('Damaged Item'),
  ('Missing Item'),
  ('Lost Package'),
  ('Delayed Delivery'),
  ('Wrong Delivery'),
  ('Tampered Package'),
  ('Incorrect Shipment'),
  ('Chain of Custody'),
  ('Others');

INSERT INTO events(event_name)
VALUES
  --Authentication
  ('User Login'),
  ('User Logout'),
  ('Invalid Login Attempt'),
  ('Account Locked'),
  ('Password Changed'),
  ('Password Reset Completed'),
  ('Session Expired'),
  ('Unauthorized Access Attempt'),
  ('Multi-factor Authentication Enabled'),
  ('Multi-factor Authentication Failed'),

  --User Management
  ('User Account Created'),
  ('User Account Updated'),
  ('User Account Deleted'),
  ('User Account Disabled'),
  ('User Account Enabled'),
  ('Role Assigned'),
  ('Role Removed'),
  ('Permission Updated'),
  ('Department Updated'),
  ('Employee Created'),
  ('Employee Updated'),
  ('Employee Removed'),

  --Request Management
  ('Request Submitted'),
  ('Request Approved'),
  ('Request Rejected'),
  ('Request Cancelled'),
  ('Request Updated'),
  ('Request Assigned to Handler'),
  ('Request Reopened'),
  ('Request Returned'),

  --Delivery Management
  ('Delivery Created'),
  ('Delivery Started'),
  ('Delivery Assigned'),
  ('Package Picked Up'),
  ('Package Delivered'),
  ('Delivery Delayed'),
  ('Delivery Cancelled'),
  ('Delivery Failed'),
  ('Delivery Completed'),

  --GPS Tracking Service
  ('GPS Tracking Started'),
  ('GPS Location Updated'),
  ('GPS Signal Lost'),
  ('GPS Signal Restored'),
  ('Messenger Check-in'),
  ('Messenger Check-out'),

  --Dispute Management
  ('Dispute Submitted'),
  ('Evidence Uploaded'),
  ('Evidence Upload Failed'),
  ('Chat Session Started'),
  ('Dispute Escalated'),
  ('Dispute Resolved'),
  ('Dispute Closed'),

  --Inventory
  ('Item Added'),
  ('Item Updated'),
  ('Item Deleted'),
  ('Stock Increased'),
  ('Stock Decreased'),
  ('Low Stock Detected'),
  ('Inventory Imported'),
  ('Inventory Exported'),
  ('Inventory Synchronization Failed'),

  --File storage
  ('File Uploaded'),
  ('File Downloaded'),
  ('File Deleted'),
  ('File Upload Failed'),
  ('Storage Quota Exceeded'),

  --Notification Service
  ('Email Sent'),
  ('SMS Sent'),
  ('Push Notification Sent'),
  ('Notification Failed'),
  ('Notification Queue Started'),

--Database
  ('Database Connected'),
  ('Database Connection Lost'),
  ('Connection Restored'),
  ('Backup Started'),
  ('Backup Completed'),
  ('Backup Failed'),
  ('Restore Started'),
  ('Restore Completed'),
  ('Query Timeout'),


--API Services
  ('API Started'),
  ('API Request Received'),
  ('API Response Sent'),
  ('API Timeout'),
  ('API Unavailable'),
  ('API Connection Restored'),

--System Settings
  ('Company Name Updated'),
  ('Logo Updated'),
  ('System Settings Updated'),
  ('Maintenance Mode Enabled'),
  ('Maintenance Mode Disabled'),
  ('Configuration Saved');

INSERT INTO issue_description (issue_type)
VALUES 
  ('Forgot Password'),
  ('Account Locked'),
  ('Wrong Permissions /  Roles'),
  ('Account Disabled'),
  ('Username Not Found'),
  ('Cannot Login'),
  ('Access Denied');



INSERT INTO incident_status (status_name)
VALUES 
  ('Reported'),
  ('Under Investigation'),
  ('Action Required'),
  ('Resolved'),
  ('Closed'),
  ('Cancelled');


INSERT INTO incident_types (incident_type)
VALUES
  ('Lost Package'),
  ('Delay / Stranded Shipment');

INSERT INTO issue_status(issue_status)
VALUES
  ('Open'),
  ('In Progress'),
  ('Resolved'),
  ('Closed');

INSERT INTO notification_types (type_name)
VALUES
  ('Request'),
  ('Approval'),
  ('Assignment'),
  ('Delivery'),
  ('Dispute'),
  ('Incident'),
  ('Chat'),
  ('Account'),
  ('System'),
  ('Database');


INSERT INTO offices (office_name)
VALUES 
  ('Main Office'),
  ('Administration Office'),
  ('Information Technology Office'),
  ('Warehouse'),
  ('Operations Office');

INSERT INTO packaging(packaging_type)
VALUES
  ('No preference - let Handler decide'),
  ('Bubble Wrap'),
  ('Bubble Wrap with Box'),
  ('Box'),
  ('Plastic Bag'),
  ('Envelope');

INSERT INTO priority (priority_category)
VALUES
  ('Critical'),
  ('High'),
  ('Normal'),
  ('Low');


--Pipeline
INSERT INTO request_pipeline(pipeline_name, pipeline_order)
VALUES
  ('Submitted', 1),
  ('Approved', 2),
  ('Inventory Collection', 3),
  ('Quality Control', 4),
  ('Packing', 5),
  ('Ready for Pickup', 6),
  ('Picked Up', 7),
  ('In Transit', 8),
  ('Delivered', 9),
  ('Completed', 10);
 

INSERT INTO quality_control_result (result_name)
VALUES
  ('Pass'),
  ('Failed');
  
--Roles
INSERT INTO roles (role_name)
VALUES
  ('IT Admin'),
  ('Supervisor'),
  ('Requester'),
  ('Handler'),
  ('Messenger'),
  ('Receiver');

INSERT INTO severity (severity)
VALUES 
  ('Info'),
  ('Warning'),
  ('Error'),
  ('Critical');

INSERT INTO system_status (system_status)
VALUES 
  ('Running'),
  ('Maintenance'),
  ('Offline'),
  ('Starting'),
  ('Stopping');

INSERT INTO units (unit_name)
VALUES 
  ('Piece'),
  ('Box'),
  ('Set'),
  ('Pack'),
  ('Pair'),
  ('Unit');



















  


































  
  


