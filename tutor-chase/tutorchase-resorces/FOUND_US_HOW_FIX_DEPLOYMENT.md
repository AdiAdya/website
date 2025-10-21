# Found Us How Field Fix - Deployment Guide

## Issue Summary
The "Found us how" field was not properly saving to the database and showing "Not specified" in the CMS after user onboarding.

## Root Causes Identified
1. **Database Column**: Missing or inconsistent `found_us_how` column in production database
2. **Frontend Type Issues**: Incorrect type casting in onboarding form
3. **Backend Logic**: Only saving field when truthy (not empty strings)
4. **CMS Display**: Showing raw values instead of human-readable labels

## Fixes Applied

### 1. Frontend Fixes (Client)
- ✅ Fixed type casting in `about-you.tsx` - removed `(data as any).foundUsHow`
- ✅ Added proper store value binding in form initialization
- ✅ Added real-time store updates on field change
- ✅ Added form hydration for foundUsHow field

**Files modified:**
- `tutorchase-resources-platform-client/app/(protected)/onboarding/about-you/about-you.tsx`

### 2. Backend Fixes (API)
- ✅ Fixed condition in `user.service.ts` to save field even when empty string
- ✅ Changed from `if (dto.foundUsHow)` to `if (dto.foundUsHow !== undefined)`

**Files modified:**
- `tutorchase-resources-platform-api/src/modules/user/user.service.ts`

### 3. CMS Fixes
- ✅ Added human-readable label mapping function
- ✅ Replaced emergency fix with proper label display
- ✅ Removed duplicate display section

**Files modified:**
- `tutorchase-resources-platform-cms/app/(protected)/users/[id]/page.tsx`

### 4. Database Migration
- ✅ Created production-safe migration script

## Deployment Steps

### Step 1: Ensure Database Column Exists
Run the production-safe migration to ensure the `found_us_how` column exists:

```bash
# For API database
psql "$DATABASE_URL" -f tutorchase-resources-platform-api/migrations-production-safe/safe_add_found_us_how.sql

# For CMS database (if separate)
psql "$CMS_DATABASE_URL" -f tutorchase-resources-platform-cms/migrations-production-safe/safe_add_found_us_how.sql
```

### Step 2: Deploy Backend Changes
Deploy the API with the updated user service:
```bash
cd tutorchase-resources-platform-api
# Follow your standard deployment process for the development branch
git add .
git commit -m "fix: properly handle foundUsHow field in onboarding"
git push origin development
# Deploy to production
```

### Step 3: Deploy Frontend Changes
Deploy the client with the updated onboarding form:
```bash
cd tutorchase-resources-platform-client
# Follow your standard deployment process for the development branch
git add .
git commit -m "fix: improve foundUsHow field handling in onboarding"
git push origin development
# Deploy to production
```

### Step 4: Deploy CMS Changes
Deploy the CMS with the improved display:
```bash
cd tutorchase-resources-platform-cms
# Follow your standard deployment process for the development branch
git add .
git commit -m "fix: improve foundUsHow field display with human-readable labels"
git push origin development
# Deploy to production
```

## Verification Steps

### 1. Database Verification
```sql
-- Check if column exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'found_us_how';

-- Check existing data
SELECT id, email, found_us_how 
FROM users 
WHERE found_us_how IS NOT NULL 
LIMIT 10;
```

### 2. Test New User Onboarding
1. Go to onboarding flow
2. Fill out "Found Us How" field
3. Complete onboarding
4. Check in CMS that the field shows correctly
5. Verify in database that the value was saved

### 3. Test Existing Users
1. Check existing users in CMS
2. Verify that "Found Us How" field shows "Not specified" for users without data
3. Verify that users with data show the proper human-readable labels

## Expected Results After Deployment

- ✅ New users can select "Found Us How" option during onboarding
- ✅ Selected values are properly saved to database
- ✅ CMS shows human-readable labels (e.g., "Google / Search Engine" instead of "GOOGLE_SEARCH_ENGINE")
- ✅ Users who didn't select anything show "Not specified"
- ✅ No more emergency fix div in CMS

## Rollback Plan

If issues occur, the changes can be rolled back individually:

1. **Database**: The column addition is safe and doesn't need rollback
2. **Backend**: Revert the condition change in user.service.ts
3. **Frontend**: Revert the type casting and form changes
4. **CMS**: Revert to the previous emergency fix display

## Technical Notes

- The database migration is idempotent and safe to run multiple times
- All fixes are backward compatible
- No existing data is modified, only the handling of new data
- The fix addresses both new user onboarding and existing user display

## Contact

If you encounter any issues during deployment, please check:
1. Database connection and migration execution
2. API logs for any onboarding errors
3. Frontend console for any form validation errors
4. CMS display for proper label mapping
