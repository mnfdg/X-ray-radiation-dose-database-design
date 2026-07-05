-- Rank radiographers by average dose for a particular type of exam/anatomy
-- Example here: Abdomen exams, since 2026-01-01.
SELECT
    "operator_code",
    AVG("radiation_dose") AS "average_radiation_dose",
    COUNT(*) AS "number_of_exams"
FROM "exam_details_by_radiographer"
WHERE "anatomy_name" = 'abdomen'
    AND "end_time" >= '2026-01-01'
GROUP BY "radiographer_id"
ORDER BY "average_radiation_dose" ASC
;

-- Rank rooms/pieces of equipment by their averages doses for a particular type of exam
-- Example here: Lumbar spine exams
SELECT
    "room_name",
    "room_type",
    AVG("radiation_dose") AS "average_radiation_dose",
    COUNT(*) AS "number_of_exams"
FROM "exam_details"
WHERE "anatomy_name" = 'lumbar spine'
GROUP BY "room_name"
ORDER BY "average_radiation_dose" DESC
;

-- Compare doses from a period of time for a particular type of exam done in A&E vs. outpatients
-- Example here: Knee, year of 2025
SELECT
    "room_type",
    AVG("radiation_dose") AS "average_radiation_dose",
    COUNT(*) AS "number_of_exams"
FROM "exam_details"
WHERE ("anatomy_name" LIKE '%knee')
    AND ("end_time" BETWEEN '2025-01-01' AND '2025-12-31')
    AND ("room_type" IN ('outpatients', 'a&e'))
GROUP BY "room_type"
;

-- Rank radiographers by image rejection rate and average dose for a type of exam in a particular department
-- Example here: Chest, year of 2025, Treatment Centre site "outpatient" rooms
SELECT
    "operator_code",
    SUM("images_rejected")/SUM("images_used"+"images_rejected") AS "rejection_rate",
    AVG("radiation_dose") AS "average_radiation_dose",
    COUNT(*) AS "number_of_exams"
FROM "exam_details_by_radiographer"
WHERE "anatomy_name" = 'chest'
    AND ("end_time" BETWEEN '2025-01-01' AND '2025-12-31')
    AND "site_name" = "treatment centre"
    AND "room_type" = "outpatient"
GROUP BY "operator_code"
;

-- Add a new radiographer
INSERT INTO "radiographers" ("operator_code", "first_name", "last_name")
VALUES ('RA123456', 'John', 'Smith');

-- Add a new referrer
INSERT INTO "referrers" ("referrer_code", "first_name", "last_name", "speciality")
VALUES ('C1234567', 'Jane', 'Smith', 'Trauma & Orthopaedics');

-- Add a new X-ray room or other piece of equipment
INSERT INTO "rooms" ("room_name", "room_type_id", "site_id")
VALUES (
    'Fuji Nano 8',
    (SELECT "id" FROM "room_types" WHERE "room_type" = 'mobile'),
    (SELECT "id" FROM "sites" WHERE "site_name" = 'treatment centre')
    );
