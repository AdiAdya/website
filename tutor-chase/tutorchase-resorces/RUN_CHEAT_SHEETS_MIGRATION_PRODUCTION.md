# 🚀 Run Cheat Sheets Migration on Production

## Overview
This guide will help you safely add the Cheat Sheets feature tables to your production database following the same process we used for Predicted Papers.

## ✅ What This Migration Does
- Creates 6 new tables for cheat sheets feature
- Adds all necessary foreign keys and indexes
- **Zero data loss** - only adds new tables
- **Zero downtime** - safe for production
- **Idempotent** - safe to run multiple times

## 📋 Tables Being Created
1. `cheat_sheet_pages` - Main grouping pages
2. `cheat_sheet_page_topics` - Topics within pages
3. `cheat_sheet_page_tutors` - Featured tutors
4. `cheat_sheet_page_sidebar_links` - Sidebar navigation
5. `cheat_sheets` - Individual cheat sheets with content
6. `user_to_cheat_sheet_page` - User tracking

---

## 🎯 RECOMMENDED: Use AWS CloudShell

This is the easiest and safest method (same as we did for predicted papers).

### Step 1: Open AWS CloudShell
1. Log into AWS Console
2. Click the **CloudShell** icon at the bottom (next to "Feedback")
3. Wait for CloudShell to initialize (~30 seconds)

### Step 2: Get Database URL
Get it from App Runner:
1. Go to **App Runner** → **tutorchase-resources-platform-api**
2. Click **"Configuration"** tab
3. Find **"Environment variables"** section
4. Copy the `DATABASE_URL` value

It should look like:
```
postgresql://postgres:<password>@tutorchase-production-database.c3i60mm00mq6.eu-west-2.rds.amazonaws.com:5432/tutorchaseproduction
```

### Step 3: Set Environment Variable
In CloudShell:
```bash
export DATABASE_URL="paste-your-database-url-here"
```

### Step 4: Install PostgreSQL Client
```bash
sudo yum install postgresql -y
```

### Step 5: Test Connection
```bash
psql "$DATABASE_URL" -c "SELECT version();" --no-password
```

You should see the PostgreSQL version info.

### Step 6: Create the Migration File
Copy the SQL content into CloudShell:

```bash
cat > safe_add_cheat_sheets.sql << 'EOF'
-- PRODUCTION-SAFE MIGRATION: Add Cheat Sheets Feature

BEGIN;

-- Create cheat_sheet_pages table
CREATE TABLE IF NOT EXISTS "cheat_sheet_pages" (
    "id" TEXT NOT NULL,
    "exam_id" TEXT,
    "headline" TEXT,
    "title" TEXT,
    "add_topic_button_text" TEXT,
    "add_topic_button_link" TEXT,
    "tutor_advert_title" TEXT,
    "tutor_advert_description" TEXT,
    "tutor_advert_button_text" TEXT,
    "tutor_advert_button_link" TEXT,
    "seo_title" TEXT,
    "seo_description" TEXT,
    "is_published" BOOLEAN DEFAULT false,
    "published_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "alert" TEXT,
    CONSTRAINT "cheat_sheet_pages_pkey" PRIMARY KEY ("id")
);

-- Create cheat_sheet_page_topics table
CREATE TABLE IF NOT EXISTS "cheat_sheet_page_topics" (
    "id" TEXT NOT NULL,
    "cheat_sheet_page_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    "is_subscription" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "cheat_sheet_page_topics_pkey" PRIMARY KEY ("id")
);

-- Create cheat_sheet_page_tutors table
CREATE TABLE IF NOT EXISTS "cheat_sheet_page_tutors" (
    "cheat_sheet_page_id" TEXT NOT NULL,
    "tutor_id" TEXT NOT NULL,
    "id" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    CONSTRAINT "cheat_sheet_page_tutors_pkey" PRIMARY KEY ("id")
);

-- Create cheat_sheet_page_sidebar_links table
CREATE TABLE IF NOT EXISTS "cheat_sheet_page_sidebar_links" (
    "id" TEXT NOT NULL,
    "cheat_sheet_page_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    CONSTRAINT "cheat_sheet_page_sidebar_links_pkey" PRIMARY KEY ("id")
);

-- Create cheat_sheets table
CREATE TABLE IF NOT EXISTS "cheat_sheets" (
    "id" TEXT NOT NULL,
    "exam_id" TEXT,
    "author_id" TEXT,
    "topic_id" TEXT,
    "internal_title" TEXT,
    "headline" TEXT,
    "title" TEXT,
    "slug" TEXT,
    "body" TEXT,
    "section_head" TEXT,
    "expert_help_button_text" TEXT,
    "expert_help_button_link" TEXT,
    "topic_questions_button_link" TEXT,
    "topic_questions_button_text" TEXT,
    "seo_title" TEXT,
    "seo_description" TEXT,
    "is_published" BOOLEAN DEFAULT false,
    "published_at" TIMESTAMP(3),
    "position" INTEGER,
    "alert" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "cheat_sheets_pkey" PRIMARY KEY ("id")
);

-- Create user_to_cheat_sheet_page table
CREATE TABLE IF NOT EXISTS "user_to_cheat_sheet_page" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "cheat_sheet_page_id" TEXT NOT NULL,
    "cheat_sheet_id" TEXT,
    "watched_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_to_cheat_sheet_page_pkey" PRIMARY KEY ("id")
);

-- Create indexes
CREATE UNIQUE INDEX IF NOT EXISTS "cheat_sheet_pages_title_key" ON "cheat_sheet_pages"("title");
CREATE UNIQUE INDEX IF NOT EXISTS "cheat_sheets_internal_title_key" ON "cheat_sheets"("internal_title");
CREATE UNIQUE INDEX IF NOT EXISTS "user_to_cheat_sheet_page_user_id_cheat_sheet_page_id_key" ON "user_to_cheat_sheet_page"("user_id", "cheat_sheet_page_id");

-- Add foreign keys
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheet_pages_exam_id_fkey') THEN
        ALTER TABLE "cheat_sheet_pages" ADD CONSTRAINT "cheat_sheet_pages_exam_id_fkey" 
        FOREIGN KEY ("exam_id") REFERENCES "exams"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheet_page_topics_cheat_sheet_page_id_fkey') THEN
        ALTER TABLE "cheat_sheet_page_topics" ADD CONSTRAINT "cheat_sheet_page_topics_cheat_sheet_page_id_fkey" 
        FOREIGN KEY ("cheat_sheet_page_id") REFERENCES "cheat_sheet_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheet_page_tutors_cheat_sheet_page_id_fkey') THEN
        ALTER TABLE "cheat_sheet_page_tutors" ADD CONSTRAINT "cheat_sheet_page_tutors_cheat_sheet_page_id_fkey" 
        FOREIGN KEY ("cheat_sheet_page_id") REFERENCES "cheat_sheet_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheet_page_tutors_tutor_id_fkey') THEN
        ALTER TABLE "cheat_sheet_page_tutors" ADD CONSTRAINT "cheat_sheet_page_tutors_tutor_id_fkey" 
        FOREIGN KEY ("tutor_id") REFERENCES "tutors"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheet_page_sidebar_links_cheat_sheet_page_id_fkey') THEN
        ALTER TABLE "cheat_sheet_page_sidebar_links" ADD CONSTRAINT "cheat_sheet_page_sidebar_links_cheat_sheet_page_id_fkey" 
        FOREIGN KEY ("cheat_sheet_page_id") REFERENCES "cheat_sheet_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheets_exam_id_fkey') THEN
        ALTER TABLE "cheat_sheets" ADD CONSTRAINT "cheat_sheets_exam_id_fkey" 
        FOREIGN KEY ("exam_id") REFERENCES "exams"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheets_author_id_fkey') THEN
        ALTER TABLE "cheat_sheets" ADD CONSTRAINT "cheat_sheets_author_id_fkey" 
        FOREIGN KEY ("author_id") REFERENCES "authors"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cheat_sheets_topic_id_fkey') THEN
        ALTER TABLE "cheat_sheets" ADD CONSTRAINT "cheat_sheets_topic_id_fkey" 
        FOREIGN KEY ("topic_id") REFERENCES "cheat_sheet_page_topics"("id") ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_to_cheat_sheet_page_user_id_fkey') THEN
        ALTER TABLE "user_to_cheat_sheet_page" ADD CONSTRAINT "user_to_cheat_sheet_page_user_id_fkey" 
        FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_to_cheat_sheet_page_cheat_sheet_page_id_fkey') THEN
        ALTER TABLE "user_to_cheat_sheet_page" ADD CONSTRAINT "user_to_cheat_sheet_page_cheat_sheet_page_id_fkey" 
        FOREIGN KEY ("cheat_sheet_page_id") REFERENCES "cheat_sheet_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_to_cheat_sheet_page_cheat_sheet_id_fkey') THEN
        ALTER TABLE "user_to_cheat_sheet_page" ADD CONSTRAINT "user_to_cheat_sheet_page_cheat_sheet_id_fkey" 
        FOREIGN KEY ("cheat_sheet_id") REFERENCES "cheat_sheets"("id") ON DELETE CASCADE ON UPDATE CASCADE;
    END IF;
END $$;

COMMIT;
EOF
```

### Step 7: Execute the Migration
```bash
psql "$DATABASE_URL" -f safe_add_cheat_sheets.sql --no-password
```

### Step 8: Verify Tables Were Created
```bash
psql "$DATABASE_URL" -c "SELECT table_name FROM information_schema.tables WHERE table_name LIKE '%cheat_sheet%' ORDER BY table_name;" --no-password
```

You should see:
```
       table_name        
-------------------------
 cheat_sheet_page_sidebar_links
 cheat_sheet_page_topics
 cheat_sheet_page_tutors
 cheat_sheet_pages
 cheat_sheets
 user_to_cheat_sheet_page
(6 rows)
```

---

## ✅ Success Indicators

After migration:
- ✅ All 6 tables created
- ✅ All indexes created
- ✅ All foreign keys added
- ✅ No errors in output
- ✅ API endpoint `/cheat-sheet-pages` returns empty array (not 500 error)

---

## 🧪 Testing After Migration

### Test API Endpoint (from CloudShell or local):
```bash
curl https://your-api-url.com/cheat-sheet-pages?page=1&pageSize=10
```

Expected: `{"cheatSheetPages":[],"meta":{...}}`

### Test CMS:
1. Open CMS
2. Navigate to **Pages → Cheat Sheet Pages**
3. Click **"Add"**
4. Fill in form and save
5. Should save without errors!

---

## 📝 Migration File Location

The migration file is already created at:
```
tutorchase-resources-platform-api/migrations-production-safe/safe_add_cheat_sheets.sql
```

And there's an automated script at:
```
tutorchase-resources-platform-api/execute-cheat-sheets-migration.sh
```

---

## ⚠️ Important Notes

1. **Safe to Re-run**: Uses `IF NOT EXISTS`, won't cause errors if run multiple times
2. **No Downtime**: All operations are non-blocking
3. **Transactional**: Wrapped in BEGIN/COMMIT for automatic rollback on error
4. **Same Process**: Identical to predicted papers migration that worked successfully

---

## 🚨 If Something Goes Wrong

The migration is wrapped in a transaction - if any error occurs, **everything will automatically rollback**.

To check if tables exist:
```bash
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name LIKE '%cheat_sheet%';" --no-password
```

Should return `6` if migration succeeded.

---

## 📞 Next Steps After Migration

1. ✅ Tables created in production database
2. 🔄 Deploy API code to production (already has the cheat sheet modules)
3. 🔄 Deploy CMS to production (already has cheat sheet pages)
4. 🔄 Deploy Client to production (already has cheat sheet frontend)
5. 🎉 Feature is live!

---

## 🎯 Quick Command Summary

```bash
# 1. Set DATABASE_URL
export DATABASE_URL="your-database-url-from-app-runner"

# 2. Install psql (if needed)
sudo yum install postgresql -y

# 3. Test connection
psql "$DATABASE_URL" -c "SELECT version();" --no-password

# 4. Run migration
psql "$DATABASE_URL" << 'EOF'
[paste the SQL from safe_add_cheat_sheets.sql]
EOF

# 5. Verify
psql "$DATABASE_URL" -c "SELECT table_name FROM information_schema.tables WHERE table_name LIKE '%cheat_sheet%' ORDER BY table_name;" --no-password
```

That's it! The migration should complete in < 1 second. 🚀

