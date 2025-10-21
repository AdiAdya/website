-- EMERGENCY PRODUCTION FIX for Predicted Papers Feature
-- Run this directly on your production database via AWS RDS Query Editor or psql
-- This creates all tables with IF NOT EXISTS to handle partial creation

BEGIN;

-- Step 1: Create all tables with IF NOT EXISTS
DO $$
BEGIN
    -- Create prediction_pages table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prediction_pages') THEN
        CREATE TABLE "prediction_pages" (
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
            CONSTRAINT "prediction_pages_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created prediction_pages table';
    ELSE
        RAISE NOTICE 'prediction_pages table already exists';
    END IF;

    -- Create prediction_page_topics table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prediction_page_topics') THEN
        CREATE TABLE "prediction_page_topics" (
            "id" TEXT NOT NULL,
            "prediction_page_id" TEXT NOT NULL,
            "name" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            "is_subscription" BOOLEAN NOT NULL DEFAULT false,
            CONSTRAINT "prediction_page_topics_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created prediction_page_topics table';
    ELSE
        RAISE NOTICE 'prediction_page_topics table already exists';
    END IF;

    -- Create prediction_page_tutors table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prediction_page_tutors') THEN
        CREATE TABLE "prediction_page_tutors" (
            "prediction_page_id" TEXT NOT NULL,
            "tutor_id" TEXT NOT NULL,
            "id" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            CONSTRAINT "prediction_page_tutors_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created prediction_page_tutors table';
    ELSE
        RAISE NOTICE 'prediction_page_tutors table already exists';
    END IF;

    -- Create prediction_page_sidebar_links table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prediction_page_sidebar_links') THEN
        CREATE TABLE "prediction_page_sidebar_links" (
            "id" TEXT NOT NULL,
            "prediction_page_id" TEXT NOT NULL,
            "name" TEXT NOT NULL,
            "url" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            CONSTRAINT "prediction_page_sidebar_links_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created prediction_page_sidebar_links table';
    ELSE
        RAISE NOTICE 'prediction_page_sidebar_links table already exists';
    END IF;

    -- Create prediction_categories table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prediction_categories') THEN
        CREATE TABLE "prediction_categories" (
            "id" TEXT NOT NULL,
            "title" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            "prediction_page_id" TEXT NOT NULL,
            CONSTRAINT "prediction_categories_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created prediction_categories table';
    ELSE
        RAISE NOTICE 'prediction_categories table already exists';
    END IF;

    -- Create predicted_papers table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'predicted_papers') THEN
        CREATE TABLE "predicted_papers" (
            "id" TEXT NOT NULL,
            "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "exam_id" TEXT,
            "headline" TEXT,
            "internal_title" TEXT,
            "is_published" BOOLEAN DEFAULT false,
            "published_at" TIMESTAMP(3),
            "seo_description" TEXT,
            "seo_title" TEXT,
            "slug" TEXT,
            "title" TEXT,
            "topic_id" TEXT,
            "updatedAt" TIMESTAMP(3) NOT NULL,
            "show_category" BOOLEAN,
            "show_difficulty" BOOLEAN,
            "show_info" BOOLEAN,
            "topic_notes_button_link" TEXT,
            "topic_notes_button_text" TEXT,
            "position" INTEGER,
            "alert" TEXT,
            CONSTRAINT "predicted_papers_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created predicted_papers table';
    ELSE
        RAISE NOTICE 'predicted_papers table already exists';
    END IF;

    -- Create multiple_choice_prediction_questions table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'multiple_choice_prediction_questions') THEN
        CREATE TABLE "multiple_choice_prediction_questions" (
            "id" TEXT NOT NULL,
            "predicted_paper_id" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            "source" TEXT,
            "info" TEXT,
            "category_id" TEXT,
            "difficulty" "QuestionQuestionDifficulty",
            "text" TEXT NOT NULL,
            "mark" INTEGER,
            "answer_letter" TEXT,
            "answer" TEXT NOT NULL,
            CONSTRAINT "multiple_choice_prediction_questions_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created multiple_choice_prediction_questions table';
    ELSE
        RAISE NOTICE 'multiple_choice_prediction_questions table already exists';
    END IF;

    -- Create one_part_prediction_questions table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'one_part_prediction_questions') THEN
        CREATE TABLE "one_part_prediction_questions" (
            "id" TEXT NOT NULL,
            "predicted_paper_id" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            "source" TEXT,
            "info" TEXT,
            "category_id" TEXT,
            "difficulty" "QuestionQuestionDifficulty",
            "text" TEXT NOT NULL,
            "mark" INTEGER,
            "answer" TEXT NOT NULL,
            CONSTRAINT "one_part_prediction_questions_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created one_part_prediction_questions table';
    ELSE
        RAISE NOTICE 'one_part_prediction_questions table already exists';
    END IF;

    -- Create multiple_part_prediction_questions table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'multiple_part_prediction_questions') THEN
        CREATE TABLE "multiple_part_prediction_questions" (
            "id" TEXT NOT NULL,
            "predicted_paper_id" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            "source" TEXT,
            "info" TEXT,
            "category_id" TEXT,
            "difficulty" "QuestionQuestionDifficulty",
            "show_answer_parts_separately" BOOLEAN,
            "total_mark" INTEGER,
            CONSTRAINT "multiple_part_prediction_questions_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created multiple_part_prediction_questions table';
    ELSE
        RAISE NOTICE 'multiple_part_prediction_questions table already exists';
    END IF;

    -- Create multiple_part_prediction_question_descriptions table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'multiple_part_prediction_question_descriptions') THEN
        CREATE TABLE "multiple_part_prediction_question_descriptions" (
            "id" TEXT NOT NULL,
            "predicted_paper_id" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            "text" TEXT NOT NULL,
            CONSTRAINT "multiple_part_prediction_question_descriptions_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created multiple_part_prediction_question_descriptions table';
    ELSE
        RAISE NOTICE 'multiple_part_prediction_question_descriptions table already exists';
    END IF;

    -- Create multiple_part_prediction_question_parts table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'multiple_part_prediction_question_parts') THEN
        CREATE TABLE "multiple_part_prediction_question_parts" (
            "id" TEXT NOT NULL,
            "predicted_paper_id" TEXT NOT NULL,
            "position" INTEGER NOT NULL,
            "name" TEXT,
            "text" TEXT NOT NULL,
            "mark" INTEGER,
            "answer" TEXT NOT NULL,
            CONSTRAINT "multiple_part_prediction_question_parts_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created multiple_part_prediction_question_parts table';
    ELSE
        RAISE NOTICE 'multiple_part_prediction_question_parts table already exists';
    END IF;

    -- Create users_to_prediction_pages table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users_to_prediction_pages') THEN
        CREATE TABLE "users_to_prediction_pages" (
            "user_id" TEXT NOT NULL,
            "prediction_page_id" TEXT NOT NULL,
            "last_watched_predicted_paper_id" TEXT NOT NULL,
            "last_watched_time" TIMESTAMP(3) NOT NULL,
            "updated_at" TIMESTAMP(3) NOT NULL,
            "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT "users_to_prediction_pages_pkey" PRIMARY KEY ("user_id","prediction_page_id")
        );
        RAISE NOTICE 'Created users_to_prediction_pages table';
    ELSE
        RAISE NOTICE 'users_to_prediction_pages table already exists';
    END IF;

    -- Create answered_predicted_papers table
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'answered_predicted_papers') THEN
        CREATE TABLE "answered_predicted_papers" (
            "id" TEXT NOT NULL,
            "multiple_choice_question_id" TEXT,
            "one_part_question_id" TEXT,
            "multiple_part_question_id" TEXT,
            "user_id" TEXT NOT NULL,
            "answer" TEXT,
            "is_completed" BOOLEAN NOT NULL DEFAULT true,
            CONSTRAINT "answered_predicted_papers_pkey" PRIMARY KEY ("id")
        );
        RAISE NOTICE 'Created answered_predicted_papers table';
    ELSE
        RAISE NOTICE 'answered_predicted_papers table already exists';
    END IF;

    -- Add show_predicted_papers column to exams
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'exams' AND column_name = 'show_predicted_papers'
    ) THEN
        ALTER TABLE "exams" ADD COLUMN "show_predicted_papers" BOOLEAN NOT NULL DEFAULT false;
        RAISE NOTICE 'Added show_predicted_papers column to exams table';
    ELSE
        RAISE NOTICE 'show_predicted_papers column already exists in exams table';
    END IF;
END $$;

-- Step 2: Add foreign keys (only if they don't exist)
DO $$
BEGIN
    -- prediction_pages foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'prediction_pages_exam_id_fkey') THEN
        ALTER TABLE "prediction_pages" ADD CONSTRAINT "prediction_pages_exam_id_fkey" 
        FOREIGN KEY ("exam_id") REFERENCES "exams"("id") ON DELETE SET NULL ON UPDATE CASCADE;
        RAISE NOTICE 'Added prediction_pages_exam_id_fkey';
    END IF;

    -- prediction_page_topics foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'prediction_page_topics_prediction_page_id_fkey') THEN
        ALTER TABLE "prediction_page_topics" ADD CONSTRAINT "prediction_page_topics_prediction_page_id_fkey" 
        FOREIGN KEY ("prediction_page_id") REFERENCES "prediction_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added prediction_page_topics_prediction_page_id_fkey';
    END IF;

    -- prediction_page_tutors foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'prediction_page_tutors_prediction_page_id_fkey') THEN
        ALTER TABLE "prediction_page_tutors" ADD CONSTRAINT "prediction_page_tutors_prediction_page_id_fkey" 
        FOREIGN KEY ("prediction_page_id") REFERENCES "prediction_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added prediction_page_tutors_prediction_page_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'prediction_page_tutors_tutor_id_fkey') THEN
        ALTER TABLE "prediction_page_tutors" ADD CONSTRAINT "prediction_page_tutors_tutor_id_fkey" 
        FOREIGN KEY ("tutor_id") REFERENCES "tutors"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added prediction_page_tutors_tutor_id_fkey';
    END IF;

    -- prediction_page_sidebar_links foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'prediction_page_sidebar_links_prediction_page_id_fkey') THEN
        ALTER TABLE "prediction_page_sidebar_links" ADD CONSTRAINT "prediction_page_sidebar_links_prediction_page_id_fkey" 
        FOREIGN KEY ("prediction_page_id") REFERENCES "prediction_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added prediction_page_sidebar_links_prediction_page_id_fkey';
    END IF;

    -- prediction_categories foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'prediction_categories_prediction_page_id_fkey') THEN
        ALTER TABLE "prediction_categories" ADD CONSTRAINT "prediction_categories_prediction_page_id_fkey" 
        FOREIGN KEY ("prediction_page_id") REFERENCES "prediction_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added prediction_categories_prediction_page_id_fkey';
    END IF;

    -- predicted_papers foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'predicted_papers_exam_id_fkey') THEN
        ALTER TABLE "predicted_papers" ADD CONSTRAINT "predicted_papers_exam_id_fkey" 
        FOREIGN KEY ("exam_id") REFERENCES "exams"("id") ON DELETE SET NULL ON UPDATE CASCADE;
        RAISE NOTICE 'Added predicted_papers_exam_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'predicted_papers_topic_id_fkey') THEN
        ALTER TABLE "predicted_papers" ADD CONSTRAINT "predicted_papers_topic_id_fkey" 
        FOREIGN KEY ("topic_id") REFERENCES "prediction_page_topics"("id") ON DELETE SET NULL ON UPDATE CASCADE;
        RAISE NOTICE 'Added predicted_papers_topic_id_fkey';
    END IF;

    -- multiple_choice_prediction_questions foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'multiple_choice_prediction_questions_category_id_fkey') THEN
        ALTER TABLE "multiple_choice_prediction_questions" ADD CONSTRAINT "multiple_choice_prediction_questions_category_id_fkey" 
        FOREIGN KEY ("category_id") REFERENCES "prediction_categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;
        RAISE NOTICE 'Added multiple_choice_prediction_questions_category_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'multiple_choice_prediction_questions_predicted_paper_id_fkey') THEN
        ALTER TABLE "multiple_choice_prediction_questions" ADD CONSTRAINT "multiple_choice_prediction_questions_predicted_paper_id_fkey" 
        FOREIGN KEY ("predicted_paper_id") REFERENCES "predicted_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added multiple_choice_prediction_questions_predicted_paper_id_fkey';
    END IF;

    -- one_part_prediction_questions foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'one_part_prediction_questions_category_id_fkey') THEN
        ALTER TABLE "one_part_prediction_questions" ADD CONSTRAINT "one_part_prediction_questions_category_id_fkey" 
        FOREIGN KEY ("category_id") REFERENCES "prediction_categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;
        RAISE NOTICE 'Added one_part_prediction_questions_category_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'one_part_prediction_questions_predicted_paper_id_fkey') THEN
        ALTER TABLE "one_part_prediction_questions" ADD CONSTRAINT "one_part_prediction_questions_predicted_paper_id_fkey" 
        FOREIGN KEY ("predicted_paper_id") REFERENCES "predicted_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added one_part_prediction_questions_predicted_paper_id_fkey';
    END IF;

    -- multiple_part_prediction_questions foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'multiple_part_prediction_questions_category_id_fkey') THEN
        ALTER TABLE "multiple_part_prediction_questions" ADD CONSTRAINT "multiple_part_prediction_questions_category_id_fkey" 
        FOREIGN KEY ("category_id") REFERENCES "prediction_categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;
        RAISE NOTICE 'Added multiple_part_prediction_questions_category_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'multiple_part_prediction_questions_predicted_paper_id_fkey') THEN
        ALTER TABLE "multiple_part_prediction_questions" ADD CONSTRAINT "multiple_part_prediction_questions_predicted_paper_id_fkey" 
        FOREIGN KEY ("predicted_paper_id") REFERENCES "predicted_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added multiple_part_prediction_questions_predicted_paper_id_fkey';
    END IF;

    -- multiple_part_prediction_question_descriptions foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'multiple_part_prediction_question_descriptions_predicted_p_fkey') THEN
        ALTER TABLE "multiple_part_prediction_question_descriptions" ADD CONSTRAINT "multiple_part_prediction_question_descriptions_predicted_p_fkey" 
        FOREIGN KEY ("predicted_paper_id") REFERENCES "multiple_part_prediction_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added multiple_part_prediction_question_descriptions_predicted_p_fkey';
    END IF;

    -- multiple_part_prediction_question_parts foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'multiple_part_prediction_question_parts_predicted_paper_id_fkey') THEN
        ALTER TABLE "multiple_part_prediction_question_parts" ADD CONSTRAINT "multiple_part_prediction_question_parts_predicted_paper_id_fkey" 
        FOREIGN KEY ("predicted_paper_id") REFERENCES "multiple_part_prediction_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added multiple_part_prediction_question_parts_predicted_paper_id_fkey';
    END IF;

    -- answered_predicted_papers foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'answered_predicted_papers_multiple_choice_question_id_fkey') THEN
        ALTER TABLE "answered_predicted_papers" ADD CONSTRAINT "answered_predicted_papers_multiple_choice_question_id_fkey" 
        FOREIGN KEY ("multiple_choice_question_id") REFERENCES "multiple_choice_prediction_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added answered_predicted_papers_multiple_choice_question_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'answered_predicted_papers_multiple_part_question_id_fkey') THEN
        ALTER TABLE "answered_predicted_papers" ADD CONSTRAINT "answered_predicted_papers_multiple_part_question_id_fkey" 
        FOREIGN KEY ("multiple_part_question_id") REFERENCES "multiple_part_prediction_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added answered_predicted_papers_multiple_part_question_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'answered_predicted_papers_one_part_question_id_fkey') THEN
        ALTER TABLE "answered_predicted_papers" ADD CONSTRAINT "answered_predicted_papers_one_part_question_id_fkey" 
        FOREIGN KEY ("one_part_question_id") REFERENCES "one_part_prediction_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added answered_predicted_papers_one_part_question_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'answered_predicted_papers_user_id_fkey') THEN
        ALTER TABLE "answered_predicted_papers" ADD CONSTRAINT "answered_predicted_papers_user_id_fkey" 
        FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added answered_predicted_papers_user_id_fkey';
    END IF;

    -- users_to_prediction_pages foreign keys
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_to_prediction_pages_last_watched_predicted_paper_id_fkey') THEN
        ALTER TABLE "users_to_prediction_pages" ADD CONSTRAINT "users_to_prediction_pages_last_watched_predicted_paper_id_fkey" 
        FOREIGN KEY ("last_watched_predicted_paper_id") REFERENCES "predicted_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added users_to_prediction_pages_last_watched_predicted_paper_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_to_prediction_pages_prediction_page_id_fkey') THEN
        ALTER TABLE "users_to_prediction_pages" ADD CONSTRAINT "users_to_prediction_pages_prediction_page_id_fkey" 
        FOREIGN KEY ("prediction_page_id") REFERENCES "prediction_pages"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added users_to_prediction_pages_prediction_page_id_fkey';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_to_prediction_pages_user_id_fkey') THEN
        ALTER TABLE "users_to_prediction_pages" ADD CONSTRAINT "users_to_prediction_pages_user_id_fkey" 
        FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        RAISE NOTICE 'Added users_to_prediction_pages_user_id_fkey';
    END IF;
END $$;

-- Step 3: Verify all tables were created
SELECT 
    table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%prediction%' OR table_name LIKE '%predicted%')
ORDER BY table_name;

-- Step 4: Verify show_predicted_papers column
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'exams' AND column_name = 'show_predicted_papers';

COMMIT;

-- INSTRUCTIONS:
-- 1. Go to AWS RDS Console
-- 2. Select your production database
-- 3. Click "Query Editor" or connect via psql
-- 4. Copy and paste this entire SQL file
-- 5. Execute it
-- 6. You should see NOTICE messages for each table/constraint created
-- 7. The verification queries at the end will confirm success
-- 8. After running this, refresh your CMS and the 500 errors should be gone!

