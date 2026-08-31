BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "remote_localization_audit_log" (
    "id" bigserial PRIMARY KEY,
    "timestamp" timestamp without time zone NOT NULL,
    "author" text NOT NULL,
    "action" text NOT NULL,
    "details" text NOT NULL,
    "previousValue" text,
    "newValue" text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "remote_localization_release" (
    "id" bigserial PRIMARY KEY,
    "version" bigint NOT NULL,
    "publishedBy" text NOT NULL,
    "publishedAt" timestamp without time zone NOT NULL,
    "active" boolean NOT NULL,
    "notes" text,
    "payloadJson" text NOT NULL,
    "checksum" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "remote_localization_release_version_idx" ON "remote_localization_release" USING btree ("version");


--
-- MIGRATION VERSION FOR baktaz
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('baktaz', '20260831110127871-remotelocalization', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260831110127871-remotelocalization', "timestamp" = now();

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
