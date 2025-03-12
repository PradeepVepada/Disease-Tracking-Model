--Datawarehouse Model - With fact table and dimension tables

-- Disease Dimension Table
CREATE TABLE Disease_Dim (
    Disease_ID SERIAL PRIMARY KEY,
    Disease_Name VARCHAR(255),
    Symptoms TEXT,
    Severity_Level VARCHAR(50),
    Transmission_Method VARCHAR(255),
    Risk_Factors TEXT
);

-- Patient Dimension Table
CREATE TABLE Patient_Dim (
    Patient_ID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    Age INT CHECK (Age >= 0),
    Gender VARCHAR(50) CHECK (Gender IN ('male', 'female', 'other')),
    Medical_History TEXT,
    Immunization_Status VARCHAR(50)
);

-- Location Dimension Table
CREATE TABLE Location_Dim (
    Location_ID SERIAL PRIMARY KEY,
    Country VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255)
);

-- Time Dimension Table
CREATE TABLE Time_Dim (
    Time_ID SERIAL PRIMARY KEY,
    Diagnosis_Date DATE,
    Year INT,
    Month INT,
    Week INT,
    Day INT
);

-- Hospital Dimension Table
CREATE TABLE Hospital_Dim (
    Hospital_ID SERIAL PRIMARY KEY,
    Hospital_Name VARCHAR(255),
    Location VARCHAR(255),
    Capacity INT CHECK (Capacity >= 0)
);

-- Physician Dimension Table
CREATE TABLE Physician_Dim (
    Physician_ID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    Specialty VARCHAR(255),
    Contact_Info TEXT
);

-- Health Organization Dimension Table
CREATE TABLE Health_Organization_Dim (
    Organization_ID SERIAL PRIMARY KEY,
    Organization_Name VARCHAR(255),
    Headquarters_Location VARCHAR(255)
);

-- Clinical Trial Dimension Table
CREATE TABLE Clinical_Trial_Dim (
    Trial_ID SERIAL PRIMARY KEY,
    Trial_Name VARCHAR(255),
    Start_Date DATE,
    End_Date DATE CHECK (End_Date >= Start_Date),
    Status VARCHAR(50),
    Location VARCHAR(255)
);

-- Create Fact Table
CREATE TABLE Disease_Facts (
    Fact_ID SERIAL PRIMARY KEY,
    Disease_ID INT NOT NULL,
    Patient_ID INT NOT NULL,
    Location_ID INT NOT NULL,
    Time_ID INT NOT NULL,
    Hospital_ID INT,
    Physician_ID INT,
    Organization_ID INT,
    Trial_ID INT,
    Medication_ID INT,
    Severity VARCHAR(50),
    Diagnosis_Count INT,
    Medication_Effectiveness FLOAT,
    FOREIGN KEY (Disease_ID) REFERENCES Disease_Dim(Disease_ID) ON DELETE CASCADE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient_Dim(Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Location_ID) REFERENCES Location_Dim(Location_ID) ON DELETE CASCADE,
    FOREIGN KEY (Time_ID) REFERENCES Time_Dim(Time_ID) ON DELETE CASCADE,
    FOREIGN KEY (Hospital_ID) REFERENCES Hospital_Dim(Hospital_ID) ON DELETE CASCADE,
    FOREIGN KEY (Physician_ID) REFERENCES Physician_Dim(Physician_ID) ON DELETE CASCADE,
    FOREIGN KEY (Organization_ID) REFERENCES Health_Organization_Dim(Organization_ID) ON DELETE CASCADE,
    FOREIGN KEY (Trial_ID) REFERENCES Clinical_Trial_Dim(Trial_ID) ON DELETE CASCADE,
    FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID) ON DELETE CASCADE
);

-- ETL Process

-- Populating Disease_Dim
INSERT INTO Disease_Dim (Disease_Name, Symptoms, Severity_Level, Transmission_Method, Risk_Factors)
SELECT DISTINCT Disease_Name, Symptoms, Severity_Level, Transmission_Method, Risk_Factors
FROM public.Disease;

-- Populating Patient_Dim
INSERT INTO Patient_Dim (Name, Age, Gender, Medical_History, Immunization_Status)
SELECT DISTINCT Name, Age, Gender, Medical_History, Immunization_Status
FROM public.Patient;

-- Populating Location_Dim
INSERT INTO Location_Dim (Country, City, Region)
SELECT DISTINCT
    SPLIT_PART(Location, ',', 1) AS Country,
    SPLIT_PART(Location, ',', 2) AS City,
    NULL AS Region
FROM public.Hospital;

-- Populating Time_Dim
INSERT INTO Time_Dim (Diagnosis_Date, Year, Month, Week, Day)
SELECT DISTINCT
    Diagnosis_Date,
    EXTRACT(YEAR FROM Diagnosis_Date) AS Year,
    EXTRACT(MONTH FROM Diagnosis_Date) AS Month,
    EXTRACT(WEEK FROM Diagnosis_Date) AS Week,
    EXTRACT(DAY FROM Diagnosis_Date) AS Day
FROM public.Diagnosis;

-- Populating Hospital_Dim
INSERT INTO Hospital_Dim (Hospital_Name, Location, Capacity)
SELECT DISTINCT Hospital_Name, Location, Capacity
FROM public.Hospital;

-- Populating Physician_Dim
INSERT INTO Physician_Dim (Name, Specialty, Contact_Info)
SELECT DISTINCT Name, Specialty, Contact_Info
FROM public.Physician;

-- Populating Health_Organization_Dim
INSERT INTO Health_Organization_Dim (Organization_Name, Headquarters_Location)
SELECT DISTINCT Organization_Name, Headquarters_Location
FROM public.Health_Organization;

-- Populating Clinical_Trial_Dim
INSERT INTO Clinical_Trial_Dim (Trial_Name, Start_Date, End_Date, Status, Location)
SELECT DISTINCT Trial_Name, Start_Date, End_Date, Status, Location
FROM public.Clinical_Trial;

-- Populating Disease_Facts
INSERT INTO Disease_Facts (
    Disease_ID,
    Patient_ID,
    Location_ID,
    Time_ID,
    Hospital_ID,
    Physician_ID,
    Organization_ID,
    Trial_ID,
    Medication_ID,
    Severity,
    Diagnosis_Count,
    Medication_Effectiveness
)
SELECT
    d.Disease_ID,
    p.Patient_ID,
    l.Location_ID,
    t.Time_ID,
    h.Hospital_ID,
    ph.Physician_ID,
    ho.Organization_ID,
    ct.Trial_ID,
    m.Medication_ID,
    diag.Severity,
    COUNT(diag.Diagnosis_ID) AS Diagnosis_Count,
    COALESCE(AVG(m.Medication_Effectiveness), 0) AS Medication_Effectiveness
FROM
    public.Diagnosis diag
    JOIN Disease_Dim d ON diag.Disease_ID = d.Disease_ID
    JOIN Patient_Dim p ON diag.Patient_ID = p.Patient_ID
    JOIN Time_Dim t ON diag.Diagnosis_Date = t.Diagnosis_Date
    LEFT JOIN Hospital_Patient hp ON diag.Patient_ID = hp.Patient_ID
    LEFT JOIN Hospital_Dim h ON hp.Hospital_ID = h.Hospital_ID
    LEFT JOIN Location_Dim l ON SPLIT_PART(h.Location, ',', 2) = l.City
    LEFT JOIN Physician_Patient pp ON diag.Patient_ID = pp.Patient_ID
    LEFT JOIN Physician_Dim ph ON pp.Physician_ID = ph.Physician_ID
    LEFT JOIN Health_Organization_Disease hod ON diag.Disease_ID = hod.Disease_ID
    LEFT JOIN Health_Organization_Dim ho ON hod.Organization_ID = ho.Organization_ID
    LEFT JOIN Clinical_Trial_Patient ctp ON diag.Patient_ID = ctp.Patient_ID
    LEFT JOIN Clinical_Trial_Dim ct ON ctp.Trial_ID = ct.Trial_ID
    LEFT JOIN Patient_Medicine pm ON p.Patient_ID = pm.Patient_ID
    LEFT JOIN Medication m ON pm.Medication_ID = m.Medication_ID
GROUP BY
    d.Disease_ID, p.Patient_ID, l.Location_ID, t.Time_ID, h.Hospital_ID,
    ph.Physician_ID, ho.Organization_ID, ct.Trial_ID, m.Medication_ID, diag.Severity;

-- Analytical Queries

--Monthly Trends in Disease Severity
SELECT
    d.Disease_Name,
    d.Severity_Level,
    DATE_TRUNC('month', di.Diagnosis_Date) AS "month",
    AVG(d.Mortality_Rate) AS avg_severity
FROM
    Diagnosis di
JOIN
    Disease d
ON
    di.Disease_ID = d.Disease_ID
GROUP BY
    d.Disease_Name,
    d.Severity_Level,
    DATE_TRUNC('month', di.Diagnosis_Date)
ORDER BY
    "month", d.Disease_Name;

--Trigger for ensuring hospital capacity doesn't get into negative

CREATE OR REPLACE FUNCTION validate_hospital_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Capacity < 0 THEN
        RAISE EXCEPTION 'Hospital capacity should never be negative';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_hospital_capacity
BEFORE INSERT OR UPDATE ON Hospital_Dim
FOR EACH ROW
EXECUTE FUNCTION validate_hospital_capacity();

--Avg medication effectiveness by disease
SELECT
    dd.Disease_Name,
    AVG(df.Medication_Effectiveness) AS Avg_Medication_Effectiveness
FROM
    Disease_Facts df
JOIN
    Disease_Dim dd ON df.Disease_ID = dd.Disease_ID
GROUP BY
    dd.Disease_Name
ORDER BY
    Avg_Medication_Effectiveness DESC;

-- Patients Enrolled in Each Clinical Trial
SELECT
    ct.Trial_Name,
    COUNT(DISTINCT df.Patient_ID) AS Patient_Count
FROM
    Disease_Facts df
JOIN
    Clinical_Trial_Dim ct ON df.Trial_ID = ct.Trial_ID
GROUP BY
    ct.Trial_Name
ORDER BY
    Patient_Count DESC;


-- Check if the Medication_Effectiveness column exists in the Disease_Facts table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'disease_facts' AND column_name = 'medication_effectiveness';

-- Verify the Medication_Effectiveness values in the Disease_Facts table
SELECT d.medication_effectiveness
FROM disease_facts d
GROUP BY d.medication_effectiveness;

-- Verify the Disease_ID and Medication_Effectiveness values in the Disease_Facts table
SELECT d.disease_id, d.medication_effectiveness, COUNT(d.diagnosis_count)
FROM disease_facts d
GROUP BY d.disease_id, d.medication_effectiveness;


--Medication effectiveness by medication id for a particular disease

SELECT
    dd.Disease_Name,
    m.Medication_ID,
    AVG(df.Medication_Effectiveness) AS Avg_Medication_Effectiveness
FROM
    Disease_Facts df
JOIN
    Disease_Dim dd ON df.Disease_ID = dd.Disease_ID
JOIN
    Clinical_Trial_Dim ctd ON df.Trial_ID = ctd.Trial_ID
JOIN
    Medication m ON df.Medication_ID = m.Medication_ID
GROUP BY
    dd.Disease_Name, m.Medication_ID
ORDER BY
    Avg_Medication_Effectiveness DESC;

--  Views
CREATE VIEW Disease_Summary AS
SELECT
    d.Disease_Name,
    COUNT(df.Diagnosis_Count) AS Total_Diagnoses,
    AVG(df.Medication_Effectiveness) AS Avg_Medication_Effectiveness
FROM
    Disease_Facts df
    JOIN Disease_Dim d ON df.Disease_ID = d.Disease_ID
GROUP BY
    d.Disease_Name;

CREATE VIEW Patient_Disease_Details AS
SELECT
    p.Name AS Patient_Name,
    d.Disease_Name,
    df.Severity,
    df.Diagnosis_Count
FROM
    Disease_Facts df
    JOIN Patient_Dim p ON df.Patient_ID = p.Patient_ID
    JOIN Disease_Dim d ON df.Disease_ID = d.Disease_ID;

--query for "Views" verification
--SELECT Disease_Name, Total_Diagnoses, Avg_Medication_Effectiveness
--FROM Disease_Summary;

--patient-disease unique - table view
SELECT
    pdd.Patient_Name,
    pdd.Disease_Name,
    pdd.Severity,
    pdd.Diagnosis_Count,
    ds.Total_Diagnoses,
    ds.Avg_Medication_Effectiveness
FROM
    (SELECT Patient_Name, Disease_Name, Severity, Diagnosis_Count
     FROM Patient_Disease_Details
     GROUP BY Patient_Name, Disease_Name, Severity, Diagnosis_Count) pdd
    JOIN Disease_Summary ds ON pdd.Disease_Name = ds.Disease_Name;


--  Indexes
CREATE INDEX idx_disease_facts_disease_id ON Disease_Facts(Disease_ID);
CREATE INDEX idx_disease_facts_patient_id ON Disease_Facts(Patient_ID);
CREATE INDEX idx_time_dim_diagnosis_date ON Time_Dim(Diagnosis_Date);

-- A hierarchical access control system for users accessing the database in a hospital 

CREATE ROLE admin WITH LOGIN PASSWORD '12344567';
CREATE ROLE doctor WITH LOGIN PASSWORD '7654321';
CREATE ROLE nurse WITH LOGIN PASSWORD '1234456';
CREATE ROLE "drug researcher" WITH LOGIN PASSWORD '765432';
CREATE ROLE "data analyst" WITH LOGIN PASSWORD '7654323';
CREATE ROLE patient WITH LOGIN PASSWORD '76543';


-- Grant permissions to admin
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin;

-- Permissions to a doctor
GRANT SELECT, INSERT, UPDATE ON Disease_Dim TO doctor;
GRANT SELECT, INSERT, UPDATE ON Patient_Dim TO doctor;
GRANT SELECT, INSERT, UPDATE ON Disease_Facts TO doctor;
GRANT SELECT, INSERT, UPDATE ON Physician_Dim TO doctor;
GRANT SELECT, INSERT, UPDATE ON Time_Dim TO doctor;
GRANT SELECT ON Hospital_Dim TO doctor;
GRANT SELECT ON Location_Dim TO doctor;
GRANT SELECT ON Health_Organization_Dim TO doctor;
GRANT SELECT ON Clinical_Trial_Dim TO doctor;

-- Grant permissions to nurse
GRANT SELECT, INSERT, UPDATE ON Patient_Dim TO nurse;
GRANT SELECT, INSERT, UPDATE ON Disease_Facts TO nurse;
GRANT SELECT ON Disease_Dim TO nurse;
GRANT SELECT ON Hospital_Dim TO nurse;
GRANT SELECT ON Location_Dim TO nurse;
GRANT SELECT ON Time_Dim TO nurse;
GRANT SELECT ON Physician_Dim TO nurse;
GRANT SELECT ON Health_Organization_Dim TO nurse;
GRANT SELECT ON Clinical_Trial_Dim TO nurse;

-- Grant permissions to drug researcher
GRANT SELECT ON Disease_Facts TO drug researcher;
GRANT SELECT ON Disease_Dim TO drug researcher;
GRANT SELECT ON Patient_Dim TO drug researcher;
GRANT SELECT ON Hospital_Dim TO drug researcher;
GRANT SELECT ON Location_Dim TO drug researcher;
GRANT SELECT ON Time_Dim TO drug researcher;
GRANT SELECT ON Physician_Dim TO drug researcher;
GRANT SELECT ON Health_Organization_Dim TO drug researcher;
GRANT SELECT ON Clinical_Trial_Dim TO drug researcher;

-- Grant permissions to data analyst
GRANT SELECT ON Disease_Facts TO data_analyst;
GRANT SELECT ON Disease_Dim TO data_analyst;
GRANT SELECT ON Patient_Dim TO data_analyst;
GRANT SELECT ON Hospital_Dim TO data_analyst;
GRANT SELECT ON Location_Dim TO data_analyst;
GRANT SELECT ON Time_Dim TO data_analyst;
GRANT SELECT ON Physician_Dim TO data_analyst;
GRANT SELECT ON Health_Organization_Dim TO data_analyst;
GRANT SELECT ON Clinical_Trial_Dim TO data_analyst;
GRANT CREATE ON SCHEMA public TO data_analyst;

--REVOKE ALL ON ALL TABLES IN SCHEMA public FROM nurse;
--REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM nurse;



