BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "user_info" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_info" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userIdentifier" uuid NOT NULL,
    "email" text NOT NULL,
    "firstName" text,
    "lastName" text,
    "username" text NOT NULL,
    "gender" text NOT NULL DEFAULT 'unknown'::text,
    "birthday" timestamp without time zone,
    "mobileNumber" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "username_unique_index" ON "user_info" USING btree ("username");


--
-- MIGRATION VERSION FOR baktaz
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('baktaz', '20260831182500644', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260831182500644', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260416151914983-insights-perf', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416151914983-insights-perf', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260417182253191', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182253191', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260417182309198', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182309198', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20260417182239578', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182239578', "timestamp" = now();


COMMIT;
