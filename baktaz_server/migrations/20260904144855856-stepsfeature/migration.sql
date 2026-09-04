BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "steps_step_integration" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" uuid NOT NULL,
    "provider" text NOT NULL,
    "status" text NOT NULL,
    "lastError" text,
    "connectedAt" timestamp without time zone,
    "updatedAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "steps_step_sync" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" uuid NOT NULL,
    "sourceDeviceId" text NOT NULL,
    "rawSteps" bigint NOT NULL,
    "filteredSteps" bigint NOT NULL,
    "wasUserEntered" boolean NOT NULL,
    "syncedAt" timestamp without time zone NOT NULL,
    "date" text NOT NULL,
    "syncStatus" text,
    "errorMessage" text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "steps_user_device" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" uuid NOT NULL,
    "deviceModel" text NOT NULL,
    "osVersion" text NOT NULL,
    "appVersion" text NOT NULL,
    "lastActiveAt" timestamp without time zone NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR baktaz
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('baktaz', '20260904144855856-stepsfeature', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260904144855856-stepsfeature', "timestamp" = now();

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
