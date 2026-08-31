BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "config_key" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "key" text NOT NULL,
    "valueType" text NOT NULL,
    "defaultValue" text NOT NULL,
    "description" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "config_key_key_unique_idx" ON "config_key" USING btree ("key");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "config_snapshot_version" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "versionNumber" text NOT NULL,
    "updateTime" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updateUserEmail" text,
    "updateOrigin" text,
    "updateType" text
);

-- Indexes
CREATE UNIQUE INDEX "config_version_number_idx" ON "config_snapshot_version" USING btree ("versionNumber");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "targeting_override" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "configKeyId" uuid NOT NULL,
    "priority" bigint NOT NULL,
    "appVersionConstraint" text,
    "userTiers" json,
    "customSegmentValues" json,
    "rolloutPercentage" bigint,
    "servedValue" text NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE INDEX "targeting_override_priority_idx" ON "targeting_override" USING btree ("configKeyId", "priority");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "targeting_override"
    ADD CONSTRAINT "targeting_override_fk_0"
    FOREIGN KEY("configKeyId")
    REFERENCES "config_key"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR baktaz
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('baktaz', '20260831053549010', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260831053549010', "timestamp" = now();

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
