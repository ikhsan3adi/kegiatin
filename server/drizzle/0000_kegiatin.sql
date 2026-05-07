CREATE TYPE "public"."attendance_status" AS ENUM('PRESENT', 'LATE', 'ABSENT');--> statement-breakpoint
CREATE TYPE "public"."event_status" AS ENUM('DRAFT', 'PUBLISHED', 'ONGOING', 'COMPLETED', 'CANCELLED');--> statement-breakpoint
CREATE TYPE "public"."event_type" AS ENUM('SINGLE', 'SERIES');--> statement-breakpoint
CREATE TYPE "public"."event_visibility" AS ENUM('OPEN', 'INVITE_ONLY');--> statement-breakpoint
CREATE TYPE "public"."rsvp_status" AS ENUM('CONFIRMED', 'CANCELLED', 'WAITLIST');--> statement-breakpoint
CREATE TYPE "public"."session_status" AS ENUM('SCHEDULED', 'ONGOING', 'COMPLETED', 'POSTPONED');--> statement-breakpoint
CREATE TYPE "public"."sync_status" AS ENUM('PENDING', 'SYNCING', 'SYNCED', 'CONFLICT');--> statement-breakpoint
CREATE TYPE "public"."user_role" AS ENUM('ADMIN', 'MEMBER');--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY NOT NULL,
	"email" varchar(255) NOT NULL,
	"password" varchar(255) NOT NULL,
	"display_name" varchar(255) NOT NULL,
	"role" "user_role" DEFAULT 'MEMBER' NOT NULL,
	"npa" varchar(100),
	"cabang" varchar(255),
	"photo_url" varchar(512),
	"email_verified" boolean DEFAULT false NOT NULL,
	"refresh_token_hash" varchar(255),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "events" (
	"id" uuid PRIMARY KEY NOT NULL,
	"title" varchar(500) NOT NULL,
	"description" text DEFAULT '' NOT NULL,
	"type" "event_type" NOT NULL,
	"status" "event_status" DEFAULT 'DRAFT' NOT NULL,
	"visibility" "event_visibility" NOT NULL,
	"location" varchar(500) DEFAULT '' NOT NULL,
	"contact_person" varchar(500) DEFAULT '' NOT NULL,
	"image_url" varchar(512),
	"max_participants" integer,
	"created_by_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"id" uuid PRIMARY KEY NOT NULL,
	"title" varchar(500) NOT NULL,
	"start_time" timestamp with time zone NOT NULL,
	"end_time" timestamp with time zone NOT NULL,
	"location" varchar(500),
	"capacity" integer,
	"order" integer NOT NULL,
	"status" "session_status" DEFAULT 'SCHEDULED' NOT NULL,
	"event_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "rsvps" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"event_id" uuid NOT NULL,
	"qr_token" varchar(512) NOT NULL,
	"status" "rsvp_status" DEFAULT 'CONFIRMED' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "rsvps_qr_token_unique" UNIQUE("qr_token")
);
--> statement-breakpoint
CREATE TABLE "attendances" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"session_id" uuid NOT NULL,
	"rsvp_id" uuid NOT NULL,
	"status" "attendance_status" NOT NULL,
	"sync_status" "sync_status" DEFAULT 'PENDING' NOT NULL,
	"checked_in_at" timestamp with time zone NOT NULL,
	"synced_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "events" ADD CONSTRAINT "events_created_by_id_users_id_fk" FOREIGN KEY ("created_by_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_event_id_events_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "rsvps" ADD CONSTRAINT "rsvps_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "rsvps" ADD CONSTRAINT "rsvps_event_id_events_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_session_id_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "public"."sessions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_rsvp_id_rsvps_id_fk" FOREIGN KEY ("rsvp_id") REFERENCES "public"."rsvps"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_event_title" ON "events" USING btree ("title");--> statement-breakpoint
CREATE INDEX "idx_event_status" ON "events" USING btree ("status");--> statement-breakpoint
CREATE INDEX "idx_event_type" ON "events" USING btree ("type");--> statement-breakpoint
CREATE INDEX "idx_event_created_at" ON "events" USING btree ("created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_rsvp_user_event" ON "rsvps" USING btree ("user_id","event_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_attendance_user_session" ON "attendances" USING btree ("user_id","session_id");