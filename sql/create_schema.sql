PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS AdmissionType (
    admission_type_id         INTEGER PRIMARY KEY,
    description               TEXT
);

CREATE TABLE IF NOT EXISTS DischargeDisposition (
    discharge_disposition_id  INTEGER PRIMARY KEY,
    description               TEXT
);

CREATE TABLE IF NOT EXISTS AdmissionSource (
    admission_source_id       INTEGER PRIMARY KEY,
    description               TEXT
);

CREATE TABLE IF NOT EXISTS ChangeStatus (
    change_status             TEXT PRIMARY KEY,
    description               TEXT
);

CREATE TABLE IF NOT EXISTS DiabetesMedStatus (
    diabetesMed_status        TEXT PRIMARY KEY,
    description               TEXT
);

CREATE TABLE IF NOT EXISTS ReadmitStatus (
    readmit_status            TEXT PRIMARY KEY,
    description               TEXT
);

CREATE TABLE IF NOT EXISTS Patients (
    patient_nbr      INTEGER PRIMARY KEY,
    race             TEXT,
    gender           TEXT,
    age              TEXT,
    weight           TEXT
);

CREATE TABLE IF NOT EXISTS Encounters (
    encounter_id              INTEGER PRIMARY KEY,
    patient_nbr               INTEGER,
    admission_type_id         INTEGER,
    discharge_disposition_id  INTEGER,
    admission_source_id       INTEGER,
    payer_code                TEXT,
    medical_specialty         TEXT,
    time_in_hospital          INTEGER,
    num_lab_procedures        INTEGER,
    num_procedures            INTEGER,
    num_medications           INTEGER,
    number_outpatient         INTEGER,
    number_emergency          INTEGER,
    number_inpatient          INTEGER,
    number_diagnoses          INTEGER,
    max_glu_serum             TEXT,
    A1Cresult                 TEXT,
    change_status             TEXT,
    diabetesMed_status        TEXT,
    readmit_status            TEXT,
    FOREIGN KEY (patient_nbr)              REFERENCES Patients(patient_nbr),
    FOREIGN KEY (admission_type_id)        REFERENCES AdmissionType(admission_type_id),
    FOREIGN KEY (discharge_disposition_id) REFERENCES DischargeDisposition(discharge_disposition_id),
    FOREIGN KEY (admission_source_id)      REFERENCES AdmissionSource(admission_source_id),
    FOREIGN KEY (change_status)            REFERENCES ChangeStatus(change_status),
    FOREIGN KEY (diabetesMed_status)       REFERENCES DiabetesMedStatus(diabetesMed_status),
    FOREIGN KEY (readmit_status)           REFERENCES ReadmitStatus(readmit_status)
);

CREATE TABLE IF NOT EXISTS Diagnosis (
    diagnosis_code   TEXT PRIMARY KEY,
    long_title       TEXT
);

CREATE TABLE IF NOT EXISTS EncounterDiagnosis (
    encounter_id     INTEGER,
    seq              INTEGER,            
    diagnosis_code   TEXT,
    PRIMARY KEY (encounter_id, seq),
    FOREIGN KEY (encounter_id)   REFERENCES Encounters(encounter_id),
    FOREIGN KEY (diagnosis_code) REFERENCES Diagnosis(diagnosis_code)
);

CREATE TABLE IF NOT EXISTS Medication (
    medication_name TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS EncounterMedication (
    encounter_id     INTEGER,
    medication_name  TEXT,
    dosage_change    TEXT,
    PRIMARY KEY (encounter_id, medication_name),
    FOREIGN KEY (encounter_id)   REFERENCES Encounters(encounter_id),
    FOREIGN KEY (medication_name)REFERENCES Medication(medication_name)
);
