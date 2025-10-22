# 🚀 Predicted Papers Manual Migration Instructions

## ⚠️ Problem
The predicted papers and prediction pages tables are missing from the production database, causing 500 errors in the CMS.

## 📋 What This Migration Does
- Creates 10 new tables for predicted papers feature
- Adds `show_predicted_papers` column to existing `exams` table
- All operations use `IF NOT EXISTS` - safe to run multiple times
- No data deletion or modification - only creates new tables

## 🎯 Tables Created
1. `prediction_pages` - Landing pages for predicted papers
2. `prediction_pages_subject_chapters` - Chapter associations
3. `prediction_pages_subject_subtopics` - Subtopic associations
4. `prediction_pages_related_pages` - Related pages links
5. `predicted_papers` - The actual predicted paper exams
6. `predicted_papers_questions` - Questions in each paper
7. `answered_predicted_papers` - User progress tracking
8. `answered_predicted_papers_answers` - User answers
9. `answered_predicted_papers_questions` - Question attempts
10. Plus: `show_predicted_papers` column added to `exams` table

---

## 🔧 Option 1: AWS CloudShell (Recommended)

### Step 1: Get Database Connection String
```bash
# In AWS Console, go to App Runner > tutorchase-resources-platform-api > Configuration
# Copy the DATABASE_URL environment variable value
```

### Step 2: Open CloudShell
```bash
# Click the CloudShell icon in AWS Console (top right)
# Wait for shell to initialize
```

### Step 3: Install PostgreSQL Client
```bash
sudo yum install -y postgresql
```

### Step 4: Download Migration File
```bash
# Get the migration SQL file from the repository
wget https://raw.githubusercontent.com/TutorChaseDev/tutorchase-resources-platform-api/main/migrations-production-safe/safe_add_predicted_papers.sql
```

### Step 5: Test Connection
```bash
# Replace YOUR_DATABASE_URL with actual URL from Step 1
export DATABASE_URL="YOUR_DATABASE_URL"
psql "$DATABASE_URL" -c "SELECT version();"
```

### Step 6: Check Existing Tables
```bash
psql "$DATABASE_URL" -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%prediction%' OR table_name LIKE '%predicted%')
ORDER BY table_name;"
```

### Step 7: Run Migration
```bash
psql "$DATABASE_URL" -f safe_add_predicted_papers.sql
```

### Step 8: Verify Success
```bash
psql "$DATABASE_URL" -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%prediction%' OR table_name LIKE '%predicted%')
ORDER BY table_name;"
```

You should see 9 tables listed:
- `answered_predicted_papers`
- `answered_predicted_papers_answers`
- `answered_predicted_papers_questions`
- `predicted_papers`
- `predicted_papers_questions`
- `prediction_pages`
- `prediction_pages_related_pages`
- `prediction_pages_subject_chapters`
- `prediction_pages_subject_subtopics`

---

## 🔧 Option 2: Local Machine (If you have database access)

### Prerequisites
- PostgreSQL client installed (`psql` command available)
- Network access to production database
- Database connection string

### Step 1: Clone Repository (if not already)
```bash
cd /Users/new/tutor-chase/tutorchase-resorces/tutorchase-resources-platform-api
```

### Step 2: Set Database URL
```bash
# Get DATABASE_URL from Vercel/AWS environment variables
export DATABASE_URL="postgresql://..."
```

### Step 3: Test Connection
```bash
psql "$DATABASE_URL" -c "SELECT version();"
```

### Step 4: Run Migration Script
```bash
chmod +x execute-predicted-papers-migration.sh
./execute-predicted-papers-migration.sh
```

---

## 🔧 Option 3: Direct SQL Execution

If you have a database GUI tool (like pgAdmin, DBeaver, DataGrip):

1. **Open the SQL file**: `tutorchase-resources-platform-api/migrations-production-safe/safe_add_predicted_papers.sql`
2. **Connect to production database** using the DATABASE_URL credentials
3. **Copy and paste the entire SQL** into a query window
4. **Execute** the SQL
5. **Verify** by running:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%prediction%' OR table_name LIKE '%predicted%')
ORDER BY table_name;
```

---

## 🔧 Option 4: AWS RDS Query Editor

### Step 1: Find Database ARN
```bash
# Go to AWS Console > RDS > Databases
# Click on your database instance
# Copy the ARN (Amazon Resource Name)
```

### Step 2: Open Query Editor
```bash
# In AWS Console, go to RDS > Query Editor
# Select your database
# Choose authentication method (Secret Manager or database credentials)
```

### Step 3: Paste and Execute SQL
```sql
-- Copy the entire contents of safe_add_predicted_papers.sql
-- Paste into Query Editor
-- Click "Run"
```

---

## 🐛 Troubleshooting

### Error: "psql: command not found"
**Solution**: Install PostgreSQL client
- **macOS**: `brew install postgresql`
- **Ubuntu/Debian**: `sudo apt-get install postgresql-client`
- **RHEL/Amazon Linux**: `sudo yum install postgresql`
- **Windows**: Download from https://www.postgresql.org/download/windows/

### Error: "connection refused" or "timeout"
**Possible causes**:
1. Database security group doesn't allow your IP
2. DATABASE_URL is incorrect
3. Database is in a private VPC

**Solution**: Use AWS CloudShell (it's already in the AWS network)

### Error: "permission denied"
**Cause**: Database user doesn't have CREATE TABLE permissions

**Solution**: Ensure you're using the admin/main database user (check DATABASE_URL)

### Error: "relation already exists"
**This is OK!** The migration uses `IF NOT EXISTS`, so this just means some tables already exist. The migration will skip existing tables and create missing ones.

### Tables Still Missing After Migration
**Check**:
1. Did the migration complete successfully? (Check output)
2. Are you connected to the correct database? (Verify DATABASE_URL)
3. Run verification query to see which tables exist

---

## ✅ Success Indicators

After successful migration, you should see:

1. **9 new tables** when you run the verification query
2. **No 500 errors** when accessing predicted papers in CMS
3. **Prediction pages save successfully** in CMS
4. **Can publish predicted papers** from CMS

---

## 🔍 Why Automatic Migration Failed

The automatic migration in the Docker container likely failed because:
1. **`psql` not available** - Fixed by installing `postgresql-client` in Dockerfile
2. **Script exits on error** - Fixed by making migration non-blocking in `start.sh`
3. **Connection issues** - Docker container may not have proper network access during startup
4. **Environment variables** - DATABASE_URL might not be properly formatted for `psql`

Even though we fixed items 1 and 2, the migration might still be failing silently. That's why manual execution is the safest approach.

---

## 📝 Post-Migration Checklist

After running the migration:

- [ ] Verify all 9 tables exist in database
- [ ] Check CMS predicted papers page loads without 500 error
- [ ] Test creating a new prediction page
- [ ] Test saving a prediction page
- [ ] Test publishing a predicted paper
- [ ] Verify frontend displays predicted papers correctly

---

## 🆘 Need Help?

If you encounter issues:

1. **Check CloudWatch Logs**: AWS Console > App Runner > Logs
2. **Check Database Logs**: AWS Console > RDS > Logs
3. **Verify Environment Variables**: Ensure DATABASE_URL is set correctly
4. **Test Database Connection**: Use `psql` to connect manually
5. **Review Migration SQL**: Check `safe_add_predicted_papers.sql` for any syntax errors

---

## 📌 Important Notes

- ✅ This migration is **SAFE** to run multiple times
- ✅ No existing data will be **modified or deleted**
- ✅ Only **creates new tables** if they don't exist
- ✅ All operations are **transactional** (rollback on error)
- ✅ **Zero downtime** - no impact on running application
- ✅ Database must be **PostgreSQL** (version 12+)

---

## 🔗 Related Files

- **Migration SQL**: `tutorchase-resources-platform-api/migrations-production-safe/safe_add_predicted_papers.sql`
- **Execution Script**: `tutorchase-resources-platform-api/execute-predicted-papers-migration.sh`
- **Startup Script**: `tutorchase-resources-platform-api/start.sh`
- **Dockerfile**: `tutorchase-resources-platform-api/Dockerfile`
- **Schema**: `tutorchase-resources-platform-api/prisma/schema.prisma`

---

**Last Updated**: October 22, 2025
**Status**: Manual execution required - automatic migration not working in production

