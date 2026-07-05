-- Represent referring clinicians who make X-ray requests
CREATE TABLE "referrers" (
    "id" INTEGER,
    "referrer_code" TEXT NOT NULL UNIQUE,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "speciality" TEXT,
    PRIMARY KEY("id")
);

-- Represent X-ray requests made by referrers
-- Each request comes from one referrer and includes one or more exams
CREATE TABLE "requests" (
    "id" INTEGER,
    "referrer_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("referrer_id") REFERENCES "referrers"("id")
);

-- Represent completed X-ray examinations
CREATE TABLE "exams" (
    "id" INTEGER,
    "request_id" INTEGER,
    "anatomy_id" INTEGER,
    "radiation_dose" NUMERIC NOT NULL,
    "start_time" TEXT,
    "end_time" TEXT,
    "images_used" INTEGER,
    "images_rejected" INTEGER,
    "room_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("request_id") REFERENCES "requests"("id"),
    FOREIGN KEY("anatomy_id") REFERENCES "anatomy"("id"),
    FOREIGN KEY("room_id") REFERENCES "rooms"("id")
);

-- Represent possible body parts that can be X-rayed, e.g. "Left wrist"
CREATE TABLE "anatomy" (
    "id" INTEGER,
    "anatomy_name" TEXT UNIQUE NOT NULL,
    PRIMARY KEY("id")
);

-- Represent radiographers working at the hospitals
CREATE TABLE "radiographers" (
    "id" INTEGER,
    "operator_code" TEXT NOT NULL UNIQUE,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- Represent which radiographers completed which examinations
CREATE TABLE "completed_by" (
    "id" INTEGER,
    "exam_id" INTEGER,
    "radiographer_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("exam_id") REFERENCES "exams"("id"),
    FOREIGN KEY("radiographer_id") REFERENCES "radiographers"("id")
);

-- Represent X-ray rooms (or other pieces of equipment used to complete exams)
CREATE TABLE "rooms" (
    "id" INTEGER,
    "room_name" TEXT NOT NULL UNIQUE,
    "room_type_id" INTEGER,
    "site_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("room_type_id") REFERENCES "room_types"("id"),
    FOREIGN KEY("site_id") REFERENCES "sites"("id")
);

-- Represent hospital sites
CREATE TABLE "sites" (
    "id" INTEGER,
    "site_name" TEXT UNIQUE NOT NULL,
    PRIMARY KEY("id")
);

-- Represent types of room/equipment
CREATE TABLE "room_types" (
    "id" INTEGER,
    "room_type" TEXT UNIQUE NOT NULL,
    PRIMARY KEY("id")
);

-- View of the details for common exam queries
CREATE VIEW "exam_details" AS
SELECT
    "exams"."id" AS "exam_id",
    "exams"."request_id" AS "request_id",
    "requests"."referrer_id" AS "referrer_id",
    "referrers"."first_name" AS "referrer_first_name",
    "referrers"."last_name" AS "referrer_last_name",
    "referrers"."speciality" AS "referrer_speciality",
    "exams"."anatomy_id" AS "anatomy_id",
    "anatomy"."anatomy_name" AS "anatomy_name",
    "exams"."room_id" AS "room_id",
    "rooms"."room_name" AS "room_name",
    "room_types"."room_type" AS "room_type",
    "sites"."site_name" AS "site_name",
    "exams"."start_time" AS "start_time",
    "exams"."end_time" AS "end_time",
    "exams"."images_used" AS "images_used",
    "exams"."images_rejected" AS "images_rejected",
    "exams"."radiation_dose" AS "radiation_dose"
FROM
    "exams"
    JOIN "requests" ON "exams"."request_id" = "requests"."id"
    JOIN "referrers" ON "requests"."referrer_id" = "referrers"."id"
    JOIN "anatomy" ON "exams"."anatomy_id" = "anatomy"."id"
    JOIN "rooms" ON "rooms"."id" = "exams"."room_id"
    JOIN "room_types" ON "room_types"."id" = "rooms"."room_type_id"
    JOIN "sites" ON "sites"."id" = "rooms"."site_id"
;

-- View of the details for common exam queries, but with one row for each radiographer listed in the "completed_by" table for each exam
-- Warning: This results in duplicate exams where an exam was completed by multiple radiographers
CREATE VIEW "exam_details_by_radiographer" AS
SELECT
    "exams"."id" AS "exam_id",
    "exams"."request_id" AS "request_id",
    "requests"."referrer_id" AS "referrer_id",
    "referrers"."first_name" AS "referrer_first_name",
    "referrers"."last_name" AS "referrer_last_name",
    "referrers"."speciality" AS "referrer_speciality",
    "exams"."anatomy_id" AS "anatomy_id",
    "anatomy"."anatomy_name" AS "anatomy_name",
    "completed_by"."radiographer_id" AS "radiographer_id",
    "radiographers"."operator_code" AS "operator_code",
    "exams"."room_id" AS "room_id",
    "rooms"."room_name" AS "room_name",
    "room_types"."room_type" AS "room_type",
    "sites"."site_name" AS "site_name",
    "exams"."start_time" AS "start_time",
    "exams"."end_time" AS "end_time",
    "exams"."images_used" AS "images_used",
    "exams"."images_rejected" AS "images_rejected",
    "exams"."radiation_dose" AS "radiation_dose"
FROM
    "exams"
    JOIN "requests" ON "exams"."request_id" = "requests"."id"
    JOIN "referrers" ON "requests"."referrer_id" = "referrers"."id"
    JOIN "anatomy" ON "exams"."anatomy_id" = "anatomy"."id"
    JOIN "completed_by" ON "completed_by"."exam_id" = "exams"."id"
    JOIN "radiographers" ON "radiographers"."id" = "completed_by"."radiographer_id"
    JOIN "rooms" ON "rooms"."id" = "exams"."room_id"
    JOIN "room_types" ON "room_types"."id" = "rooms"."room_type_id"
    JOIN "sites" ON "sites"."id" = "rooms"."site_id"
;

-- Create indexes to speed common searches
CREATE INDEX "exams_by_anatomy" ON "exams"("anatomy_id");
CREATE INDEX "exams_by_room" ON "exams"("room_id");
