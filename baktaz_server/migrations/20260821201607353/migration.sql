BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "home_daily_step_telemetry" (
    "id" bigserial PRIMARY KEY,
    "userId" uuid NOT NULL,
    "date" text NOT NULL,
    "currentSteps" bigint NOT NULL,
    "goalSteps" bigint NOT NULL,
    "syncSource" text NOT NULL,
    "lastSyncedAt" timestamp without time zone NOT NULL,
    "isFlaggedForReview" boolean NOT NULL
);


--
-- MIGRATION VERSION FOR baktaz
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('baktaz', '20260821201607353', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260821201607353', "timestamp" = now();

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
