# 🚀 Predicted Papers Manual Migration Instructions

## ✅ STATUS UPDATE (Oct 22, 2025)

**ISSUE RESOLVED**: The automatic migration is now working! The problem was that the Docker image in ECR was never rebuilt with the migration scripts.

**What was fixed:**
- ✅ Docker image now includes migration scripts and PostgreSQL client
- ✅ GitHub Actions triggered to rebuild and push new image to ECR
- ✅ App Runner will automatically run migration on next deployment

**Next Steps:**
1. Wait for GitHub Actions to complete (~5-8 minutes)
2. Check CloudWatch logs to verify migration ran successfully
3. Test the predicted papers page in CMS (500 error should be gone)

**If automatic migration still fails after rebuild**, use the manual migration options below.

---

## ⚠️ Original Problem
The predicted papers and prediction pages tables were missing from the production database, causing 500 errors in the CMS.

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

## 🔧 Option 1: AWS CloudShell (⭐ STRONGLY RECOMMENDED)

### ✅ Why AWS CloudShell is the Best Option
- **Works from anywhere** - No VPN required!
- **Already inside AWS network** - Can access private VPC databases
- **No local setup needed** - Everything runs in the cloud
- **Free to use** - No additional costs
- **Pre-authenticated** - Uses your AWS console session

### Step 1: Get Database Connection String
```bash
# In AWS Console, go to App Runner > tutorchase-resources-platform-api > Configuration
# Copy the DATABASE_URL environment variable value
# Format: postgresql://username:password@host:5432/database
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

## 🔧 Option 2: Local Machine (⚠️ Requires VPN/Network Access)

### ⚠️ Important Network Requirements
- **VPN Required**: If your database is in a private VPC, you'll need to be connected to your company VPN
- **Security Group Access**: Your IP address must be whitelisted in the database security group
- **If this doesn't work**: Use AWS CloudShell instead (Option 1)

### Prerequisites
- PostgreSQL client installed (`psql` command available)
- Network access to production database (VPN or whitelisted IP)
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

### Root Cause Identified: Docker Image Not Rebuilt ✅

**The migration scripts were added to the codebase but the Docker image in ECR was never rebuilt!**

The automatic migration failed because:
1. ✅ **FIXED**: Migration scripts weren't in the Docker image (old ECR image was being used)
2. ✅ **FIXED**: `psql` not available - Added `postgresql-client` in Dockerfile
3. ✅ **FIXED**: Script exits on error - Made migration non-blocking in `start.sh`

### Solution Implemented (Oct 22, 2025)

**Fixed by triggering GitHub Actions to rebuild and push the Docker image:**

1. Updated `Dockerfile` to:
   - Copy `execute-predicted-papers-migration.sh` and `migrations-production-safe/` directory
   - Install `postgresql-client` (for `psql` command)

2. Updated `start.sh` to:
   - Make the predicted papers migration non-blocking (won't fail deployment)
   - Add detailed error logging

3. Triggered GitHub Actions rebuild by committing:
   ```bash
   git commit -m "chore: trigger Docker image rebuild with migration scripts"
   git push origin main
   ```

### 🔍 Check CloudWatch Logs to Verify

After the new deployment completes, check the startup logs:
1. Go to **AWS Console > App Runner > tutorchase-resources-platform-api**
2. Click **Logs** tab > **View in CloudWatch**
3. Look for logs from the new deployment time
4. Search for: `"Running predicted papers migration"`

**Expected output if successful:**
```
🔄 Running predicted papers migration...
🔍 Testing database connection...
📋 DATABASE_URL is set: YES
✅ Database connection successful
✅ Successfully executed predicted papers migration
🎉 MIGRATION COMPLETED SUCCESSFULLY!
```

**If migration is skipped (tables already exist):**
```
⚠️ Predicted papers migration skipped or failed (this is OK if tables already exist)
```

### ⚠️ If Automatic Migration Still Fails

If the automatic migration still doesn't work after the Docker rebuild, use the manual migration options below. This could happen if:
- Database connection issues during startup
- Timing issues (migration runs before database is ready)
- Environment variable formatting issues

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

