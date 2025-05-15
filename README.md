# Mini-Projects-2-and-3-Driving-Decisions-with-Data

```markdown
# Driving Decisions with Data

This project demonstrates how to normalize a flat health-care dataset (the “Diabetes 130-US Hospitals” CSV), load it into SQLite, run decision-driving SQL queries, and reproduce those insights in pandas. The end result is a stakeholder-facing report with actionable recommendations.

---

## 📂 Repository Structure

```

driving\_decisions/
├── data/
│   ├── diabetic\_data.csv      # raw patient encounter data
│   └── IDS\_mapping.csv        # lookup mappings for all “\_id” fields
│
├── sql/
│   ├── create\_schema.sql      # DDL: create normalized 3NF tables
│   └── queries.sql            # your five stakeholder SQL queries
│
├── src/
│   ├── normalize\_and\_load.py  # Python script: build DB & load data
│   └── pandas\_analysis.ipynb  # Jupyter notebook: replicate queries in pandas
│
└── report/
├── body.docx              # non-technical findings & recommendations
└── appendix.docx          # ERD, normalization notes, SQL & pandas snippets

````

---

## 🛠 Prerequisites

- **Python 3.8+** (includes `sqlite3`)
- **pip**
- **virtualenv** (optional)
- **Git** (if you plan to clone or version-control)

---

## ⚙️ Installation & Setup

1. **Clone the repo**  
   ```bash
   git clone https://github.com/your-username/driving_decisions.git
   cd driving_decisions
````

2. **Create & activate a virtual environment**

   ```bash
   python3 -m venv venv
   source venv/bin/activate       # Windows: venv\Scripts\activate
   ```

3. **Install dependencies**

   ```bash
   pip install --upgrade pip pandas
   ```

4. **Verify the data files**
   Ensure that `data/diabetic_data.csv` and `data/IDS_mapping.csv` are present.

---

## ▶️ Running the Data Load

```bash
# from project root
python3 src/normalize_and_load.py
```

This will:

1. Create `driving_decisions.db` in the project root.
2. Execute `sql/create_schema.sql` to build all tables (Patients, Encounters, lookups, bridges).
3. Populate lookup tables from `data/IDS_mapping.csv`.
4. Normalize & load the main CSV into 3NF tables.

---

## 🔍 Sanity Check

After loading, you can verify table counts:

```bash
sqlite3 driving_decisions.db <<'EOF'
.headers on
.mode column
SELECT 
  'Patients'              AS table, COUNT(*) FROM Patients UNION ALL
SELECT 
  'Encounters',           COUNT(*) FROM Encounters UNION ALL
SELECT 
  'AdmissionType',        COUNT(*) FROM AdmissionType UNION ALL
SELECT 
  'Diagnosis',            COUNT(*) FROM Diagnosis UNION ALL
SELECT 
  'EncounterDiagnosis',   COUNT(*) FROM EncounterDiagnosis UNION ALL
SELECT 
  'Medication',           COUNT(*) FROM Medication UNION ALL
SELECT 
  'EncounterMedication',  COUNT(*) FROM EncounterMedication;
EOF
```

---

## 🔧 Writing & Running Your SQL Queries

1. Edit `sql/queries.sql` with your five decision-driving queries (must include at least two `JOIN`s).
2. Run them in SQLite:

   ```bash
   sqlite3 driving_decisions.db < sql/queries.sql
   ```

---

## 📊 Pandas Analysis

Open `src/pandas_analysis.ipynb` to:

* Connect to the same `driving_decisions.db`
* Use `pd.read_sql()` and `DataFrame.merge` / `groupby` to replicate each SQL query
* Visualize or tabulate your results in Jupyter

---

## 📝 Reports

* **report/body.docx**: Plain-English summary of your findings and concrete recommendations for your stakeholder (e.g., Hospital Quality Manager).
* **report/appendix.docx**: Technical appendix showing your ERD, normalization rationale (1NF → 3NF), full SQL scripts with explanations, and core pandas code snippets.

---

## 🤝 Contribution

Feel free to:

* Propose improvements to normalization design
* Add more advanced analyses or visualizations
* Suggest alternative stakeholder questions

Pull requests and issues are welcome!

---

## 📧 Contact

**Sai Krishna Anagani**
– University at Buffalo, MS in Data Science

---

