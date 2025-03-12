--Disease Model

-- Disease Table
CREATE TABLE Disease (
    Disease_ID SERIAL PRIMARY KEY,
    Disease_Name VARCHAR(255) NOT NULL,
    Symptoms TEXT,
    Severity_Level VARCHAR(50),
    Transmission_Method VARCHAR(255),
    Mortality_Rate FLOAT,
    Incubation_Period INT,
    Risk_Factors TEXT,
    CONSTRAINT chk_severity_level CHECK (Severity_Level IN ('mild', 'moderate', 'severe')),
    CONSTRAINT chk_mortality_rate CHECK (Mortality_Rate >= 0 AND Mortality_Rate <= 100),
    CONSTRAINT chk_incubation_period CHECK (Incubation_Period >= 0)
);

-- Create Patient Table
CREATE TABLE Patient (
    Patient_ID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Age INT CHECK (Age >= 0),
    Gender VARCHAR(50) CHECK (Gender IN ('male', 'female', 'other')),
    City VARCHAR(255),
    Medical_History TEXT,
    Immunization_Status VARCHAR(50)
);

-- Create Medication Table
CREATE TABLE Medication (
    Medication_ID SERIAL PRIMARY KEY,
    Medication_Name VARCHAR(255) NOT NULL,
    Dosage VARCHAR(255),
    Side_Effects TEXT,
    Manufacturer VARCHAR(255),
    Approval_Status VARCHAR(50) CHECK (Approval_Status IN ('approved', 'under review', 'rejected')),
	Medication_Effectiveness FLOAT NOT NULL
);

--DROP TABLE IF EXISTS Medication CASCADE;



-- Create Clinical_Trial Table
CREATE TABLE Clinical_Trial (
    Trial_ID SERIAL PRIMARY KEY,
    Trial_Name VARCHAR(255) NOT NULL,
    Start_Date DATE,
    End_Date DATE CHECK (End_Date >= Start_Date),
    Status VARCHAR(50) CHECK (Status IN ('ongoing', 'completed', 'cancelled')),
    Location VARCHAR(255)
);

-- Create Health_Organization Table
CREATE TABLE Health_Organization (
    Organization_ID SERIAL PRIMARY KEY,
    Organization_Name VARCHAR(255) NOT NULL,
    Headquarters_Location VARCHAR(255),
    Contact_Info TEXT
);

-- Create Physician Table
CREATE TABLE Physician (
    Physician_ID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Specialty VARCHAR(255),
    Contact_Info TEXT,
    City VARCHAR(255)
);

-- Create Hospital Table
CREATE TABLE Hospital (
    Hospital_ID SERIAL PRIMARY KEY,
    Hospital_Name VARCHAR(255) NOT NULL,
    Location VARCHAR(255),
    Capacity INT CHECK (Capacity >= 0),
    Contact_Info TEXT
);

-- Create Diagnosis Table (Many-to-Many relationship between Patient and Disease)
CREATE TABLE Diagnosis (
    Diagnosis_ID SERIAL PRIMARY KEY,
    Patient_ID INT NOT NULL,
    Disease_ID INT NOT NULL,
    Diagnosis_Date DATE NOT NULL,
    Severity VARCHAR(50) CHECK (Severity IN ('mild', 'moderate', 'severe')),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Disease_ID) REFERENCES Disease(Disease_ID) ON DELETE CASCADE
);

-- Create Patient_Medicine Table (Many-to-Many relationship between Patient and Medication)
CREATE TABLE Patient_Medicine (
    Patient_ID INT NOT NULL,
    Medication_ID INT NOT NULL,
    PRIMARY KEY (Patient_ID, Medication_ID),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID) ON DELETE CASCADE
);

-- Create Clinical_Trial_Patient Table (Many-to-Many relationship between Clinical_Trial and Patient)
CREATE TABLE Clinical_Trial_Patient (
    Trial_ID INT NOT NULL,
    Patient_ID INT NOT NULL,
    PRIMARY KEY (Trial_ID, Patient_ID),
    FOREIGN KEY (Trial_ID) REFERENCES Clinical_Trial(Trial_ID) ON DELETE CASCADE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE
);

-- Create Clinical_Trial_Medication Table (Many-to-Many relationship between Clinical_Trial and Medication)
CREATE TABLE Clinical_Trial_Medication (
    Trial_ID INT NOT NULL,
    Medication_ID INT NOT NULL,
    PRIMARY KEY (Trial_ID, Medication_ID),
    FOREIGN KEY (Trial_ID) REFERENCES Clinical_Trial(Trial_ID) ON DELETE CASCADE,
    FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID) ON DELETE CASCADE
);

-- Create Health_Organization_Disease Table (One-to-Many relationship between Health_Organization and Disease)
CREATE TABLE Health_Organization_Disease (
    Organization_ID INT NOT NULL,
    Disease_ID INT NOT NULL,
    PRIMARY KEY (Organization_ID, Disease_ID),
    FOREIGN KEY (Organization_ID) REFERENCES Health_Organization(Organization_ID) ON DELETE CASCADE,
    FOREIGN KEY (Disease_ID) REFERENCES Disease(Disease_ID) ON DELETE CASCADE
);

-- Create Physician_Patient Table (Many-to-Many relationship between Physician and Patient)
CREATE TABLE Physician_Patient (
    Physician_ID INT NOT NULL,
    Patient_ID INT NOT NULL,
    PRIMARY KEY (Physician_ID, Patient_ID),
    FOREIGN KEY (Physician_ID) REFERENCES Physician(Physician_ID) ON DELETE CASCADE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE
);

-- Create Hospital_Patient Table (Many-to-Many relationship between Hospital and Patient)
CREATE TABLE Hospital_Patient (
    Hospital_ID INT NOT NULL,
    Patient_ID INT NOT NULL,
    PRIMARY KEY (Hospital_ID, Patient_ID),
    FOREIGN KEY (Hospital_ID) REFERENCES Hospital(Hospital_ID) ON DELETE CASCADE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE
);

--Sample data

INSERT INTO Disease (Disease_ID, Disease_Name, Symptoms, Severity_Level, Transmission_Method, Mortality_Rate, Incubation_Period, Risk_Factors) VALUES
(1, 'Influenza', 'Fever, cough, sore throat', 'moderate', 'Airborne', 0.1, 2, 'Elderly, immunocompromised'),
(2, 'COVID-19', 'Fever, dry cough, fatigue', 'severe', 'Airborne', 2.0, 5, 'Elderly, immunocompromised, chronic diseases'),
(3, 'Malaria', 'Fever, chills, nausea', 'moderate', 'Mosquito bite', 1.0, 10, 'Travel to endemic areas'),
(4, 'Tuberculosis', 'Cough, fever, night sweats', 'severe', 'Airborne', 1.5, 21, 'Immunocompromised, close contact'),
(5, 'Measles', 'Fever, rash, cough', 'moderate', 'Airborne', 0.2, 10, 'Unvaccinated, children'),
(6, 'Hepatitis B', 'Jaundice, fatigue, abdominal pain', 'moderate', 'Blood, bodily fluids', 0.5, 90, 'Intravenous drug users, healthcare workers'),
(7, 'Dengue Fever', 'Fever, headache, muscle pain', 'moderate', 'Mosquito bite', 0.8, 7, 'Travel to endemic areas'),
(8, 'Cholera', 'Diarrhea, vomiting, dehydration', 'severe', 'Contaminated water', 1.0, 2, 'Poor sanitation, travel to endemic areas'),
(9, 'Ebola', 'Fever, severe headache, muscle pain', 'severe', 'Bodily fluids', 50.0, 8, 'Close contact with infected individuals'),
(10, 'HIV/AIDS', 'Fever, fatigue, swollen lymph nodes', 'severe', 'Bodily fluids', 10.0, 180, 'Unprotected sex, intravenous drug users'),
(11, 'Zika Virus', 'Fever, rash, joint pain', 'mild', 'Mosquito bite', 0.1, 7, 'Travel to endemic areas, pregnant women'),
(12, 'MERS', 'Fever, cough, shortness of breath', 'severe', 'Airborne', 35.0, 14, 'Close contact with infected individuals'),
(13, 'Smallpox', 'Rash, fever, vomiting', 'severe', 'Airborne', 30.0, 12, 'Unvaccinated individuals'),
(14, 'Anthrax', 'Skin ulcers, nausea, fever', 'moderate', 'Contaminated food', 5.0, 7, 'Farm workers, veterinarians'),
(15, 'Plague', 'Fever, chills, swollen lymph nodes', 'severe', 'Fleas', 10.0, 4, 'Close contact with infected animals'),
(16, 'Rabies', 'Fever, confusion, hallucinations', 'severe', 'Animal bites', 100.0, 20, 'Non-vaccinated exposed individuals'),
(17, 'SARS', 'Fever, dry cough, pneumonia', 'severe', 'Airborne', 15.0, 10, 'Close contact with infected individuals'),
(18, 'Yellow Fever', 'Fever, jaundice, muscle pain', 'moderate', 'Mosquito bite', 3.0, 6, 'Travel to endemic areas'),
(19, 'Typhoid', 'Fever, weakness, abdominal pain', 'moderate', 'Contaminated water', 1.0, 14, 'Poor sanitation'),
(20, 'Chickenpox', 'Rash, fever, fatigue', 'mild', 'Airborne', 0.1, 14, 'Unvaccinated children');

INSERT INTO Patient (Patient_ID, Name, Age, Gender, City, Medical_History, Immunization_Status) VALUES
(1, 'John Doe', 45, 'male', 'New York', 'Hypertension', 'up-to-date'),
(2, 'Jane Smith', 30, 'female', 'Los Angeles', 'Asthma', 'up-to-date'),
(3, 'Alex Johnson', 25, 'other', 'Chicago', 'None', 'not up-to-date'),
(4, 'Emily Davis', 50, 'female', 'Houston', 'Diabetes', 'up-to-date'),
(5, 'Michael Brown', 35, 'male', 'Boston', 'None', 'up-to-date'),
(6, 'Sarah Wilson', 40, 'female', 'Seattle', 'Heart disease', 'not up-to-date'),
(7, 'David Lee', 28, 'male', 'San Francisco', 'Allergies', 'up-to-date'),
(8, 'Linda Clark', 60, 'female', 'Miami', 'Arthritis', 'up-to-date'),
(9, 'Robert Hall', 42, 'male', 'Dallas', 'None', 'not up-to-date'),
(10, 'Laura Young', 32, 'female', 'Philadelphia', 'Migraines', 'up-to-date'),
(11, 'James Miller', 55, 'male', 'Atlanta', 'Hypertension', 'up-to-date'),
(12, 'Olivia Taylor', 29, 'female', 'Denver', 'None', 'not up-to-date'),
(13, 'Sophia Anderson', 37, 'female', 'Phoenix', 'Asthma', 'up-to-date'),
(14, 'Liam Martinez', 23, 'male', 'San Antonio', 'None', 'not up-to-date'),
(15, 'Benjamin Thomas', 31, 'male', 'San Diego', 'Diabetes', 'up-to-date'),
(16, 'Ella Davis', 45, 'female', 'Austin', 'Heart disease', 'not up-to-date'),
(17, 'Isabella Garcia', 50, 'female', 'Columbus', 'Arthritis', 'up-to-date'),
(18, 'Lucas Hernandez', 48, 'male', 'Fort Worth', 'None', 'not up-to-date'),
(19, 'Mia Martinez', 29, 'female', 'Charlotte', 'Migraines', 'up-to-date'),
(20, 'Henry Moore', 60, 'male', 'Indianapolis', 'Hypertension', 'up-to-date');

INSERT INTO Medication (Medication_ID, Medication_Name, Dosage, Side_Effects, Manufacturer, Approval_Status, Medication_Effectiveness) VALUES
(1, 'Paracetamol', '500mg', 'Liver damage', 'PharmaCorp', 'approved', 0.95),
(2, 'Ibuprofen', '200mg', 'Stomach ulcers', 'Medico', 'approved', 0.88),
(3, 'Remdesivir', '100mg', 'Nausea', 'BioTech', 'under review', 0.72),
(4, 'Amoxicillin', '500mg', 'Allergic reactions', 'PharmaCorp', 'approved', 0.90),
(5, 'Metformin', '500mg', 'Stomach upset', 'Medico', 'approved', 0.85),
(6, 'Lisinopril', '10mg', 'Dizziness', 'BioTech', 'approved', 0.87),
(7, 'Hydroxychloroquine', '200mg', 'Heart problems', 'PharmaCorp', 'under review', 0.60),
(8, 'Azithromycin', '500mg', 'Stomach upset', 'Medico', 'approved', 0.89),
(9, 'Warfarin', '5mg', 'Bleeding', 'BioTech', 'approved', 0.82),
(10, 'Insulin', '10 units', 'Low blood sugar', 'PharmaCorp', 'approved', 0.98),
(11, 'Zinc Tablets', '50mg', 'Nausea', 'HealthMeds', 'approved', 0.80),
(12, 'Vitamin C', '1000mg', 'None', 'NutriCo', 'approved', 0.97),
(13, 'Aspirin', '100mg', 'Bleeding', 'GlobalPharma', 'approved', 0.84),
(14, 'Doxycycline', '100mg', 'Photosensitivity', 'BioTech', 'approved', 0.86),
(15, 'Levothyroxine', '50mcg', 'Sweating', 'EndoCorp', 'approved', 0.91),
(16, 'Clopidogrel', '75mg', 'Nosebleeds', 'CardioMed', 'approved', 0.83),
(17, 'Omeprazole', '20mg', 'Headache', 'GastroInc', 'approved', 0.88),
(18, 'Losartan', '50mg', 'Dizziness', 'HypertensionPlus', 'approved', 0.92),
(19, 'Atorvastatin', '10mg', 'Muscle pain', 'LipHealth', 'approved', 0.89),
(20, 'Albuterol', '90mcg', 'Tremor', 'RespiraLife', 'approved', 0.93);


--Delete From Medication;

INSERT INTO Clinical_Trial (Trial_ID, Trial_Name, Start_Date, End_Date, Status, Location) VALUES
(1, 'Vaccine Trial 1', '2023-01-01', '2023-12-31', 'ongoing', 'New York, USA'),
(2, 'Drug Trial 2', '2022-06-01', '2023-06-01', 'completed', 'Los Angeles, USA'),
(3, 'Therapy Trial 3', '2023-03-01', '2023-09-01', 'cancelled', 'Chicago, USA'),
(4, 'Cancer Treatment Trial', '2023-02-01', '2024-02-01', 'ongoing', 'Houston, USA'),
(5, 'Diabetes Study', '2023-04-01', '2024-04-01', 'ongoing', 'Boston, USA'),
(6, 'Heart Disease Trial', '2023-05-01', '2024-05-01', 'ongoing', 'Seattle, USA'),
(7, 'Alzheimers Research', '2023-06-01', '2024-06-01', 'ongoing', 'San Francisco, USA'),
(8, 'Asthma Treatment Study', '2023-07-01', '2024-07-01', 'ongoing', 'Miami, USA'),
(9, 'Arthritis Drug Trial', '2023-08-01', '2024-08-01', 'ongoing', 'Dallas, USA'),
(10, 'Migraine Treatment Study', '2023-09-01', '2024-09-01', 'ongoing', 'Philadelphia, USA'),
(11, 'Parkinsons Disease Trial', '2023-10-01', '2024-10-01', 'ongoing', 'Denver, USA'),
(12, 'Liver Disease Study', '2023-11-01', '2024-11-01', 'ongoing', 'San Diego, USA'),
(13, 'Kidney Failure Research', '2023-12-01', '2024-12-01', 'completed', 'Portland, USA'),
(14, 'Obesity Treatment Trial', '2023-05-15', '2024-05-15', 'ongoing', 'Atlanta, USA'),
(15, 'Hypertension Management Study', '2023-04-01', '2024-04-01', 'completed', 'Phoenix, USA'),
(16, 'Rare Diseases Therapy Trial', '2023-03-01', '2024-03-01', 'cancelled', 'Austin, USA'),
(17, 'HIV Vaccine Trial', '2023-06-15', '2024-06-15', 'ongoing', 'Washington, D.C., USA'),
(18, 'Mental Health Research', '2023-02-01', '2024-02-01', 'completed', 'Nashville, USA'),
(19, 'Cancer Immunotherapy Study', '2023-01-01', '2023-12-31', 'ongoing', 'Charlotte, USA'),
(20, 'COVID-19 Long-Term Effects Study', '2023-08-01', '2024-08-01', 'ongoing', 'Indianapolis, USA');


INSERT INTO Health_Organization (Organization_ID, Organization_Name, Headquarters_Location, Contact_Info) VALUES
(1, 'CDC', 'Atlanta, USA', 'contact@cdc.gov'),
(2, 'WHO', 'Geneva, Switzerland', 'contact@who.int'),
(3, 'NIH', 'Bethesda, USA', 'contact@nih.gov'),
(4, 'FDA', 'Silver Spring, USA', 'contact@fda.gov'),
(5, 'UNICEF', 'New York, USA', 'contact@unicef.org'),
(6, 'Red Cross', 'Washington D.C., USA', 'contact@redcross.org'),
(7, 'Doctors Without Borders', 'New York, USA', 'contact@msf.org'),
(8, 'American Heart Association', 'Dallas, USA', 'contact@heart.org'),
(9, 'American Cancer Society', 'Atlanta, USA', 'contact@cancer.org'),
(10, 'American Diabetes Association', 'Arlington, USA', 'contact@diabetes.org'),
(11, 'World Food Programme', 'Rome, Italy', 'contact@wfp.org'),
(12, 'Global Fund', 'Geneva, Switzerland', 'contact@globalfund.org'),
(13, 'Gavi, the Vaccine Alliance', 'Geneva, Switzerland', 'contact@gavi.org'),
(14, 'Bill & Melinda Gates Foundation', 'Seattle, USA', 'contact@gatesfoundation.org'),
(15, 'Save the Children', 'London, UK', 'contact@savethechildren.org'),
(16, 'PATH', 'Seattle, USA', 'contact@path.org'),
(17, 'Global Health Council', 'Washington D.C., USA', 'contact@globalhealth.org'),
(18, 'National Kidney Foundation', 'New York, USA', 'contact@kidney.org'),
(19, 'American Lung Association', 'Chicago, USA', 'contact@lung.org'),
(20, 'Operation Smile', 'Virginia Beach, USA', 'contact@operationsmile.org');

INSERT INTO Physician (Physician_ID, Name, Specialty, Contact_Info, City) VALUES
(1, 'Dr. Alice Brown', 'Cardiology', 'alice.brown@hospital.com', 'New York'),
(2, 'Dr. Bob Green', 'Oncology', 'bob.green@hospital.com', 'Los Angeles'),
(3, 'Dr. Charlie Blue', 'Pediatrics', 'charlie.blue@hospital.com', 'Chicago'),
(4, 'Dr. Diana White', 'Neurology', 'diana.white@hospital.com', 'Houston'),
(5, 'Dr. Edward Black', 'Dermatology', 'edward.black@hospital.com', 'Boston'),
(6, 'Dr. Francesca Gray', 'Gastroenterology', 'francesca.gray@hospital.com', 'Seattle'),
(7, 'Dr. George Red', 'Psychiatry', 'george.red@hospital.com', 'San Francisco'),
(8, 'Dr. Helen Pink', 'Obstetrics', 'helen.pink@hospital.com', 'Miami'),
(9, 'Dr. Ian Orange', 'Orthopedics', 'ian.orange@hospital.com', 'Dallas'),
(10, 'Dr. Jane Yellow', 'Endocrinology', 'jane.yellow@hospital.com', 'Philadelphia'),
(11, 'Dr. Kevin Gray', 'Pulmonology', 'kevin.gray@hospital.com', 'Denver'),
(12, 'Dr. Lisa Green', 'Nephrology', 'lisa.green@hospital.com', 'San Diego'),
(13, 'Dr. Andrew Blue', 'Rheumatology', 'andrew.blue@hospital.com', 'Portland'),
(14, 'Dr. Sarah Black', 'Ophthalmology', 'sarah.black@hospital.com', 'Atlanta'),
(15, 'Dr. Rachel White', 'Allergy and Immunology', 'rachel.white@hospital.com', 'Phoenix'),
(16, 'Dr. Daniel Brown', 'Hematology', 'daniel.brown@hospital.com', 'Austin'),
(17, 'Dr. Emily Red', 'Urology', 'emily.red@hospital.com', 'Washington D.C.'),
(18, 'Dr. Benjamin Pink', 'Sports Medicine', 'benjamin.pink@hospital.com', 'Nashville'),
(19, 'Dr. Lauren Yellow', 'Infectious Disease', 'lauren.yellow@hospital.com', 'Charlotte'),
(20, 'Dr. Christopher Orange', 'Geriatrics', 'christopher.orange@hospital.com', 'Indianapolis');


INSERT INTO Hospital (Hospital_ID, Hospital_Name, Location, Capacity, Contact_Info) VALUES
(1, 'General Hospital', 'New York, USA', 500, 'info@generalhospital.com'),
(2, 'City Hospital', 'Los Angeles, USA', 300, 'info@cityhospital.com'),
(3, 'Community Hospital', 'Chicago, USA', 200, 'info@communityhospital.com'),
(4, 'Mercy Hospital', 'Houston, USA', 400, 'info@mercyhospital.com'),
(5, 'St. Mary’s Hospital', 'Boston, USA', 250, 'info@stmaryshospital.com'),
(6, 'University Hospital', 'Seattle, USA', 350, 'info@universityhospital.com'),
(7, 'Memorial Hospital', 'San Francisco, USA', 300, 'info@memorialhospital.com'),
(8, 'Regional Hospital', 'Miami, USA', 200, 'info@regionalhospital.com'),
(9, 'County Hospital', 'Dallas, USA', 250, 'info@countyhospital.com'),
(10, 'Metropolitan Hospital', 'Philadelphia, USA', 300, 'info@metropolitanhospital.com'),
(11, 'Rocky Mountain Hospital', 'Denver, USA', 400, 'info@rockymountainhospital.com'),
(12, 'Pacific Coast Hospital', 'San Diego, USA', 350, 'info@pacificcoasthospital.com'),
(13, 'Rose City Medical Center', 'Portland, USA', 300, 'info@rosecitymedicalcenter.com'),
(14, 'Peach State Hospital', 'Atlanta, USA', 450, 'info@peachstatehospital.com'),
(15, 'Sun Valley Medical Center', 'Phoenix, USA', 400, 'info@sunvalleymedicalcenter.com'),
(16, 'Lone Star Medical Center', 'Austin, USA', 300, 'info@lonestarmedicalcenter.com'),
(17, 'Capitol Hospital', 'Washington D.C., USA', 500, 'info@capitolhospital.com'),
(18, 'Music City Medical Center', 'Nashville, USA', 350, 'info@musiccitymedicalcenter.com'),
(19, 'Queen City Hospital', 'Charlotte, USA', 400, 'info@queencityhospital.com'),
(20, 'Hoosier Medical Center', 'Indianapolis, USA', 300, 'info@hoosiermedicalcenter.com');

-- Insert randomized sample data
INSERT INTO Diagnosis (Diagnosis_ID, Patient_ID, Disease_ID, Diagnosis_Date, Severity) VALUES
(1, 1, 3, '2023-01-15', 'moderate'),
(2, 1, 5, '2023-02-05', 'mild'),
(3, 2, 2, '2023-01-20', 'severe'),
(4, 2, 7, '2023-03-10', 'moderate'),
(5, 3, 1, '2023-02-18', 'severe'),
(6, 3, 4, '2023-03-22', 'mild'),
(7, 4, 6, '2023-04-15', 'moderate'),
(8, 5, 8, '2023-05-10', 'severe'),
(9, 5, 2, '2023-06-12', 'mild'),
(10, 6, 9, '2023-07-20', 'moderate'),
(11, 6, 3, '2023-08-14', 'severe'),
(12, 7, 11, '2023-09-05', 'moderate'),
(13, 8, 12, '2023-09-18', 'severe'),
(14, 8, 13, '2023-10-01', 'mild'),
(15, 9, 10, '2023-10-15', 'moderate'),
(16, 10, 14, '2023-11-05', 'severe'),
(17, 10, 15, '2023-11-18', 'moderate'),
(18, 11, 7, '2023-11-25', 'mild'),
(19, 12, 6, '2023-12-01', 'severe'),
(20, 13, 3, '2023-01-10', 'moderate'),
(21, 13, 5, '2023-02-22', 'severe'),
(22, 14, 8, '2023-03-14', 'mild'),
(23, 15, 11, '2023-04-18', 'severe'),
(24, 15, 12, '2023-05-25', 'moderate'),
(25, 16, 16, '2023-06-05', 'mild'),
(26, 17, 14, '2023-07-15', 'severe'),
(27, 17, 9, '2023-08-20', 'moderate'),
(28, 18, 13, '2023-09-05', 'severe'),
(29, 18, 4, '2023-10-10', 'mild'),
(30, 19, 17, '2023-11-12', 'moderate'),
(31, 19, 18, '2023-12-05', 'severe'),
(32, 20, 19, '2023-12-20', 'mild'),
(33, 20, 10, '2023-01-01', 'severe'),
(34, 4, 15, '2023-01-25', 'moderate'),
(35, 12, 1, '2023-02-10', 'severe'),
(36, 8, 19, '2023-03-30', 'moderate'),
(37, 6, 12, '2023-04-15', 'mild'),
(38, 11, 7, '2023-06-10', 'severe'),
(39, 3, 14, '2023-07-20', 'moderate'),
(40, 17, 16, '2023-09-05', 'mild');

--DELETE FROM Diagnosis;

INSERT INTO Patient_Medicine (Patient_ID, Medication_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);


INSERT INTO Clinical_Trial_Patient (Trial_ID, Patient_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);

INSERT INTO Clinical_Trial_Medication (Trial_ID, Medication_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);

INSERT INTO Health_Organization_Disease (Organization_ID, Disease_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);

INSERT INTO Physician_Patient (Physician_ID, Patient_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);


INSERT INTO Hospital_Patient (Hospital_ID, Patient_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);

--SELECT * FROM Disease;

--SELECT * FROM Patient;

--SELECT * FROM Medication;

--SELECT * FROM Clinical_Trial;

--SELECT * FROM Health_Organization;

--SELECT * FROM Physician;

--SELECT * FROM Hospital;

--SELECT * FROM Diagnosis;

--SELECT * FROM Patient_Medicine;

--SELECT * FROM Clinical_Trial_Patient;

--SELECT * FROM Clinical_Trial_Medication;

--SELECT * FROM Health_Organization_Disease;

--SELECT * FROM Physician_Patient;

--SELECT * FROM Hospital_Patient;

--Patients treated by physician
SELECT ph.Name AS Physician_Name, p.Name AS Patient_Name
FROM Physician_Patient pp
JOIN Physician ph ON pp.Physician_ID = ph.Physician_ID
JOIN Patient p ON pp.Patient_ID = p.Patient_ID
ORDER BY ph.Name, p.Name;

--Patients with Multiple Diagnoses
SELECT p.Name, COUNT(di.Disease_ID) AS Number_of_Diagnoses
FROM Diagnosis di
JOIN Patient p ON di.Patient_ID = p.Patient_ID
GROUP BY p.Name
HAVING COUNT(di.Disease_ID) > 1
ORDER BY Number_of_Diagnoses DESC;

--Mortality rate by diseases
SELECT Disease_Name, Mortality_Rate
FROM Disease
ORDER BY Mortality_Rate DESC
LIMIT 5;

-- An average estimation of patients diagnosed with a particular disease
SELECT d.Disease_Name, AVG(p.Age) AS Average_Age
FROM Diagnosis di
JOIN Disease d ON di.Disease_ID = d.Disease_ID
JOIN Patient p ON di.Patient_ID = p.Patient_ID
GROUP BY d.Disease_Name
ORDER BY Average_Age DESC;

--Common medications prescribed by physicians
SELECT m.Medication_Name, COUNT(pm.Patient_ID) AS Number_of_Prescriptions
FROM Patient_Medicine pm
JOIN Medication m ON pm.Medication_ID = m.Medication_ID
GROUP BY m.Medication_Name
ORDER BY Number_of_Prescriptions DESC
LIMIT 5;



