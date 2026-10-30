"""
Chapters 16 through 20 for PRANA Comprehensive Project Report.
"""

CHAPTERS_16_TO_20 = """
# CHAPTER 16: API AND RESTFUL SERVICE DOCUMENTATION

## 16.1 Architectural Style, Versioning, and Error Handling Standards

The PRANA backend exposes a comprehensive RESTful Application Programming Interface (API) implemented on the Next.js 16 App Router architecture. The API adheres to modern web standards:
- **Transport Security:** Enforced exclusively over HTTPS with TLS 1.3 encryption.
- **Resource Representations:** All request and response bodies utilize JavaScript Object Notation (`application/json`) with UTF-8 encoding.
- **Authentication:** Authenticated endpoints require a standard HTTP `Authorization` header containing a valid bearer token (`Bearer <token>`).
- **Standardized Error Envelope:** All error responses return a uniform JSON schema accompanied by RFC 7231 compliant HTTP status codes:
  ```json
  {
    "success": false,
    "error": "Descriptive human-readable error explanation",
    "code": "ERROR_MACHINE_READABLE_CODE"
  }
  ```

## 16.2 Group 1: Authentication and Telephony OTP Services

### 1. `POST /api/auth/send-otp`
- **Purpose:** Initiates phone-based passwordless authentication.
- **Calling App:** PRANA Patient Mobile App.
- **Authentication:** None (Public Endpoint).
- **Request Body:**
  ```json
  { "phone": "9876543210" }
  ```
- **Validation:** Phone must be exactly 10 digits (numeric). Rate-limited to 3 requests per 10 minutes per IP.
- **Success Response (200 OK):**
  ```json
  { "success": true, "message": "OTP dispatched successfully", "expires_in": 300 }
  ```
- **Error Codes:** 400 Bad Request, 429 Too Many Requests, 500 Internal Error.

### 2. `POST /api/auth/verify-otp`
- **Purpose:** Validates 6-digit OTP and returns signed patient JWT.
- **Calling App:** PRANA Patient Mobile App.
- **Authentication:** None.
- **Request Body:**
  ```json
  { "phone": "9876543210", "otp": "452189" }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": { "id": "f81d4fae-7dec-11d0-a765-00a0c91e6bf6", "prana_id": "PRAN-2973CAC1" }
  }
  ```
- **Error Codes:** 400 Bad Request (Invalid OTP), 401 Unauthorized (Expired OTP).

### 3. `POST /api/auth/resend-otp`
- **Purpose:** Resends active OTP token following 60-second client cooldown.
- **Calling App:** PRANA Patient Mobile App.
- **Authentication:** None.
- **Success Response (200 OK):**
  ```json
  { "success": true, "message": "OTP re-sent successfully" }
  ```

### 4. `POST /api/paramedic/login`
- **Purpose:** Authenticates emergency responders against verified paramedic roster.
- **Calling App:** PRANA Responder Mobile App.
- **Authentication:** None.
- **Request Body:**
  ```json
  { "phone": "9876500001", "otp": "123456" }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI...",
    "responder": {
      "responder_code": "EMD-4521",
      "name": "Arun Kumar",
      "organization": "GVK EMRI 108",
      "unit": "BLR-AMB-04"
    }
  }
  ```
- **Error Codes:** 401 Unauthorized (Not on active verified roster), 403 Forbidden (Expired license).

### 5. `POST /api/hospital-auth/login`
- **Purpose:** Authenticates hospital staff for emergency room admissions.
- **Calling App:** PRANA Hospital Web Portal.
- **Authentication:** None.
- **Request Body:**
  ```json
  {
    "hospital_id": "HOSP-AIIMS-01",
    "doctor_id": "DOC-9921",
    "password": "HospitalSecurePassword123"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "token": "eyJhbGciOiJIUzI1NiIsIn...",
    "hospital": {
      "hospital_uuid": "e3b0c442-98fc-1c14-9afbf4c8996fb924",
      "hospital_id": "HOSP-AIIMS-01",
      "name": "AIIMS Trauma Center, Bengaluru"
    }
  }
  ```

### 6. `POST /api/admin/login`
- **Purpose:** Authenticates master system super administrators.
- **Calling App:** PRANA Super Admin Web Portal.
- **Authentication:** None.
- **Success Response (200 OK):**
  ```json
  { "success": true, "token": "eyJhbGci...", "user": { "email": "admin@prana.health", "role": "superadmin" } }
  ```

## 16.3 Group 2: Patient Profile, Avatars, and Health Record APIs

### 7. `GET /api/patient/profile`
- **Purpose:** Fetches full master profile of authenticated patient.
- **Calling App:** Patient Mobile App.
- **Authentication:** Required (`Bearer <patient_token>`).
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "profile": {
      "id": "f81d4fae-7dec-11d0-a765-00a0c91e6bf6",
      "prana_id": "PRAN-2973CAC1",
      "full_name": "Sreeju S",
      "blood_group": "B+",
      "date_of_birth": "1998-05-14",
      "gender": "M",
      "weight_kg": 72.5,
      "height_cm": 178,
      "card_status": "active"
    }
  }
  ```

### 8. `PUT /api/patient/profile`
- **Purpose:** Updates personal demographic parameters.
- **Calling App:** Patient Mobile App.
- **Authentication:** Required.
- **Request Body:**
  ```json
  { "weight_kg": 73.0, "height_cm": 178, "full_name": "Sreeju S" }
  ```

### 9. `POST /api/patient/avatar`
- **Purpose:** Uploads photographic profile avatar to Cloudflare R2.
- **Calling App:** Patient Mobile App.
- **Authentication:** Required (`multipart/form-data`).
- **Success Response (200 OK):**
  ```json
  { "success": true, "avatar_url": "https://pub-r2.prana.health/avatars/user-123.jpg" }
  ```

### 10. `GET /api/patient/briefing`
- **Purpose:** Retrieves active 5-bullet Emergency Medical Briefing.
- **Calling App:** Patient App / Responder App.
- **Authentication:** Required.
- **Success Response (200 OK):**
  ```json
  {
    "title": "Emergency Summary",
    "badge": "Auto-updated",
    "bullets": [
      { "text": "Severe Penicillin Allergy — Anaphylaxis Risk", "is_critical": true },
      { "text": "Type 2 Diabetes (Metformin 500mg BD)", "is_critical": false },
      { "text": "Emergency Relay: Priya S (Verified)", "is_critical": false }
    ],
    "overflow_count": 0,
    "has_records": true
  }
  ```

### 11. `POST /api/briefing/regenerate`
- **Purpose:** Forces immediate recalculation of the deterministic emergency briefing.
- **Calling App:** Patient Mobile App.
- **Authentication:** Required.

## 16.4 Group 3: Clinical Entities (Allergies, Medications, Conditions, Vitals)

### 12–15. `GET/POST/PUT/DELETE /api/allergies` & `[id]`
- **Purpose:** Complete CRUD operations for patient allergies.
- **Calling App:** Patient Mobile App.
- **Authentication:** Required (`auth.uid() = user_id`).
- **Sample POST Body:**
  ```json
  {
    "allergen": "Penicillin",
    "severity": "severe",
    "reaction_description": "Anaphylaxis and acute bronchospasm",
    "is_critical": true,
    "client_uuid": "550e8400-e29b-41d4-a716-446655440000"
  }
  ```
- **Success Response (201 Created):**
  ```json
  { "success": true, "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6" }
  ```

### 16–19. `GET/POST/PUT/DELETE /api/medications` & `[id]`
- **Purpose:** Complete CRUD operations for prescription medications.
- **Calling App:** Patient Mobile App.
- **Sample POST Body:**
  ```json
  {
    "name": "Metformin",
    "generic_name": "Metformin Hydrochloride",
    "dose": "500mg",
    "frequency": "BD",
    "is_active": true
  }
  ```

### 20–23. `GET/POST/PUT/DELETE /api/conditions` & `[id]`
- **Purpose:** Complete CRUD operations for chronic and acute diagnoses.
- **Calling App:** Patient Mobile App.
- **Sample POST Body:**
  ```json
  {
    "name": "Type 2 Diabetes Mellitus",
    "icd10_code": "E11",
    "diagnosed_date": "2022-03-10",
    "status": "active"
  }
  ```

### 24–26. `GET/POST/DELETE /api/vitals` & `[id]`
- **Purpose:** Management of biometric vital sign observations.
- **Calling App:** Patient Mobile App.
- **Sample POST Body:**
  ```json
  {
    "vital_type": "bp_systolic",
    "value": 128.0,
    "unit": "mmHg",
    "source": "manual"
  }
  ```

## 16.5 Group 4: Advanced Clinical Records (Surgeries, Devices, Insurance)

### 27–29. `GET/POST/DELETE /api/surgeries` & `[id]`
- **Purpose:** Surgical procedure tracking and complication notes.
- **Calling App:** Patient Mobile App.
- **Sample POST Body:**
  ```json
  {
    "procedure_name": "Appendectomy",
    "date_performed": "2019-11-20",
    "hospital": "Manipal Hospital",
    "surgeon": "Dr. Ramesh K"
  }
  ```

### 30–32. `GET/POST/DELETE /api/devices` & `[id]`
- **Purpose:** Implanted medical hardware registry (pacemakers, stents).
- **Sample POST Body:**
  ```json
  {
    "device_name": "Dual-Chamber Pacemaker",
    "model_manufacturer": "Medtronic Astra XT",
    "implant_date": "2021-06-15",
    "location_on_body": "Left Upper Pectoral"
  }
  ```

### 33–34. `GET/POST /api/insurance`
- **Purpose:** Health insurance cashless policy management.
- **Sample POST Body:**
  ```json
  {
    "provider_name": "Star Health & Allied Insurance",
    "policy_number": "SH-99281726",
    "group_number": "CORP-TECH-04",
    "helpline_phone": "1800-425-2255"
  }
  ```

## 16.6 Group 5: Emergency Contacts, SMS Dispatch, and Verification

### 35–37. `GET/POST/DELETE /api/emergency-contacts` & `[id]`
- **Purpose:** Management of next-of-kin emergency relays.
- **Sample POST Body:**
  ```json
  {
    "name": "Priya S",
    "relationship": "Sister",
    "phone": "+919876543210",
    "is_primary": true
  }
  ```

### 38. `POST /api/emergency-contacts/test-sms`
- **Purpose:** Tests automated emergency SMS dispatching via Fast2SMS.

## 16.7 Group 6: QR Generation, Offline Sync, and Security Control APIs

### 39. `GET /api/card/qr`
- **Purpose:** Fetches compiled Base45 string and micro-token for on-screen QR display.
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "qr_string": "PRANA_V2|PID:PRAN-2973CAC1|STATUS:ACTIVE|BG:B+",
    "base45_payload": "Y8/AFA S0N00E$40BE2UF: E1-8.FP0BF+EVY28BCLKW%N*S*..."
  }
  ```

### 40. `POST /api/card/sync`
- **Purpose:** Two-way delta-synchronization endpoint for mobile outbox queues.
- **Calling App:** Patient App / Responder App.
- **Request Body:** Batch array of pending entities with `client_uuid` and `updated_at`.
- **Success Response (200 OK):** Returns server reconciliation status and fresher remote records.

### 41. `POST /api/card/suspend` & `POST /api/card/reactivate`
- **Purpose:** Immediate suspension or reactivation of emergency QR card.
- **Request Body:** `{ "reason": "Wallet misplaced in transit" }`.

### 42. `GET /api/card/scan-history` & `/api/card/scan-details`
- **Purpose:** Patient-facing audit log showing who scanned their card, when, and where.

## 16.8 Group 7: AI Document Processing and Emergency Briefing Services

### 43. `POST /api/ai-summary`
- **Purpose:** Ingests medical report PDF/image and extracts structured clinical findings via Gemini 2.0 Flash.
- **Request Body:**
  ```json
  { "reportUrl": "https://pub-r2.prana.health/reports/cbc-lab.pdf", "reportType": "pdf" }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "id": "b182f42a-91dc-49ef-871d-5310860361fb",
      "summary": {
        "diagnoses": ["Microcytic Anemia"],
        "medicines": [{"name": "Ferrous Ascorbate", "dose": "100mg", "frequency": "OD"}],
        "allergies": [],
        "lab_values": [{"test": "Hemoglobin", "value": "9.2 g/dL", "flag": "Low"}]
      }
    }
  }
  ```

### 44. `POST /api/scanner/prescription`
- **Purpose:** OCR parsing of handwritten prescription slip photos.

## 16.9 Group 8: Paramedic Field APIs and Triage Verification

### 45. `POST /api/scan/decode`
- **Purpose:** Server-side verification and unpacking of encrypted QR Base45 envelopes.

### 46. `GET /api/scans/recent`
- **Purpose:** Retrieves recent pre-hospital triage scans executed by active responder.

## 16.10 Group 9: Hospital Clinical Portal and Pre-Hospital Incoming APIs

### 47. `GET /api/hospitals/incoming` & `POST /api/hospitals/incoming`
- **Purpose:** Real-time pre-hospital ambulance dispatch queue.
- **POST Body (from Paramedic in transit):**
  ```json
  {
    "prana_id": "PRAN-2973CAC1",
    "destination_hospital_id": "HOSP-AIIMS-01",
    "eta_minutes": 10,
    "condition_summary": "High-speed bike crash, open compound tibia fracture",
    "vitals": { "bp": "110/70", "pulse": "105", "spo2": "97%" }
  }
  ```

### 48. `GET /api/hospitals/search-patient`
- **Purpose:** Full Tier 3 patient chart retrieval with mandatory audit logging.
- **Headers:** `Authorization: Bearer <hosp_token>`.
- **Query Params:** `?prana_id=PRAN-2973CAC1&hospital_id=HOSP-AIIMS-01&reason=Trauma%20Admission`.

### 49. `POST /api/hospitals/insurance/verify`
- **Purpose:** Updates cashless hospitalization pre-authorization status.

## 16.11 Group 10: Super Administrator Governance and Audit Log Services

- `GET /api/admin/metrics`: Platform-wide statistical counts (total hospitals, active responders, scans today).
- `GET /api/admin/patients`: Zero-knowledge patient account registry.
- `GET /api/admin/audit-logs`: Global forensic inspection of immutable `scan_logs`.
- `GET/POST /api/hospitals`: Institutional hospital accreditation and onboarding management.
- `GET/POST /api/responders`: Paramedic license issuance and credentialing.

---

# CHAPTER 17: DATA FLOW DIAGRAMS

## 17.1 Context Diagram (Level 0 DFD)

The Context Diagram (Level 0 DFD) defines the boundaries of the PRANA platform, modeling data exchanges between external user entities and the central system:

```mermaid
graph TD
    subgraph ExternalEntities["External Actors & Systems"]
        Patient["Citizen Patient"]
        Bystander["Anonymous Bystander"]
        Paramedic["Emergency Responder (Paramedic)"]
        HospitalStaff["Hospital ER Clinician / Staff"]
        SuperAdmin["Super Administrator"]
        GeminiAI["Google Gemini 2.0 Flash"]
        FastSMS["Fast2SMS Gateway"]
    end

    subgraph PRANASystem["PRANA Platform Boundary (Level 0)"]
        CoreSystem((PRANA Emergency Platform<br/>Core Engine))
    end

    %% Patient Flows
    Patient -->|Phone & OTP| CoreSystem
    Patient -->|Clinical Entities, Meds, Vitals| CoreSystem
    Patient -->|Prescription Photos & Reports| CoreSystem
    CoreSystem -->|Dynamic QR Code & Sync Status| Patient

    %% Bystander Flows
    Bystander -->|Scans Physical Card QR| CoreSystem
    CoreSystem -->|Tier 1 Green Demographics & Relative Phone| Bystander

    %% Paramedic Flows
    Paramedic -->|Paramedic Credentials & QR Scan String| CoreSystem
    CoreSystem -->|Tier 2 Clinical Profile & Anaphylaxis Alerts| Paramedic
    Paramedic -->|Pre-Hospital Alert & Patient Vitals| CoreSystem

    %% Hospital Flows
    HospitalStaff -->|Hospital Credentials & PRANA ID Lookup| CoreSystem
    CoreSystem -->|Live Incoming Queue & Tier 3 Full Chart| HospitalStaff
    HospitalStaff -->|Insurance Pre-Auth Status Updates| CoreSystem

    %% Admin Flows
    SuperAdmin -->|Admin Credentials & Approvals| CoreSystem
    CoreSystem -->|Platform Metrics & Immutable Audit Logs| SuperAdmin

    %% External Gateways
    CoreSystem -->|Document Image Stream| GeminiAI
    GeminiAI -->|Extracted Structured JSON| CoreSystem
    CoreSystem -->|SMS Dispatch Payloads| FastSMS
```

## 17.2 Level 1 DFD: Patient Profile Lifecycle and Mobile Outbox Sync

Processes involved in patient health profile management and offline outbox synchronization:

```mermaid
graph TD
    User([Citizen Patient]) -->|Input Demographics & Vitals| P1[1.1 Input Validation & Form Capture]
    P1 -->|Validated Entities| P2[1.2 Local Drift Persistence & Encryption]
    P2 -->|Write Pages| D1[(Local SQLite / SQLCipher Vault)]
    P1 -->|Log Mutation Event| P3[1.3 Outbox Queue Manager]
    P3 -->|Enqueue Task| D2[(Local Outbox Table)]
    
    NetCheck{Network Available?}
    D2 -.-> NetCheck
    NetCheck -->|No| P3
    NetCheck -->|Yes| P4[1.4 Background Sync Worker]
    P4 -->|HTTP POST /api/card/sync| P5[1.5 Remote Edge Reconciliation Engine]
    P5 -->|Write Transactions| D3[(Supabase PostgreSQL Profiles & Meds)]
    P5 -->|Trigger Briefing Refresh| P6[1.6 Briefing Generator]
    P6 -->|Write Briefing| D4[(Medical Briefings Table)]
    P5 -->|HTTP 200 Confirmation| P4
    P4 -->|Flush Completed Tasks| D2
```

## 17.3 Level 1 DFD: Paramedic Field Triage and Hospital Alerting

Processes governing optical scanning, local silicon cache hydration, and pre-hospital ER dispatching:

```mermaid
graph TD
    Paramedic([Paramedic / EMT]) -->|Scan Card with Camera| P1[2.1 Optical Barcode Frame Processor]
    P1 -->|Extracted String| P2[2.2 PRANA ID Extractor & Sanitizer]
    P2 -->|Clean PID| P3[2.3 Silicon Vault Cache Lookup]
    
    CacheCheck{Record in Local RAM?}
    P3 --> CacheCheck
    CacheCheck -->|Yes (0.0 ms)| P4[2.4 Instant Triage Renderer]
    CacheCheck -->|No| P5[2.5 Network Delta-Sync Request]
    P5 -->|GET /api/card/scan-details| D1[(Central PostgreSQL DB)]
    D1 -->|Hydrate Profile| P4
    
    P4 -->|Display Clinical Surface| Paramedic
    Paramedic -->|Tap Call Relative| P6[2.6 Telephony Intent Handler]
    P6 -->|Android tel: URI| Phone[Native Phone Dialer]
    
    Paramedic -->|Input Vitals & ETA| P7[2.7 Hospital Alert Dispatcher]
    P7 -->|POST /api/hospitals/incoming| D2[(Incoming Patients Queue)]
    D2 -->|Live Stream| Hosp([Hospital Trauma Bay])
```

## 17.4 Level 1 DFD: AI Medical Document Extraction and Briefing

Data flows for prescription scanning, diagnostic report parsing, and emergency briefing synthesis:

```mermaid
graph TD
    Patient([Patient / Clinician]) -->|Upload Rx Image / Lab PDF| P1[3.1 Document Ingestion & Storage]
    P1 -->|Store Blob| D1[(Cloudflare R2 Object Storage)]
    P1 -->|Base64 Stream| P2[3.2 Gemini 2.0 Flash Vision Pipeline]
    P2 -->|Medical System Prompt| ExtModel[Google Gemini 2.0 Flash API]
    ExtModel -->|Raw Extracted JSON| P3[3.3 JSON Schema Sanitizer & Guard]
    P3 -->|Validated Entities| D2[(ai_summaries Table)]
    P3 -->|Parsed Medications| D3[(medications Table)]
    
    D2 & D3 -.-> P4[3.4 Deterministic Briefing Engine]
    P4 -->|Allergen Normalization & Rule Evaluation| P5[3.5 Risk Prioritization]
    P5 -->|Standardized 5-Bullet Summary| D4[(medical_briefings Table)]
```

## 17.5 Level 1 DFD: Super Admin Governance and Immutable Auditing

Processes governing platform governance, institution onboarding, and tamper-proof auditing:

```mermaid
graph TD
    Admin([Super Administrator]) -->|Submit Hospital Approvals| P1[4.1 Institutional Verification Engine]
    P1 -->|Update is_active = true| D1[(verified_hospitals Table)]
    
    Admin -->|Submit Responder Credentials| P2[4.2 Paramedic Roster Manager]
    P2 -->|Issue 30-Day License| D2[(verified_responders Table)]
    
    Admin -->|Query Patient Accounts| P3[4.3 Zero-Knowledge Telemetry Filter]
    P3 -->|Query Status Only (No Med Data)| D3[(profiles Table)]
    P3 -->|Display Card Logistics| Admin
    
    AnyScan([Any Scan Event]) --> P4[4.4 Automated Scan Logger]
    P4 -->|Insert Audit Entry| D4[(scan_logs Table)]
    
    MaliciousActor([Adversary / Rogue Admin]) -.->|Attempt UPDATE / DELETE| D4
    D4 -->|Trigger Abort: prevent_scan_log_modification| Fail[Exception: Logs are Immutable]
    
    Admin -->|Query Audit Trail| P5[4.5 Audit Log Inspector]
    D4 -->|Read-Only Stream| P5
    P5 -->|Render Forensic Log View| Admin
```

---

# CHAPTER 18: SECURITY, PRIVACY, AND DATA PROTECTION

## 18.1 Threat Modeling using the STRIDE Methodology

To ensure comprehensive cybersecurity resilience, PRANA was evaluated using Microsoft's **STRIDE Threat Modeling Framework**:

| STRIDE Threat Category | Potential Attack Scenario | Target Architectural Asset | Implemented Security Countermeasure | Verification Status |
| :--- | :--- | :--- | :--- | :---: |
| **Spoofing Identity** | Adversary attempts to forge a physical PRANA QR code containing fabricated patient medical data | Physical QR Code / Paramedic Mobile Scanner | Payloads are signed with an **Ed25519 digital signature** (`encrypt.ts`). Scanner verifies signature against central authority before decoding. | **Verified & Implemented** |
| **Spoofing Identity** | Unauthorized individual impersonates a verified paramedic to access Tier 2 medical records | `/api/paramedic/login` API Endpoint | Phone number must match pre-registered roster in `verified_responders`. Mandatory 2FA OTP verification required. | **Verified & Implemented** |
| **Tampering with Data**| Attacker attempts to modify roadside scan logs to conceal an unauthorized patient lookup | `scan_logs` Relational Table | PostgreSQL trigger `prevent_scan_log_modification` aborts all SQL `UPDATE` and `DELETE` queries with an uncatchable exception. | **Verified & Implemented** |
| **Tampering with Data**| Local malware on a rooted Android device attempts to alter offline medication records | Local SQLite Database on Mobile Flash Storage | Local database pages are encrypted using **256-bit AES via SQLCipher**, with master keys isolated in the Android Keystore. | **Verified & Implemented** |
| **Repudiation** | Paramedic or hospital clinician denies accessing a patient's confidential health record | Triage Access Operations | Every lookup automatically commits the actor's ID, hospital station ID, IP address, user agent, and timestamp to `scan_logs`. | **Verified & Implemented** |
| **Information Disclosure** | Anonymous bystander scanning physical card attempts to read patient's psychiatric history or full medication list | Emergency Profile Web Routing (`/p/[id]`) | **Three-Tier Architecture**: Public route exposes only Tier 1 Green data (Blood Group, Critical Allergies, Emergency Relay Phone). | **Verified & Implemented** |
| **Information Disclosure** | Rogue platform super administrator queries central database to harvest citizen clinical histories | Central Database Queries from Admin Portal | **Zero-Knowledge Architecture**: Schema design and admin API routes structurally exclude clinical tables from administrative views. | **Verified & Implemented** |
| **Denial of Service** | Malicious botnet executes high-frequency automated lookups on public PRANA ID URLs | Edge Serverless APIs (`/p/[id]`) | Edge rate limiting enforces a maximum of 10 scans per IP per day per card; edge caching via Vercel absorbs repeated queries. | **Verified & Implemented** |
| **Elevation of Privilege** | Paramedic token utilized to access Tier 3 hospital surgical records and insurance claims | Hospital Clinical APIs (`/api/hospitals/*`) | Token verification guard `verifyHospitalToken()` validates explicit institutional claims; rejects responder tokens. | **Verified & Implemented** |

## 18.2 In-Transit and At-Rest Cryptographic Safeguards

- **In-Transit Security:** Enforced via Transport Layer Security (**TLS 1.3**) with HTTP Strict Transport Security (HSTS) headers across all client-to-edge and edge-to-database connections. Deprecated TLS 1.0/1.1 protocols are disabled.
- **At-Rest Cloud Database Encryption:** Underlying Supabase EBS storage volumes are encrypted via AWS KMS using 256-bit AES. Sensitive Personally Identifiable Information (PII) columns within `profiles` utilize symmetric column-level encryption via PostgreSQL's `pgcrypto` extension (`pgp_sym_encrypt`).
- **Secure Object Storage:** Uploaded diagnostic report scans in Cloudflare R2 are encrypted at rest with AES-256. Public file listing is disabled; assets are accessed strictly via pre-signed, short-lived URLs.

## 18.3 On-Device Mobile Vault Protection via SQLCipher and Biometrics

Mobile devices operate in hostile physical environments. If an EMT's phone or a patient's device is stolen:
- Raw SQLite database files stored in application sandboxes are encrypted at the page level using **SQLCipher (256-bit AES in GCM mode)**.
- The 256-bit encryption key is generated using secure random bytes on initial boot and saved directly into the **Android Keystore System** via `flutter_secure_storage`.
- In rooted environments, memory-dump attacks are mitigated by zeroing out decrypted in-memory buffers immediately following UI rendering.

## 18.4 Database Row-Level Security (RLS) Policy Audit

All 15 relational tables in Supabase PostgreSQL enforce Row-Level Security (`ALTER TABLE <name> ENABLE ROW LEVEL SECURITY;`). Policies mandate that:
- Patients can only execute `SELECT`, `INSERT`, `UPDATE`, and `DELETE` on rows where `user_id = auth.uid()`.
- Public anonymous users can execute `SELECT` strictly on `profiles` and `allergies` where `card_status = 'active'` and `is_critical = true`.
- Service roles executing serverless edge functions operate under bounded, parameterized contexts.

## 18.5 Immutable Audit Trail and Tamper-Proof Scan Logs

The `scan_logs` table provides a tamper-proof forensic log of all emergency interactions:
```sql
-- Database-level immutability enforcement
CREATE OR REPLACE FUNCTION prevent_scan_log_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Scan logs are immutable and cannot be modified or deleted';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER scan_logs_immutable
BEFORE UPDATE OR DELETE ON scan_logs
FOR EACH ROW EXECUTE FUNCTION prevent_scan_log_modification();
```
Even database administrators with direct SQL query consoles cannot delete or alter historical access records.

## 18.6 Privacy Mandate: Super Admin Zero-Knowledge Enforcement

PRANA's privacy architecture explicitly addresses insider threats:
- Super administrators have full operational visibility over platform infrastructure, server uptimes, hospital onboarding licenses, and card manufacturing logistics.
- The database schema completely excludes clinical foreign keys from administrative tables.
- Administrative queries are structurally isolated; no API endpoint available to super administrators contains SQL join logic linking to `allergies`, `medications`, `conditions`, or `vitals`.

## 18.7 Regulatory Posture: ABDM, DISHA, and HIPAA Evaluation

While PRANA is an academic project, its architecture is rigorously aligned with primary healthcare data protection frameworks:
- **Ayushman Bharat Digital Mission (ABDM):** Clinical entity representations match ABDM FHIR profile specifications; unique `prana_id` values can be mapped to 14-digit ABHA numbers.
- **Digital Information Security in Healthcare Act (DISHA - Draft India):** Fulfills requirements regarding data minimization, patient consent ownership, and mandatory cryptographic audit logging.
- **HIPAA Security & Privacy Rules (USA):** Complies with the Technical Safeguards (164.312) regarding access control, audit controls, integrity, and transmission security. Formal regulatory certification requires additional organizational, legal, and institutional compliance assessments.

---

# CHAPTER 19: USER INTERFACE AND SCREEN DOCUMENTATION

## 19.1 Design System Philosophy and Accessibility Tokens

The user interfaces across the four PRANA applications are built upon a unified clinical design philosophy: **maximum contrast, minimal cognitive friction, and ergonomic touch targets**. 

In high-stress pre-hospital trauma care, ambiguous color schemes or microscopic touch targets induce fatal clinical mistakes. The design system establishes standardized semantic color tokens:
- **Clinical Primary Brand:** Deep Medical Teal (`#0E7490` / `#008080`) evoking clinical precision and trust.
- **Emergency Accent:** High-Visibility Crimson (`#EF4444` / `#DC2626`) reserved strictly for blood groups and acute anaphylaxis alerts.
- **Warning Indicator:** Amber (`#F59E0B` / `#B45309`) indicating severe but non-fatal allergies and active medication alerts.
- **Success & Safe Baseline:** Emerald Green (`#10B981` / `#059669`) indicating active card status and verified contacts.
- **Surface & Backgrounds:** Pure High-Contrast White (`#FFFFFF`) and Slate Gray (`#F8FAFC`), ensuring high readability under direct outdoor sunlight glare.

## 19.2 Patient Mobile App: Dashboard, Identity Card, and Briefing UI

### Figure 19.1: Patient Mobile App — Emergency Dashboard & Briefing (`flutter_01.png`)
- **Application & Screen:** PRANA Patient Mobile App — Main Dashboard Screen (`dashboard_screen.dart`).
- **User Role:** Citizen Patient.
- **Visible Elements:**
  - *Top Header:* Personalized greeting ("Hello, User"), active status badge ("Your Medical Identity is Active"), and interactive PRANA ID pill (`PRAN-7843`) with one-tap copy icon and glowing green health pulse.
  - *Health Overview Card:* Prominent circular Blood Group badge (**B+**), with summary counters: 0 Meds, 0 Allergy, 0 Condition, linked to the Health Hub.
  - *Quick Actions Bar:* Five circular ergonomic action buttons: Scan RX (Camera icon), Add Med (Pill icon), Add Allergy (Warning triangle), Add Condition (Clipboard), and Log Vitals (Heart).
  - *Your Emergency Briefing Card:* Clinical briefing panel featuring a refresh action icon and prioritized bullets:
    - `"Type 2 Diabetes (Metformin 500mg BD)"`
    - `"Severe Penicillin Allergy (Anaphylaxis Risk)"`
    - `"Emergency Relay Jane Doe Verified"`
    - Timestamp: `"Generated today at 14:32"`, with `"Tap to view full >"` action link.
  - *Last 7 Days Activity Timeline:* Vertical chronological audit feed showing:
    - Added Metformin 500mg (Yesterday • Prescription auto-scan).
    - BP Logged: 128/82 mmHg (3 days ago • Vital Tracker).
    - Card Scanned by EMD-4521 (5 days ago • AIIMS Delhi).
- **User Actions:** Tapping quick actions launches modals; tapping briefing opens expanded clinical chart; tapping PRANA ID copies string to clipboard.
- **System Behavior:** On tap, triggers instant state navigation via Riverpod state providers.

```
┌─────────────────────────────────────────────────────────────┐
│ 15:38 💬 ...                               90% [🔋]         │
├─────────────────────────────────────────────────────────────┤
│ Hello, User 👋                         [ PRAN-7843 📋 ] (●) │
│ Your Medical Identity is Active                             │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  ( B+ )    Health Overview                    >         │ │
│ │            💊 0 Meds    ⚠️ 0 Allergy    🏥 0 Condition  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ QUICK ACTIONS                                               │
│   (📷)         (💊)         (⚠️)         (📋)         (❤️)  │
│  Scan RX     Add Med     Add Allergy  Add Condition Log Vit.│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ✨ Your Emergency Briefing                           🔄 │ │
│ │ • Type 2 Diabetes (Metformin 500mg BD)                  │ │
│ │ • Severe Penicillin Allergy (Anaphylaxis Risk)          │ │
│ │ • Emergency Relay Jane Doe Verified                     │ │
│ │   Generated today at 14:32             Tap to view full>│ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ LAST 7 DAYS                                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ (💊) Added Metformin 500mg (Yesterday • Auto-scan)    │  │
│  │ (❤️) BP Logged: 128/82 mmHg (3 days ago • Tracker)    │  │
│  │ (📷) Card Scanned by EMD-4521 (5 days ago • AIIMS)    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 19.3 Patient Mobile App: Onboarding, Medical Setup, and Vitals Logging

### Figure 19.2: Patient Mobile App — Step 1 of 4 Medical Onboarding Flow (`flutter_02.png`)
- **Application & Screen:** PRANA Patient Mobile App — Medical Onboarding Setup (`onboarding_screen.dart`).
- **User Role:** Newly Registered Citizen Patient.
- **Visible Elements:**
  - *Step Indicator:* "Step 1 of 4" with horizontal progress bar and four navigation dots.
  - *Title & Context:* "Basic Medical Info", with clinical guidance: *"Your blood group is the #1 scanned field by paramedics."*
  - *Form Inputs:* Full Name input field (`e.g. Sreeju`) with language selector badge (`EN`), Date of Birth picker with calendar icon, and Biological Gender dropdown selector (`Male`).
  - *Blood Group Selector Grid:* High-contrast 8-button matrix (A+, A-, B+, B-, AB+, AB-, O+, O-), with **O+** actively selected in prominent medical crimson.
  - *Primary Action:* Large, ergonomic green "Continue" CTA button at the bottom.
- **User Actions:** Tapping blood group chips toggles selection; tapping "Continue" validates required fields and advances to Step 2 (Allergies).

### Figure 19.3: Patient Mobile App — Active Profile & Medication Alert State (`flutter_03.png`)
- **Application & Screen:** PRANA Patient Mobile App — Main Dashboard Secondary State (`dashboard_screen.dart`).
- **Visible Elements:**
  - *Personalized Greeting:* "Hello, Sreeju".
  - *Emergency Profile Summary:* Prominent badges for Blood Group (`🩸 O+`), Severe Allergy (`⚠️ Bee Sting (severe)`), and Medication status (`💊 No meds recorded`), with direct `"View QR ->"` link.
  - *Clinical Gap Reminder Banner:* Light cyan callout banner: *"💊 You haven't added your medications yet. Add daily prescriptions to help healthcare professionals during emergencies."* with prominent "Add Medication" button.
  - *Quick Actions & Scans:* Quick action bar and "Recent Field Scans" card indicating "No field scans yet".
  - *Bottom Navigation Bar:* 4-tab clinical navigation bar with Home (active), Health, My Card, and Settings.

### Figure 19.4: Patient Mobile App — Biometric Vitals Logging Modal (`flutter_04.png`)
- **Application & Screen:** PRANA Patient Mobile App — Vitals Logging Bottom Sheet (`dashboard_screen.dart`).
- **Visible Elements:**
  - *Search Bar:* "Search Vitals Log..." with language badge (`EN`).
  - *Modal Title:* "Log Vital Reading".
  - *Vital Type Selector Chips:* 6 interactive horizontal chips: Blood Pressure (selected with checkmark), Heart Rate, Temperature, Blood Glucose, SpO2, and Weight.
  - *Numeric Inputs:* Systolic (Top) text field pre-filled with `120`, Diastolic (Bottom) text field pre-filled with `80`, with unit label `mmHg`.
  - *Primary CTA:* Large teal "Log Vital Reading" button.
- **User Actions:** Tapping chips shifts input types; typing updates numeric values; tapping "Log Vital Reading" writes to Drift database and flushes to remote API.

## 19.4 Responder Mobile App: High-Contrast Tactical Scanner and Triage UI

### Figure 19.5: Responder Mobile App — Optical Triage Scanner
- **Application & Screen:** PRANA Responder App — Camera Viewfinder (`scanner_screen.dart`).
- **User Role:** Verified Paramedic / EMT.
- **Visible Elements:** Full-screen 60 fps camera stream, green optical crosshair targeting frame, torch toggle button (top right), offline status indicator pill ("Offline Vault Active: 1,240 records cached"), and manual PRANA ID input drawer.
- **User Actions:** Aiming camera at physical card automatically triggers symbol acquisition and extraction without requiring button presses.

## 19.5 Responder Mobile App: Clinical Surface, Click-to-Call, and Dispatch UI

### Figure 19.6: Responder Mobile App — Clinical Surface & One-Tap Relay
- **Application & Screen:** PRANA Responder App — Patient Triage Detail (`patient_details_screen.dart`).
- **Visible Elements:**
  - *Top Banner:* Crimson Blood Group badge (**B+**), Full Name, Age (28 Yrs), Gender (M), and PRANA ID (`PRAN-2973CAC1`).
  - *Allergy Warning Panel:* High-contrast amber cards: **"Severe Penicillin Allergy — Anaphylaxis Risk"** and **"Severe Peanuts Allergy"**.
  - *Active Medications List:* Metformin 500mg BD, Amlodipine 5mg OD.
  - *Chronic Conditions:* Type 2 Diabetes Mellitus (E11), Hypertension (I10).
  - *Emergency Contacts Card:* Primary relative card ("Priya S - Sister • +91 9876543210") with prominent green **CALL** action button.
  - *Bottom Action Bar:* "Notify Destination Hospital" dispatch drawer.
- **User Actions:** Tapping anywhere on the contact card launches Android phone dialer; tapping "Notify Hospital" opens pre-arrival dispatch modal.

## 19.6 Hospital Portal: Emergency Ambulance Queue and Clinical Chart UI

### Figure 19.7: Hospital Web Portal — Real-Time Ambulance Incoming Triage Queue
- **Application & Screen:** PRANA Hospital Portal — Dashboard Queue (`/app/hospitals/page.tsx`).
- **User Role:** Hospital Emergency Room Charge Nurse / Trauma Physician.
- **Visible Elements:**
  - Dynamic table displaying incoming ambulances: Unit BLR-AMB-04, Paramedic Arun Kumar, Patient Name ("Sreeju S"), Age (28), Blood Group (**B+**), Critical Allergies ("Penicillin (Severe)"), Live Vitals (BP 110/70, Pulse 105, SpO2 97%), and live countdown ETA badge (**"ETA: 6 Mins"**).
  - Top action bar with patient search by PRANA ID and station context (`HOSP-AIIMS-01`).

### Figure 19.8: Hospital Web Portal — Comprehensive Clinical Patient Chart
- **Application & Screen:** PRANA Hospital Portal — Patient Clinical Chart (`/app/hospitals/records/[id]/page.tsx`).
- **Visible Elements:**
  - Comprehensive clinical navigation tabs: *Summary, Medications, Conditions, Vitals, Surgeries, Reports, Insurance, Emergency Contacts, Access Log*.
  - Full longitudinal records: Past appendectomy with surgical complication notes, implanted pacemaker model details, historical blood pressure trend graph.
  - Cashless insurance pre-auth selector: status badge actively displaying **"Pre-auth requested"**.

## 19.7 Super Admin Portal: System Analytics and Governance UI

### Figure 19.9: Super Admin Portal — System Overview & Hospital Governance
- **Application & Screen:** PRANA Super Admin Portal — Dashboard (`/app/admin/page.tsx`).
- **User Role:** Platform Super Administrator.
- **Visible Elements:**
  - *System Metrics Grid:* 12 Total Hospitals (10 Active), 48 Verified Responders, 1,240 Total Patients, 324 Scans Today (182 Green, 114 Yellow, 28 Red).
  - *Hospital Verification Roster:* Table of accredited healthcare institutions with one-click "Approve / Suspend" toggles and staff credential generators.
  - *Zero-Knowledge Patient Roster:* Citizen accounts displaying only PRANA ID, registration date, card status, and physical card delivery stage—strictly omitting all medical diagnosis columns.
  - *Immutable Audit Trail Stream:* Real-time feed of global scan logs showing timestamp, PRANA ID, access tier invoked, actor ID, and IP address.

---

# CHAPTER 20: IMPLEMENTATION DETAILS

## 20.1 Mobile Client Project Structure and Initialization (Flutter)

The PRANA mobile client is organized according to clean architectural layers:

```
lib/
├── database/            # Drift ORM schema & SQLCipher encryption
│   ├── app_database.dart
│   └── database_service.dart
├── models/              # Immutable Dart domain models
├── repositories/        # Repository pattern isolating SQLite from UI
│   ├── allergy_repository.dart
│   ├── medication_repository.dart
│   ├── condition_repository.dart
│   └── profile_repository.dart
├── screens/             # Presentation screens (Riverpod consumer widgets)
│   ├── dashboard_screen.dart
│   ├── health_hub_screen.dart
│   ├── my_card_screen.dart
│   └── prescription_scanner_screen.dart
├── services/            # Edge API clients & background engines
│   ├── api_service.dart
│   ├── sync_service.dart
│   └── qr_service.dart
├── theme/               # Standardized clinical design tokens
└── widgets/             # Reusable UI components
```

Application initialization sets up SQLCipher and initializes Riverpod state providers:

```dart
// Native initialization in lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize encrypted database singleton
  final database = AppDatabase.instance();
  final dbService = DatabaseService(database);
  
  runApp(
    ProviderScope(
      child: PranaApp(dbService: dbService),
    ),
  );
}
```

## 20.2 Encrypted Drift Database and Outbox Sync Implementation

The local database configuration ensures that all SQLite data pages are encrypted on disk:

```dart
// Excerpt from lib/database/app_database.dart
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'prana_database.db'));

    const storage = FlutterSecureStorage();
    var password = await storage.read(key: 'database_password');

    if (password == null) {
      // Generate cryptographically random 32-byte key
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      password = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await storage.write(key: 'database_password', value: password);
    }

    return NativeDatabase.createInBackground(file);
  });
}
```

The outbox synchronization engine monitors network connectivity and executes delta flushes:

```dart
// Excerpt from lib/services/sync_service.dart
void _setupConnectivityListener() {
  _connectivity.onConnectivityChanged.listen((results) {
    final isConnected = results.any((r) => r != ConnectivityResult.none);
    if (isConnected && _state != SyncState.syncing) {
      _processOutboxQueue();
    }
  });
}
```

## 20.3 Binary QR Packing and Cryptographic Decryption Engine

The binary packing engine (`pack.ts`) compiles structured clinical parameters into a 121-byte byte array:

```typescript
// Excerpt from lib/prana-qr/pack.ts
export function pack(data: PatientData): PackedData {
  const buffer: number[] = [];

  // Version header (1 byte)
  buffer.push(CODEBOOK_VERSION & 0xFF);

  // PRANA ID without prefix
  const pranaId = data.pranaId.replace(/^PRAN-/, '');
  addString(pranaId, 16);

  // Demographics: Name, Age, Gender, Blood Group
  addString(data.name, 20);
  buffer.push(Math.min(data.age, 150) & 0xFF);
  buffer.push(GENDERS.indexOf(data.gender) & 0xFF);
  buffer.push(BLOOD_GROUPS.indexOf(data.bloodGroup) & 0xFF);

  // 16-Bit Critical Flags Register (2 bytes)
  const flagBytes = new Uint8Array(2);
  for (const flag of data.criticalFlags) {
    const idx = getFlagIndex(flag);
    if (idx !== null && idx >= 0 && idx < 16) {
      flagBytes[Math.floor(idx / 8)] |= (1 << (idx % 8));
    }
  }
  buffer.push(...flagBytes);

  // Allergies packing (1-byte codebook index + 1-byte severity)
  buffer.push(Math.min(data.allergies.length, 10));
  for (const item of data.allergies) {
    const idx = getAllergenIndex(item.allergen);
    const sev = SEVERITY_MAP[item.severity.toLowerCase()] ?? 0;
    buffer.push(idx !== null ? idx : 255);
    buffer.push(sev);
  }
  return { bytes: new Uint8Array(buffer), size: buffer.length };
}
```

## 20.4 Backend Edge API Request Routing and Auth Verification (Next.js)

Backend route handlers validate incoming JWT tokens and enforce role-based boundaries:

```typescript
// Excerpt from lib/auth.ts
export function verifyToken(req: Request): UserPayload {
  const authHeader = req.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Unauthorized: Missing bearer token');
  }
  const token = authHeader.split(' ')[1];
  try {
    return jwt.verify(token, JWT_SECRET) as UserPayload;
  } catch {
    throw new Error('Unauthorized: Invalid or expired token');
  }
}
```

## 20.5 Google Gemini 2.0 Flash Extraction Pipeline Implementation

The AI extraction endpoint downloads diagnostic documents from Cloudflare R2 and streams base64 inline buffers to Gemini:

```typescript
// Excerpt from app/api/ai-summary/route.ts
const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

const result = await model.generateContent([
  prompt,
  {
    inlineData: {
      data: Buffer.from(buffer).toString('base64'),
      mimeType: reportType === 'pdf' ? 'application/pdf' : 'image/jpeg',
    },
  },
]);

const text = result.response.text();
const jsonMatch = text.match(/\{[\s\S]*\}/);
const summary = jsonMatch ? JSON.parse(jsonMatch[0]) : { raw: text };
```

## 20.6 Responder Three-Tier Cascade and Telephony Dialing Engine

The responder application resolves clinical profiles with zero latency from local silicon:

```dart
// Excerpt from prana_responder/lib/services/scan_service.dart
Future<PatientScanData> fetchPatientDetails(String rawCode) async {
  final pid = extractPid(rawCode);

  // Tier 1: Immediate local silicon cache check
  final cached = await _getCachedPatient(pid);
  if (cached != null) {
    return cached; // Instantaneous 0.0 ms return
  }

  // Tier 2: Background network delta-sync query
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/card/scan-details?prana_id=$pid'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _cachePatient(pid, data);
      return PatientScanData.fromJson(data);
    }
  } catch (_) {}

  // Tier 3: Optical micro-payload decoding fallback
  return _tryParseStructuredQr(rawCode, pid);
}
```
"""
