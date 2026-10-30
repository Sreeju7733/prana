"""
Front Matter content for PRANA Comprehensive Project Report.
"""

FRONT_MATTER = """# PRANA: An Emergency Medical Identity and Intelligent Health Record Platform

---

## A PROJECT REPORT

*Submitted in partial fulfillment of the requirements for the award of the degree of*

### BACHELOR OF COMPUTER APPLICATIONS (BCA)

*By*

**SREEJU S**  
**(Register No.: U18GO24S0099)**

**SHREYAS M**  
**(Register No.: U18GO24S0161)**

*Under the Guidance of*

**Dr. SHEELA R.**  
Head of the Department & Associate Professor  
Department of Computer Applications

---

### DEPARTMENT OF COMPUTER APPLICATIONS
### SSMRV COLLEGE
*(Affiliated to Dr. Manmohan Singh Bengaluru City University)*  
**36th Cross, 4th 'T' Block, Jayanagar, Bengaluru – 560 041, Karnataka, India**  
**Academic Year 2025 – 2026**

---

<div style="page-break-after: always;"></div>

## CERTIFICATE

This is to certify that the project report entitled **"PRANA: An Emergency Medical Identity and Intelligent Health Record Platform"** is a bonafide work carried out by **SREEJU S (Reg. No. U18GO24S0099)** and **SHREYAS M (Reg. No. U18GO24S0161)** in partial fulfillment of the requirements for the award of the degree of **Bachelor of Computer Applications (BCA)** from **Dr. Manmohan Singh Bengaluru City University** during the academic year 2025–2026.

It is certified that all corrections/suggestions indicated for internal assessment have been incorporated into the report deposited in the departmental library. The project report has been approved as it satisfies the academic requirements in respect of project work prescribed for the said degree.

<br><br><br>

--------------------------------------- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ---------------------------------------  
**Dr. SHEELA R.** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Dr. SHEELA R.**  
Project Guide &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Head of the Department  
Department of Computer Applications &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Department of Computer Applications  
SSMRV College, Bengaluru &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SSMRV College, Bengaluru  

<br><br><br>

--------------------------------------- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ---------------------------------------  
**Dr. GEETHA R.** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **EXTERNAL EXAMINER**  
Principal &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Name: _______________________  
SSMRV College, Bengaluru &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Affiliation: ____________________  

---

<div style="page-break-after: always;"></div>

## DECLARATION

We, **SREEJU S (Reg. No. U18GO24S0099)** and **SHREYAS M (Reg. No. U18GO24S0161)**, bona fide students of Final Year Bachelor of Computer Applications (BCA) at **SSMRV College, Bengaluru**, hereby declare that the project entitled **"PRANA: An Emergency Medical Identity and Intelligent Health Record Platform"** submitted to **Dr. Manmohan Singh Bengaluru City University** in partial fulfillment of the requirements for the award of the Degree of Bachelor of Computer Applications, is an original record of the software engineering work carried out by us under the supervision and guidance of **Dr. SHEELA R.**, Head of the Department and Associate Professor, Department of Computer Applications, SSMRV College.

We further declare that the results embodied in this report have not been submitted to any other University or Institution for the award of any degree, diploma, or fellowship.

**Place:** Bengaluru  
**Date:** 17 October 2026  

<br>

--------------------------------------------------- &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ---------------------------------------------------  
**SREEJU S** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **SHREYAS M**  
(Reg. No.: U18GO24S0099) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (Reg. No.: U18GO24S0161)  

---

<div style="page-break-after: always;"></div>

## ACKNOWLEDGEMENT

The satisfaction and euphoria that accompany the successful completion of any task would be incomplete without expressing our profound gratitude to the people who made it possible and whose constant guidance and encouragement served as a beacon of light throughout this endeavor.

First and foremost, we express our heartfelt gratitude to **Dr. Geetha R.**, Principal, SSMRV College, Bengaluru, for providing us with the necessary academic infrastructure, computational facilities, and supportive atmosphere required to pursue our undergraduate studies and software engineering projects.

We express our deepest sense of gratitude and indebtedness to our esteemed Project Guide and Head of Department, **Dr. Sheela R.**, Associate Professor and HOD, Department of Computer Applications, SSMRV College, for her sagacious guidance, constructive critique, patient encouragement, and unwavering technical support throughout the development and documentation of the PRANA platform. Her rigorous academic standards and insightful architectural suggestions have significantly shaped this research and implementation.

We also convey our sincere thanks to all the faculty and non-teaching staff members of the Department of Computer Applications for their direct and indirect assistance, valuable suggestions, and intellectual support during our academic tenure.

We extend our sincere appreciation to the emergency responders, medical officers, and hospital triage personnel whose domain discussions provided invaluable practical context on emergency triage workflows, trauma golden-hour delays, and resuscitation protocols.

Finally, we express our deepest affection, love, and gratitude to our parents, family members, and friends for their continuous moral support, understanding, patience, and encouragement throughout our course of study and project execution.

**SREEJU S (U18GO24S0099)**  
**SHREYAS M (U18GO24S0161)**

---

<div style="page-break-after: always;"></div>

## ABSTRACT

During acute traumatic injuries, cardiac arrests, and medical emergencies, the first sixty minutes—clinically designated as the **"Golden Hour"**—determine patient morbidity and mortality. In clinical reality, emergency medical responders and trauma teams are routinely hindered by complete information asymmetry: unconscious, disoriented, or pediatric patients cannot articulate their identity, severe drug allergies, active anticoagulant prescriptions, or chronic conditions. Furthermore, physical medical bracelets contain static, text-constrained snippets, while smartphone-based health apps fail when the device is password-locked, battery-depleted, or physically damaged in vehicular impacts.

To eliminate this life-threatening bottleneck, this project presents **PRANA** (*An Emergency Medical Identity and Intelligent Health Record Platform*), an enterprise-grade, four-pillar healthcare ecosystem engineered for zero-latency emergency triage, cryptographic health data security, and seamless hospital admission workflows. PRANA bridges physical and digital emergency healthcare through a synchronized multi-application architecture comprising:

1. **The PRANA Patient Mobile Application (Flutter/Dart):** An Android/iOS client allowing individuals to manage comprehensive health profiles, track active prescriptions, record biometric vitals, configure emergency contacts, and synchronize data using an encrypted on-device database (SQLCipher with Drift ORM) operating an outbox synchronization protocol for 100% offline access.
2. **The PRANA Responder Mobile Application (Flutter/Dart):** A tactical mobile triage engine designed for paramedics, Emergency Medical Technicians (EMTs), and disaster teams. It features a Three-Tier Dual-Engine Resolution Cascade capable of scanning physical PRANA cards and decoding micro-payloads in 0.0 milliseconds from local silicon cache, initiating one-tap click-to-call emergency relative relays, and dispatching real-time pre-arrival notifications to destination emergency rooms.
3. **The PRANA Hospital Web Portal (Next.js 16/React 19/TypeScript):** A clinical command center enabling hospital trauma teams to monitor incoming ambulance queues in real time, inspect full clinical charts, access pre-admission vitals and implanted device histories, verify cashless health insurance pre-authorizations, and review immutable triage access logs.
4. **The PRANA Super Admin Web Portal (Next.js 16/TypeScript):** A centralized platform governance system providing strict operational oversight, hospital verification and onboarding, paramedic credentialing, card fulfillment tracking, and system-wide security auditing—strictly adhering to a Zero-Knowledge privacy mandate where administrators are architecturally restricted from viewing patient medical data.

PRANA introduces a novel **Three-Tier Access Architecture**: **Tier 1 (Green Zone)** exposes minimal life-saving demographics (Blood Group, Critical Allergies, Emergency Relay) to any bystander via physical card text or public edge web routing (`/p/[id]`); **Tier 2 (Yellow Zone)** surfaces active medications, clinical conditions, and baseline vitals exclusively to verified paramedics via X25519/AES-256-GCM cryptographic decryption or authenticated API tokens; and **Tier 3 (Red Zone)** exposes full clinical histories, surgical logs, and insurance documents to authorized hospital personnel. Additionally, the platform integrates **Google Gemini 2.0 Flash AI** for automated diagnostic report summarization, optical prescription extraction, and deterministic on-demand emergency briefings.

Empirical verification confirms that the custom binary QR packing engine compresses 50+ clinical parameters into 121 bytes (well within the 150-byte physical card threshold) with 100% cryptographic round-trip accuracy, while the mobile client delivers instantaneous 0ms triage retrieval during simulated cellular blackouts. PRANA establishes a scalable, privacy-preserving, and clinically resilient standard for digital emergency healthcare in India and resource-constrained environments.

**Keywords:** Emergency Medical Identity, Golden Hour Triage, QR-Based Medical Access, Offline-First Architecture, Drift ORM, SQLCipher, Three-Tier Access Control, Google Gemini AI, Paramedic Mobile Application, Clinical EHR Integration.

---

<div style="page-break-after: always;"></div>

## TABLE OF CONTENTS

| Chapter No. | Title | Page No. |
| :---: | :--- | :---: |
| &nbsp; | **Front Matter** | &nbsp; |
| &nbsp; | Certificate | ii |
| &nbsp; | Declaration | iii |
| &nbsp; | Acknowledgement | iv |
| &nbsp; | Abstract | v |
| &nbsp; | Table of Contents | vi |
| &nbsp; | List of Figures | ix |
| &nbsp; | List of Tables | xi |
| &nbsp; | List of Abbreviations | xiii |
| &nbsp; | Project Team Details | xv |
| **1** | **Introduction** | **1** |
| 1.1 | Background of Digital Healthcare Systems | 1 |
| 1.2 | Emergency Medical Identification: The Golden Hour Challenge | 3 |
| 1.3 | Challenges in Obtaining Patient Information During Traumatic Triage | 5 |
| 1.4 | Importance of Accessible and Structured Health Records | 7 |
| 1.5 | Role of QR-Based Micro-Identities in Critical Care | 8 |
| 1.6 | Role of AI-Assisted Medical Document Processing | 10 |
| 1.7 | Rationale for a Multi-Application Ecosystem Architecture | 11 |
| 1.8 | Overview of the Four Connected PRANA Applications | 13 |
| 1.9 | Intended User Personas and System Boundaries | 16 |
| 1.10 | Motivation and Academic Contributions of the Project | 18 |
| 1.11 | Organization of the Project Report | 20 |
| **2** | **Problem Statement** | **22** |
| 2.1 | Analysis of Delays in Clinical Information Acquisition | 22 |
| 2.2 | Hidden Allergies, Medication Contraindications, and Chronic Risks | 24 |
| 2.3 | Fragmentation of Modern Electronic Medical Records (EMR) | 26 |
| 2.4 | Physical Identification Constraints and Failure Modes | 28 |
| 2.5 | Unconscious, Disoriented, and Incapacitated Patient Scenarios | 30 |
| 2.6 | The Accessibility versus Patient Privacy Dichotomy | 32 |
| 2.7 | Operational Bottlenecks in Pre-Hospital and Hospital Triage | 34 |
| 2.8 | Formal Academic Problem Statement | 36 |
| **3** | **Objectives** | **37** |
| 3.1 | Primary Objective | 37 |
| 3.2 | Secondary Objectives | 37 |
| 3.3 | Functional Objectives | 38 |
| 3.4 | Security, Privacy, and Confidentiality Objectives | 40 |
| 3.5 | Performance and Real-Time Usability Objectives | 41 |
| 3.6 | Healthcare Interoperability Objectives | 42 |
| 3.7 | Offline-First Resilience Objectives | 43 |
| 3.8 | Platform Administration and Governance Objectives | 44 |
| 3.9 | Measurable Acceptance Criteria | 45 |
| 3.10 | Objectives-to-Implementation Verification Matrix | 47 |
| **4** | **Project Scope** | **49** |
| 4.1 | Functional Scope | 49 |
| 4.2 | Technical and Architectural Scope | 51 |
| 4.3 | User and Persona Scope | 53 |
| 4.4 | Application and Platform Scope | 54 |
| 4.5 | Data Lifecycle Scope | 56 |
| 4.6 | Security and Cryptographic Scope | 58 |
| 4.7 | Deployment and Infrastructure Scope | 60 |
| 4.8 | Explicit Scope Exclusions | 61 |
| 4.9 | Known Technical Constraints and Limitations | 62 |
| 4.10 | Prospective Future Scope | 63 |
| **5** | **Background Study and Literature Review** | **65** |
| 5.1 | Evolution of Electronic Health Record (EHR) Architectures | 65 |
| 5.2 | Patient Identification Technologies in Emergency Medicine | 67 |
| 5.3 | QR Code Systems in Pre-Hospital Triage: Density and Optical Constraints | 69 |
| 5.4 | Interoperability Standards in Digital Health (HL7 FHIR and ABDM) | 71 |
| 5.5 | Artificial Intelligence in Clinical Document Extraction and OCR | 73 |
| 5.6 | Offline-First Mobile Architectures: SQLite, SQLCipher, and Outbox Sync | 75 |
| 5.7 | Tiered Information Disclosure Models in Emergency Situations | 77 |
| 5.8 | Role-Based Access Control and Cryptographic Auditability in Healthcare | 79 |
| 5.9 | Comparative Literature Analysis Table | 81 |
| 5.10 | Identification of Research and Engineering Gaps | 85 |
| **6** | **Existing System and Proposed System** | **87** |
| 6.1 | Comprehensive Review of Current Emergency ID Approaches | 87 |
| 6.2 | Failure Analysis of Legacy Solutions | 90 |
| 6.3 | Architecture of the Proposed PRANA Platform | 93 |
| 6.4 | Multi-Dimensional Feature Comparison Matrix | 96 |
| 6.5 | Engineering Innovations of PRANA | 99 |
| **7** | **Requirements Analysis** | **102** |
| 7.1 | Functional Requirements (FR-001 to FR-035) | 102 |
| 7.2 | Non-Functional Requirements (NFR-001 to NFR-012) | 114 |
| 7.3 | System Constraints and Assumptions | 120 |
| 7.4 | Operational Environment Dependencies | 122 |
| **8** | **System Users and Access Control** | **124** |
| 8.1 | User Personas and Clinical Roles | 124 |
| 8.2 | The Three-Tier Information Disclosure Paradigm | 126 |
| 8.3 | Comprehensive Role-Permission Access Matrix | 128 |
| 8.4 | Authentication Infrastructure and Telephony OTP Protocol | 131 |
| 8.5 | JWT Session Hydration, Claims, and Verification Guards | 133 |
| 8.6 | Row-Level Security (RLS) Implementation in PostgreSQL | 135 |
| 8.7 | Paramedic Roster Matching and Emergency Access Rules | 137 |
| 8.8 | Super Admin Zero-Knowledge Architectural Isolation | 139 |
| **9** | **System Architecture** | **141** |
| 9.1 | Overall Four-Pillar Logical Architecture | 141 |
| 9.2 | Physical and Cloud Deployment Architecture | 145 |
| 9.3 | Cross-Application Communication Protocols | 148 |
| 9.4 | Trust Boundaries and Attack Surfaces | 151 |
| 9.5 | Data Persistence and Caching Hierarchy | 154 |
| 9.6 | High-Availability and Network Failure Resilience | 157 |
| **10** | **Technology Stack** | **160** |
| 10.1 | Comprehensive Technology Inventory | 160 |
| 10.2 | Mobile Client Technologies (Flutter, Riverpod, Drift, SQLCipher) | 164 |
| 10.3 | Web Portal Technologies (Next.js 16, React 19, Tailwind CSS v4) | 167 |
| 10.4 | Backend and Persistence Layer (Node.js, Supabase, PostgreSQL) | 170 |
| 10.5 | Artificial Intelligence Frameworks (Google Gemini 2.0 Flash) | 173 |
| 10.6 | Cryptographic and Encoding Libraries (@noble, Base45, Ed25519) | 175 |
| 10.7 | Telephony, Storage, and Operational Tooling | 177 |
| **11** | **Module-Wise Functional Documentation** | **180** |
| 11.1 | Application 1: PRANA Patient Mobile Application Modules | 180 |
| 11.2 | Application 2: PRANA Responder Mobile Application Modules | 188 |
| 11.3 | Application 3: PRANA Hospital Web Portal Modules | 196 |
| 11.4 | Application 4: PRANA Super Admin Web Portal Modules | 204 |
| 11.5 | Cross-Application Shared Modules and State Coordination | 211 |
| **12** | **Workflows and Use Cases** | **214** |
| 12.1 | Formal Use Case Specifications (UC-01 to UC-10) | 214 |
| 12.2 | End-to-End Emergency Trauma Scenario Workflow | 224 |
| 12.3 | Patient Profile Creation and Offline Synchronization Flow | 227 |
| 12.4 | Paramedic Optical Triage and Pre-Hospital Dispatch Flow | 230 |
| 12.5 | Hospital Admission, Chart Retrieval, and Cashless Pre-Auth Flow | 233 |
| **13** | **QR-Based Emergency Identification** | **236** |
| 13.1 | The Optical Density Dilemma on Physical Laminates | 236 |
| 13.2 | PRANA Codebook v1 Specification | 238 |
| 13.3 | Binary Packing and Bitflag Architecture (`pack.ts`) | 241 |
| 13.4 | Asymmetric Cryptographic Protocol (X25519 & Ed25519) | 244 |
| 13.5 | Authenticated Payload Encryption (AES-256-GCM) | 247 |
| 13.6 | RFC 9246 Base45 Optical Encoding (`base45.ts`) | 249 |
| 13.7 | Verification, Decryption, and Unpacking Pipeline (`unpack.ts`) | 251 |
| 13.8 | The PRANA_V2 Micro-Token Fallback Grammar | 253 |
| **14** | **AI and Medical Document Processing** | **256** |
| 14.1 | Architectural Integration of Google Gemini 2.0 Flash | 256 |
| 14.2 | Optical Prescription Parsing Pipeline (`/api/scanner/prescription`) | 258 |
| 14.3 | Diagnostic Report Analysis and JSON Extraction (`/api/ai-summary`) | 261 |
| 14.4 | Deterministic Emergency Briefing Engine (`summary_generator.ts`) | 264 |
| 14.5 | Allergen Normalization and Anaphylaxis Risk Rules | 267 |
| 14.6 | Truncation Prevention and Display Constraints | 269 |
| 14.7 | Clinical Safety Boundaries, Hallucination Guards, and Disclaimers | 271 |
| **15** | **Database Design** | **274** |
| 15.1 | Conceptual Data Model and Entity-Relationship Architecture | 274 |
| 15.2 | Complete Relational Schema Table Specifications (14 Tables) | 277 |
| 15.3 | Secure Database Views (`public_green_data`, `paramedic_yellow_data`) | 291 |
| 15.4 | Stored Procedures, Cryptographic Functions, and Triggers | 293 |
| 15.5 | Immutable Audit Trail Enforcement (`prevent_scan_log_modification`) | 296 |
| 15.6 | Indexing Strategy and Query Optimization | 298 |
| **16** | **API and RESTful Service Documentation** | **301** |
| 16.1 | Architectural Style, Versioning, and Error Handling Standards | 301 |
| 16.2 | Group 1: Authentication and Telephony OTP Services | 304 |
| 16.3 | Group 2: Patient Profile, Avatars, and Health Record APIs | 308 |
| 16.4 | Group 3: Clinical Entities (Allergies, Medications, Conditions, Vitals) | 313 |
| 16.5 | Group 4: Advanced Clinical Records (Surgeries, Devices, Insurance) | 321 |
| 16.6 | Group 5: Emergency Contacts, SMS Dispatch, and Verification | 327 |
| 16.7 | Group 6: QR Generation, Offline Sync, and Security Control APIs | 332 |
| 16.8 | Group 7: AI Document Processing and Emergency Briefing Services | 338 |
| 16.9 | Group 8: Paramedic Field APIs and Triage Verification | 343 |
| 16.10| Group 9: Hospital Clinical Portal and Pre-Hospital Incoming APIs | 348 |
| 16.11| Group 10: Super Administrator Governance and Audit Log Services | 353 |
| **17** | **Data Flow Diagrams** | **358** |
| 17.1 | Context Diagram (Level 0 DFD) | 358 |
| 17.2 | Level 1 DFD: Patient Profile Lifecycle and Mobile Outbox Sync | 361 |
| 17.3 | Level 1 DFD: Paramedic Field Triage and Hospital Alerting | 364 |
| 17.4 | Level 1 DFD: AI Medical Document Extraction and Briefing | 367 |
| 17.5 | Level 1 DFD: Super Admin Governance and Immutable Auditing | 370 |
| **18** | **Security, Privacy, and Data Protection** | **373** |
| 18.1 | Threat Modeling using the STRIDE Methodology | 373 |
| 18.2 | In-Transit and At-Rest Cryptographic Safeguards | 377 |
| 18.3 | On-Device Mobile Vault Protection via SQLCipher and Biometrics | 380 |
| 18.4 | Database Row-Level Security (RLS) Policy Audit | 383 |
| 18.5 | Immutable Audit Trail and Tamper-Proof Scan Logs | 386 |
| 18.6 | Privacy Mandate: Super Admin Zero-Knowledge Enforcement | 389 |
| 18.7 | Regulatory Posture: ABDM, DISHA, and HIPAA Evaluation | 391 |
| **19** | **User Interface and Screen Documentation** | **394** |
| 19.1 | Design System Philosophy and Accessibility Tokens | 394 |
| 19.2 | Patient Mobile App: Dashboard, Identity Card, and Briefing UI | 396 |
| 19.3 | Patient Mobile App: Onboarding, Medical Setup, and Vitals Logging | 400 |
| 19.4 | Responder Mobile App: High-Contrast Tactical Scanner and Triage UI | 404 |
| 19.5 | Responder Mobile App: Clinical Surface, Click-to-Call, and Dispatch UI | 408 |
| 19.6 | Hospital Portal: Emergency Ambulance Queue and Clinical Chart UI | 412 |
| 19.7 | Super Admin Portal: System Analytics and Governance UI | 416 |
| **20** | **Implementation Details** | **420** |
| 20.1 | Mobile Client Project Structure and Initialization (Flutter) | 420 |
| 20.2 | Encrypted Drift Database and Outbox Sync Implementation | 423 |
| 20.3 | Binary QR Packing and Cryptographic Decryption Engine | 427 |
| 20.4 | Backend Edge API Request Routing and Auth Verification (Next.js) | 431 |
| 20.5 | Google Gemini 2.0 Flash Extraction Pipeline Implementation | 435 |
| 20.6 | Responder Three-Tier Cascade and Telephony Dialing Engine | 438 |
| **21** | **Software Development Methodology** | **442** |
| 21.1 | Adoption of Agile / Scrum Methodology | 442 |
| 21.2 | Sprint Breakdown and Iterative Lifecycle | 444 |
| 21.3 | Version Control, Git Branching Strategy, and Collaboration | 447 |
| 21.4 | Continuous Integration and Automated Build Tooling | 449 |
| **22** | **Testing and Quality Assurance** | **452** |
| 22.1 | Comprehensive Testing Strategy and Quality Gates | 452 |
| 22.2 | Unit Testing: Cryptographic QR Codebook Round-Trip Suite | 454 |
| 22.3 | Unit Testing: Asymmetric Encryption and Signature Verification Suite | 457 |
| 22.4 | Integration Testing: Mobile Outbox Sync and Conflict Resolution | 460 |
| 22.5 | API Security and Authentication Testing | 462 |
| 22.6 | Field Simulation: Network Blackout and Latency Benchmarks | 465 |
| 22.7 | Formal Test Case Execution Specifications (TC-001 to TC-025) | 467 |
| 22.8 | Requirements-to-Test Traceability Matrix | 478 |
| **23** | **Deployment and Operations** | **482** |
| 23.1 | Production Cloud Architecture (Vercel Edge & Supabase Cloud) | 482 |
| 23.2 | Mobile Application Release Engineering (Android APK Signing) | 485 |
| 23.3 | Environment Configuration and Cryptographic Secrets Isolation | 488 |
| 23.4 | Automated Database Migrations and Backup Strategy | 490 |
| 23.5 | System Health Monitoring, Edge Caching, and Telemetry | 492 |
| **24** | **Results and Discussion** | **495** |
| 24.1 | Feature Completion and Verification Matrix | 495 |
| 24.2 | Empirical Evaluation Against Acceptance Criteria | 498 |
| 24.3 | QR Optical Density and Compression Benchmarks | 501 |
| 24.4 | Pre-Hospital Triage Latency Analysis | 503 |
| 24.5 | Discussion of Architectural Trade-offs and Lessons Learned | 505 |
| **25** | **Limitations and Future Enhancements** | **508** |
| 25.1 | Architectural and Operational Limitations | 508 |
| 25.2 | Prospective Technical Enhancements | 511 |
| 25.3 | Integration Roadmap with National Digital Health Infrastructure (ABDM) | 514 |
| **26** | **Conclusion** | **517** |
| 26.1 | Project Summary and Synthesis | 517 |
| 26.2 | Final Assessment of Achievements | 519 |
| 26.3 | Concluding Remarks | 521 |
| &nbsp; | **References** | **523** |
| &nbsp; | **Appendices** | **530** |
| App. A | Comprehensive Technology Inventory | 530 |
| App. B | Complete API Endpoint Reference | 535 |
| App. C | Complete Supabase Database Schema (DDL) | 545 |
| App. D | Representative Configuration Examples | 556 |
| App. E | Installation and Local Development Guide | 560 |
| App. F | Automated Test Suite Execution Logs | 566 |
| App. G | Complete Screen & UI Catalogue | 572 |
| App. H | Technical Glossary and Acronyms | 578 |
| App. I | Requirements Traceability Matrix | 583 |
| App. J | User Operational Manuals (All 4 Applications) | 588 |
| App. K | Known Edge Cases and Tactical Recovery Procedures | 600 |
| App. L | Extended Architecture and Data Flow Diagrams | 605 |

---

<div style="page-break-after: always;"></div>

## LIST OF FIGURES

| Figure No. | Caption | Page No. |
| :---: | :--- | :---: |
| Figure 1.1 | The Four-Pillar Connected Healthcare Architecture of PRANA | 14 |
| Figure 3.1 | PRANA Objectives-to-Architecture Mapping Schema | 46 |
| Figure 6.1 | Comparison of Information Flow in Legacy vs. PRANA Triage | 95 |
| Figure 8.1 | Three-Tier Emergency Information Disclosure Model | 127 |
| Figure 9.1 | High-Level PRANA Logical Architecture Diagram | 143 |
| Figure 9.2 | Physical Cloud Infrastructure and Edge Deployment Architecture | 147 |
| Figure 9.3 | Cross-Application Network Communication and Security Boundaries | 150 |
| Figure 9.4 | Dual-Layer Local and Remote Cache Hierarchy | 156 |
| Figure 11.1 | PRANA Patient Mobile App: Subsystem Architecture | 182 |
| Figure 11.2 | PRANA Responder Mobile App: Three-Tier Resolution Cascade | 190 |
| Figure 11.3 | PRANA Hospital Web Portal: Clinical Command Center Structure | 198 |
| Figure 11.4 | PRANA Super Admin Portal: Multi-Tenant Oversight Architecture | 206 |
| Figure 12.1 | Sequence Diagram: End-to-End Emergency Trauma Care Lifecycle | 226 |
| Figure 12.2 | Sequence Diagram: Patient Registration, Profile Creation, and Delta Sync | 229 |
| Figure 12.3 | Sequence Diagram: Paramedic Field Triage and Hospital Dispatch Alert | 232 |
| Figure 12.4 | Sequence Diagram: Hospital Patient Search and Cashless Pre-Auth | 235 |
| Figure 13.1 | PRANA Dual-Layer QR Payload Architecture | 237 |
| Figure 13.2 | Asymmetric Key Derivation and AES-256-GCM Encryption Pipeline | 246 |
| Figure 13.3 | RFC 9246 Base45 Encoding and Decoding State Machine | 250 |
| Figure 14.1 | Google Gemini 2.0 Flash AI Medical Document Extraction Pipeline | 258 |
| Figure 14.2 | Emergency Medical Briefing Generator Logic Flow | 266 |
| Figure 15.1 | Entity-Relationship Diagram (ERD) of PRANA Relational Schema | 276 |
| Figure 17.1 | Context Diagram (Level 0 Data Flow Diagram) of PRANA Platform | 360 |
| Figure 17.2 | Level 1 DFD: Patient Profile Management and Offline Outbox Sync | 363 |
| Figure 17.3 | Level 1 DFD: Paramedic Emergency Triage and ER Notification | 366 |
| Figure 17.4 | Level 1 DFD: AI Medical Document Extraction and Briefing Refresh | 369 |
| Figure 17.5 | Level 1 DFD: Super Admin Governance and Immutable Audit Logging | 372 |
| Figure 19.1 | Patient Mobile App: Active Emergency Dashboard and AI Briefing (`flutter_01.png`) | 398 |
| Figure 19.2 | Patient Mobile App: Step 1 of 4 Medical Onboarding Flow (`flutter_02.png`) | 402 |
| Figure 19.3 | Patient Mobile App: Personalized Dashboard and Medication Alert (`flutter_03.png`) | 406 |
| Figure 19.4 | Patient Mobile App: Biometric Vitals Logging Modal (`flutter_04.png`) | 410 |
| Figure 19.5 | Responder Mobile App: High-Speed Camera QR Scanner Screen | 414 |
| Figure 19.6 | Responder Mobile App: Clinical Profile and Click-to-Call Contact Card | 415 |
| Figure 19.7 | Hospital Web Portal: Real-Time Ambulance Incoming Patient Triage Queue | 418 |
| Figure 19.8 | Hospital Web Portal: Comprehensive Clinical Patient Chart and Pre-Auth | 419 |
| Figure 19.9 | Super Admin Portal: System Analytics, Metrics, and Hospital Governance | 422 |
| Figure 21.1 | Agile / Scrum Iterative Development Lifecycle Flowchart | 446 |
| Figure 22.1 | QR Binary Codebook Round-Trip Test Execution Hex Dump Output | 456 |
| Figure 22.2 | Asymmetric Encryption and Signature Verification Test Execution Output | 459 |
| Figure 24.1 | Optical Density Comparison: Standard Raw JSON vs. PRANA Base45 Payload | 502 |

---

<div style="page-break-after: always;"></div>

## LIST OF TABLES

| Table No. | Title | Page No. |
| :---: | :--- | :---: |
| Table 3.1 | Acceptance Criteria and Objective Verification Matrix | 47 |
| Table 4.1 | Project Scope Classification (Implemented vs. Planned vs. Excluded) | 50 |
| Table 5.1 | Comparative Review of Emergency Medical Systems in Prior Literature | 82 |
| Table 6.1 | Comprehensive Multi-Dimensional Feature Comparison Matrix | 97 |
| Table 7.1 | Functional Requirements Specification (FR-001 to FR-035) | 104 |
| Table 7.2 | Non-Functional Requirements Specification (NFR-001 to NFR-012) | 116 |
| Table 8.1 | Comprehensive Role-Based Access Control (RBAC) Permission Matrix | 129 |
| Table 9.1 | Architectural Trust Boundaries and Security Countermeasures | 152 |
| Table 10.1 | Master Technology Stack Inventory with Verified Versions and Roles | 161 |
| Table 13.1 | PRANA QR Codebook v1 Entity Index Ranges | 240 |
| Table 13.2 | Critical Clinical Bitflag Map (16-Bit Register) | 242 |
| Table 15.1 | Relational Table: `profiles` Column Specifications | 278 |
| Table 15.2 | Relational Table: `allergies` Column Specifications | 280 |
| Table 15.3 | Relational Table: `medications` Column Specifications | 281 |
| Table 15.4 | Relational Table: `conditions` Column Specifications | 282 |
| Table 15.5 | Relational Table: `emergency_contacts` Column Specifications | 283 |
| Table 15.6 | Relational Table: `vitals` Column Specifications | 284 |
| Table 15.7 | Relational Table: `surgeries` Column Specifications | 285 |
| Table 15.8 | Relational Table: `devices` Column Specifications | 286 |
| Table 15.9 | Relational Table: `insurance_policies` Column Specifications | 287 |
| Table 15.10| Relational Table: `ai_summaries` Column Specifications | 288 |
| Table 15.11| Relational Table: `printed_cards` Column Specifications | 288 |
| Table 15.12| Relational Table: `medical_briefings` Column Specifications | 289 |
| Table 15.13| Relational Table: `scan_logs` Column Specifications | 290 |
| Table 15.14| Relational Table: `verified_responders` Column Specifications | 290 |
| Table 15.15| Relational Table: `verified_hospitals` and `hospital_staff` Specifications | 291 |
| Table 16.1 | Complete Master API Endpoint Catalog (49 Endpoints) | 302 |
| Table 18.1 | STRIDE Security Threat Modeling Analysis Matrix | 375 |
| Table 22.1 | Formal Quality Assurance Test Execution Matrix (TC-001 to TC-025) | 468 |
| Table 22.2 | Requirements-to-Test Traceability Matrix | 479 |
| Table 24.1 | System Feature Implementation and Verification Status Matrix | 496 |
| Table 24.2 | Optical QR Payload Size and Compression Ratio Benchmarks | 501 |
| Table 24.3 | Pre-Hospital Triage Retrieval Latency Benchmarks | 504 |

---

<div style="page-break-after: always;"></div>

## LIST OF ABBREVIATIONS

| Abbreviation | Expanded Form |
| :--- | :--- |
| **ABDM** | Ayushman Bharat Digital Mission |
| **ABHA** | Ayushman Bharat Health Account |
| **AES** | Advanced Encryption Standard |
| **AES-GCM** | Advanced Encryption Standard – Galois/Counter Mode |
| **AI** | Artificial Intelligence |
| **API** | Application Programming Interface |
| **APK** | Android Package Kit |
| **BCA** | Bachelor of Computer Applications |
| **BLE** | Bluetooth Low Energy |
| **BP** | Blood Pressure |
| **CBC** | Complete Blood Count |
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **CORS** | Cross-Origin Resource Sharing |
| **CRUD** | Create, Read, Update, Delete |
| **CSRF** | Cross-Site Request Forgery |
| **DDL** | Data Definition Language |
| **DFD** | Data Flow Diagram |
| **DISHA** | Digital Information Security in Healthcare Act |
| **DNR** | Do Not Resuscitate |
| **ECG / EKG** | Electrocardiogram |
| **ECDH** | Elliptic-Curve Diffie-Hellman |
| **Ed25519** | Edwards-curve Digital Signature Algorithm over Curve25519 |
| **EMR** | Electronic Medical Record |
| **EMT** | Emergency Medical Technician |
| **ER / ED** | Emergency Room / Emergency Department |
| **ERD** | Entity-Relationship Diagram |
| **FHIR** | Fast Healthcare Interoperability Resources (HL7) |
| **GCM** | Galois/Counter Mode |
| **HIPAA** | Health Insurance Portability and Accountability Act |
| **HL7** | Health Level Seven International |
| **HOD** | Head of the Department |
| **HTTP / HTTPS** | Hypertext Transfer Protocol / Hypertext Transfer Protocol Secure |
| **ICD-10** | International Statistical Classification of Diseases and Related Health Problems, 10th Revision |
| **JSON** | JavaScript Object Notation |
| **JSONB** | Binary JavaScript Object Notation (PostgreSQL) |
| **JWT** | JSON Web Token |
| **KYC** | Know Your Customer / Verified Identity Verification |
| **LLM** | Large Language Model |
| **NMC** | National Medical Commission (India) |
| **NSAID** | Non-Steroidal Anti-Inflammatory Drug |
| **OCR** | Optical Character Recognition |
| **ORM** | Object-Relational Mapping |
| **OTP** | One-Time Password |
| **PII** | Personally Identifiable Information |
| **PWA** | Progressive Web Application |
| **QR** | Quick Response Code |
| **RBAC** | Role-Based Access Control |
| **REST** | Representational State Transfer |
| **RLS** | Row-Level Security (PostgreSQL) |
| **SDK** | Software Development Kit |
| **SHA** | Secure Hash Algorithm |
| **SMS** | Short Message Service |
| **SQL** | Structured Query Language |
| **SpO2** | Peripheral Capillary Oxygen Saturation |
| **SSMRV** | Sivananda Sarma Memorial Rashtreeya Vidyalaya College |
| **STRIDE** | Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege |
| **TPA** | Third-Party Administrator (Health Insurance) |
| **UI / UX** | User Interface / User Experience |
| **URI / URL** | Uniform Resource Identifier / Uniform Resource Locator |
| **UUID** | Universally Unique Identifier |
| **X25519** | Diffie-Hellman Key Exchange over Curve25519 |
| **ZXing** | "Zebra Crossing" Open-Source Barcode Image Processing Library |

---

<div style="page-break-after: always;"></div>

## PROJECT TEAM DETAILS

### Student 1
- **Name:** Sreeju S
- **Register Number:** U18GO24S0099
- **Programme:** Bachelor of Computer Applications (BCA)
- **Institution:** SSMRV College, Bengaluru
- **Affiliated University:** Dr. Manmohan Singh Bengaluru City University
- **Core Engineering Responsibilities:**
  - Full-Stack Architecture and Edge Backend Engineering (Next.js 16, TypeScript, Supabase PostgreSQL).
  - Database Schema Design, Row-Level Security (RLS) Policies, Triggers, and Migration Architecture.
  - Cryptographic QR Subsystem Design (X25519, Ed25519, AES-256-GCM, Codebook v1, and RFC 9246 Base45 Encoding).
  - Hospital Web Portal and Super Admin Governance Portal Engineering.
  - Google Gemini 2.0 Flash AI Integration for Document Summarization and Prescription OCR Parsing.
  - Master Academic Documentation, API Endpoint Cataloging, and System Testing.

### Student 2
- **Name:** Shreyas M
- **Register Number:** U18GO24S0161
- **Programme:** Bachelor of Computer Applications (BCA)
- **Institution:** SSMRV College, Bengaluru
- **Affiliated University:** Dr. Manmohan Singh Bengaluru City University
- **Core Engineering Responsibilities:**
  - PRANA Patient Mobile Application Engineering (Flutter, Dart, Riverpod State Management).
  - Local Encrypted SQLite Persistence Layer (Drift ORM with SQLCipher Libs).
  - Outbox Sync Protocol and Background Network Connectivity State Engine (`connectivity_plus`).
  - PRANA Responder Mobile Application Interface, Optical Triage Camera Scanner (`mobile_scanner`), and Click-to-Call Telephony Integration.
  - User Interface Design, High-Contrast Design Tokens, Ergonomic Mobile Form Layouts, and Screenshot Cataloging.
  - Manual Field Testing, Blackout Latency Simulation, and Academic Presentation Preparation.

### Project Guide
- **Name:** Dr. Sheela R.
- **Designation:** Head of the Department & Associate Professor
- **Department:** Department of Computer Applications
- **Institution:** SSMRV College, 36th Cross, 4th 'T' Block, Jayanagar, Bengaluru – 560 041

---
"""
