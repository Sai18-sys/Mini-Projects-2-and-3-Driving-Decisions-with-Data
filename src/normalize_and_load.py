r"""
Build driving_decisions.db from the raw diabetic dataset.

    > cd C:/Users/dell/Desktop/final_mini_project
    > .venv/Scripts/Activate
    > python src/normalize_and_load.py
"""

import csv, sqlite3, pathlib, sys

def ensure_lookup(cur, table: str, pk_col: str, key):
    """Insert <key> into <table>(<pk_col>) if it isn't present yet."""
    cur.execute(
        f"INSERT OR IGNORE INTO {table}({pk_col}, description) VALUES (?, '')",
        (key,)
    )

def int_or_none(val: str):
    """Return int(val) or None if val is '?', 'NULL', or empty."""
    val = (val or "").strip()
    if val.isdigit():
        return int(val)
    return None

ROOT     = pathlib.Path(r"C:/Users/dell/Desktop/final_mini_project")
DATA_CSV = ROOT / "data" / "diabetic_data.csv"
MAP_CSV  = ROOT / "data" / "IDs_mapping.csv"
SCHEMA   = ROOT / "sql"  / "create_schema.sql"
DB_FILE  = ROOT / "driving_decisions.db"

def load_lookup_tables(cur):
    special = {
        'change'     : ('ChangeStatus',      'change_status'),
        'diabetesMed': ('DiabetesMedStatus', 'diabetesMed_status'),
        'readmitted' : ('ReadmitStatus',     'readmit_status')
    }

    current = None
    with MAP_CSV.open() as fh:
        for raw in fh:
            raw = raw.strip()
            if not raw:
                continue

            parts = raw.split(",", 1)

            if len(parts) == 2 and parts[1].lower() == "description":
                current = parts[0]
                continue
            if not current:
                continue

            code, meaning = parts if len(parts) == 2 else (parts[0], "")
            code = code.strip()
            if code in ("?", "NULL", ""):
                continue      

            if current in special:
                table, idcol = special[current]
            elif current.endswith("_id"):
                table = "".join(w.capitalize() for w in current.split("_")[:-1])
                idcol = current
            else:
                table = "".join(w.capitalize() for w in current.split("_"))
                idcol = current

            pk = int(code) if code.isdigit() else code
            cur.execute(
                f"INSERT OR IGNORE INTO {table}({idcol}, description) VALUES (?,?)",
                (pk, meaning.strip())
            )


def load_main(cur):
    with DATA_CSV.open() as fh:
        rdr = csv.DictReader(fh)
        for row in rdr:
            cur.execute("""INSERT OR IGNORE INTO Patients
                           (patient_nbr,race,gender,age,weight)
                           VALUES (?,?,?,?,?)""",
                        (row["patient_nbr"], row["race"], row["gender"],
                         row["age"], row["weight"]))
            
            for tbl, col in [
                ("AdmissionType",        "admission_type_id"),
                ("DischargeDisposition", "discharge_disposition_id"),
                ("AdmissionSource",      "admission_source_id")
            ]:
                key = int_or_none(row[col])
                if key is not None:
                    ensure_lookup(cur, tbl, col, key)

            status_map = {
                "change"     : ("ChangeStatus",      "change_status"),
                "diabetesMed": ("DiabetesMedStatus", "diabetesMed_status"),
                "readmitted" : ("ReadmitStatus",     "readmit_status")
            }
            for csv_col, (tbl, pk_col) in status_map.items():
                key = row[csv_col].strip()
                if key not in ("", "?", "NULL"):
                    ensure_lookup(cur, tbl, pk_col, key)

            enc_cols = [
                "encounter_id","patient_nbr","admission_type_id",
                "discharge_disposition_id","admission_source_id","payer_code",
                "medical_specialty","time_in_hospital","num_lab_procedures",
                "num_procedures","num_medications","number_outpatient",
                "number_emergency","number_inpatient","number_diagnoses",
                "max_glu_serum","A1Cresult","change","diabetesMed","readmitted"
            ]
            values = []
            for c in enc_cols:
                v = row[c].strip()
                if c.endswith("_id"):
                    v = int_or_none(v)
                if v in ("?", "NULL", ""):
                    v = None
                values.append(v)

            cur.execute(
                f"INSERT OR IGNORE INTO Encounters "
                f"VALUES ({','.join('?'*len(enc_cols))})",
                tuple(values)
            )

            for seq, dcol in enumerate(["diag_1","diag_2","diag_3"], start=1):
                code = row[dcol]
                cur.execute("INSERT OR IGNORE INTO Diagnosis VALUES (?,NULL)", (code,))
                cur.execute("""INSERT OR IGNORE INTO EncounterDiagnosis
                               VALUES (?,?,?)""",
                            (row["encounter_id"], seq, code))

            meds_to_skip = set(enc_cols + ["race","gender","age","weight",
                                           "diag_1","diag_2","diag_3"])
            for med in (c for c in row if c not in meds_to_skip):
                cur.execute("INSERT OR IGNORE INTO Medication VALUES (?)", (med,))
                cur.execute("""INSERT OR IGNORE INTO EncounterMedication
                               VALUES (?,?,?)""",
                            (row["encounter_id"], med, row[med]))

def main():
    if DB_FILE.exists():
        DB_FILE.unlink()

    with sqlite3.connect(DB_FILE) as conn:
        conn.execute("PRAGMA foreign_keys = ON;")
        cur = conn.cursor()

        cur.executescript(SCHEMA.read_text())   
        load_lookup_tables(cur)                 
        load_main(cur)                          
        conn.commit()

    print("  Database built at", DB_FILE)

if __name__ == "__main__":
    sys.exit(main())
