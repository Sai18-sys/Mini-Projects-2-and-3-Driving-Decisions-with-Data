'''SELECT at.description            AS admission_type,
       COUNT(*)                  AS n_encounters,
       ROUND(AVG(time_in_hospital),1) AS avg_LOS
FROM   Encounters  e
JOIN   AdmissionType at USING (admission_type_id)
GROUP  BY at.description
ORDER  BY n_encounters DESC;
'''


/* ------------------------------------------------------------------
   Q1  Average length of stay by admission type
------------------------------------------------------------------ */
SELECT at.description            AS admission_type,
       COUNT(*)                  AS n_encounters,
       ROUND(AVG(e.time_in_hospital),1) AS avg_LOS
FROM   Encounters  e
JOIN   AdmissionType at USING (admission_type_id)
GROUP  BY at.description
ORDER  BY n_encounters DESC;

/* ------------------------------------------------------------------
   Q2  30‑day readmission rate
------------------------------------------------------------------ */
SELECT ROUND(100.0*SUM(readmitted='<30')/COUNT(*),1) AS pct_30_days
FROM   Encounters;

/* ------------------------------------------------------------------
   Q3  Top 10 medications
------------------------------------------------------------------ */
SELECT medication_name,
       COUNT(*) AS times_prescribed
FROM   EncounterMedication
GROUP  BY medication_name
ORDER  BY times_prescribed DESC
LIMIT 10;

/* ------------------------------------------------------------------
   Q4  A1C category vs average number of diagnoses
------------------------------------------------------------------ */
SELECT A1Cresult,
       ROUND(AVG(number_diagnoses),1) AS avg_dx
FROM   Encounters
WHERE  A1Cresult NOT IN ('None','?')
GROUP  BY A1Cresult
ORDER  BY avg_dx DESC;

/* ------------------------------------------------------------------
   Q5  Common discharge dispositions for patients aged ≥ 70
------------------------------------------------------------------ */
SELECT dd.description,
       COUNT(*) AS n_cases
FROM   Encounters  e
JOIN   Patients    p  USING (patient_nbr)
JOIN   DischargeDisposition dd USING (discharge_disposition_id)
WHERE  p.age IN ('70-80','80-90','90-100')
GROUP  BY dd.description
ORDER  BY n_cases DESC;
