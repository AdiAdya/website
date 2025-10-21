-- EMERGENCY PRODUCTION FIX for foundUsHow field
-- Run this directly on your production database

BEGIN;

-- Step 1: Ensure the column exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'found_us_how'
    ) THEN
        ALTER TABLE "users" ADD COLUMN "found_us_how" TEXT;
        RAISE NOTICE 'Added found_us_how column to users table';
    ELSE
        RAISE NOTICE 'found_us_how column already exists in users table';
    END IF;
END $$;

-- Step 2: Verify the column was created
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'found_us_how';

-- Step 3: Check recent users
SELECT 
    email, 
    found_us_how, 
    created_at 
FROM users 
WHERE email = 'test@user3.com'
ORDER BY created_at DESC;

COMMIT;

-- VERIFICATION: After running this, the new user test@user3.com should show their foundUsHow value
-- If it's still NULL, then the problem is in the API code, not the database
