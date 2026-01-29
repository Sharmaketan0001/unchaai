-- =====================================================
-- UnchaAi Mentorship Platform Database Schema
-- =====================================================

-- 1. TYPES (ENUMs)
-- =====================================================

DROP TYPE IF EXISTS public.user_role CASCADE;
CREATE TYPE public.user_role AS ENUM ('user', 'mentor', 'admin');

DROP TYPE IF EXISTS public.session_status CASCADE;
CREATE TYPE public.session_status AS ENUM ('upcoming', 'completed', 'cancelled');

DROP TYPE IF EXISTS public.booking_status CASCADE;
CREATE TYPE public.booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');

DROP TYPE IF EXISTS public.mentor_status CASCADE;
CREATE TYPE public.mentor_status AS ENUM ('active', 'inactive', 'pending_approval');

DROP TYPE IF EXISTS public.expertise_level CASCADE;
CREATE TYPE public.expertise_level AS ENUM ('beginner', 'intermediate', 'expert');

-- 2. CORE TABLES
-- =====================================================

-- User Profiles (extends auth.users)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role public.user_role DEFAULT 'user'::public.user_role,
    bio TEXT,
    location TEXT,
    timezone TEXT DEFAULT 'UTC',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Mentors (extended profile for mentors)
CREATE TABLE IF NOT EXISTS public.mentors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    company TEXT,
    years_of_experience INTEGER DEFAULT 0,
    hourly_rate DECIMAL(10, 2) NOT NULL,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    expertise_level public.expertise_level DEFAULT 'intermediate'::public.expertise_level,
    status public.mentor_status DEFAULT 'pending_approval'::public.mentor_status,
    is_featured BOOLEAN DEFAULT false,
    video_intro_url TEXT,
    linkedin_url TEXT,
    github_url TEXT,
    portfolio_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Categories (for mentorship areas)
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Mentor Categories (junction table)
CREATE TABLE IF NOT EXISTS public.mentor_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(mentor_id, category_id)
);

-- Skills
CREATE TABLE IF NOT EXISTS public.skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Mentor Skills (junction table)
CREATE TABLE IF NOT EXISTS public.mentor_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES public.skills(id) ON DELETE CASCADE,
    proficiency_level public.expertise_level DEFAULT 'intermediate'::public.expertise_level,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(mentor_id, skill_id)
);

-- Courses (offered by mentors)
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    max_participants INTEGER DEFAULT 1,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    thumbnail_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Availability Slots (mentor availability)
CREATE TABLE IF NOT EXISTS public.availability_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_recurring BOOLEAN DEFAULT true,
    specific_date DATE,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_time > start_time)
);

-- Sessions (scheduled mentorship sessions)
CREATE TABLE IF NOT EXISTS public.sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER NOT NULL,
    status public.session_status DEFAULT 'upcoming'::public.session_status,
    meeting_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Bookings (user bookings for sessions)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
    status public.booking_status DEFAULT 'pending'::public.booking_status,
    amount_paid DECIMAL(10, 2) NOT NULL,
    booking_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    confirmation_code TEXT UNIQUE,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Reviews (user reviews for mentors)
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, booking_id)
);

-- Experience (mentor work experience)
CREATE TABLE IF NOT EXISTS public.experiences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    company TEXT NOT NULL,
    position TEXT NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_mentors_user_id ON public.mentors(user_id);
CREATE INDEX IF NOT EXISTS idx_mentors_status ON public.mentors(status);
CREATE INDEX IF NOT EXISTS idx_mentors_rating ON public.mentors(rating DESC);
CREATE INDEX IF NOT EXISTS idx_mentors_is_featured ON public.mentors(is_featured);
CREATE INDEX IF NOT EXISTS idx_sessions_mentor_id ON public.sessions(mentor_id);
CREATE INDEX IF NOT EXISTS idx_sessions_scheduled_at ON public.sessions(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_sessions_status ON public.sessions(status);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_session_id ON public.bookings(session_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_reviews_mentor_id ON public.reviews(mentor_id);
CREATE INDEX IF NOT EXISTS idx_courses_mentor_id ON public.courses(mentor_id);
CREATE INDEX IF NOT EXISTS idx_availability_slots_mentor_id ON public.availability_slots(mentor_id);

-- 4. FUNCTIONS
-- =====================================================

-- Trigger function to create user profile automatically
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, phone, avatar_url, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'phone', NULL),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', NULL),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'user'::public.user_role)
    );
    RETURN NEW;
END;
$$;

-- Function to update mentor rating
CREATE OR REPLACE FUNCTION public.update_mentor_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.mentors
    SET 
        rating = (
            SELECT COALESCE(AVG(rating), 0.0)
            FROM public.reviews
            WHERE mentor_id = NEW.mentor_id
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM public.reviews
            WHERE mentor_id = NEW.mentor_id
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.mentor_id;
    RETURN NEW;
END;
$$;

-- Function to update session count
CREATE OR REPLACE FUNCTION public.update_mentor_session_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.status = 'completed'::public.booking_status THEN
        UPDATE public.mentors
        SET 
            total_sessions = total_sessions + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.mentor_id;
    END IF;
    RETURN NEW;
END;
$$;

-- Function to generate confirmation code
CREATE OR REPLACE FUNCTION public.generate_confirmation_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.confirmation_code := 'BK-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8));
    RETURN NEW;
END;
$$;

-- 5. ENABLE RLS
-- =====================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentor_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentor_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.availability_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.experiences ENABLE ROW LEVEL SECURITY;

-- 6. RLS POLICIES
-- =====================================================

-- User Profiles Policies
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "public_read_user_profiles" ON public.user_profiles;
CREATE POLICY "public_read_user_profiles"
ON public.user_profiles
FOR SELECT
TO public
USING (true);

-- Mentors Policies
DROP POLICY IF EXISTS "public_read_active_mentors" ON public.mentors;
CREATE POLICY "public_read_active_mentors"
ON public.mentors
FOR SELECT
TO public
USING (status = 'active'::public.mentor_status);

DROP POLICY IF EXISTS "mentors_manage_own_mentors" ON public.mentors;
CREATE POLICY "mentors_manage_own_mentors"
ON public.mentors
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Categories Policies
DROP POLICY IF EXISTS "public_read_categories" ON public.categories;
CREATE POLICY "public_read_categories"
ON public.categories
FOR SELECT
TO public
USING (is_active = true);

-- Mentor Categories Policies
DROP POLICY IF EXISTS "public_read_mentor_categories" ON public.mentor_categories;
CREATE POLICY "public_read_mentor_categories"
ON public.mentor_categories
FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "mentors_manage_own_mentor_categories" ON public.mentor_categories;
CREATE POLICY "mentors_manage_own_mentor_categories"
ON public.mentor_categories
FOR ALL
TO authenticated
USING (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
);

-- Skills Policies
DROP POLICY IF EXISTS "public_read_skills" ON public.skills;
CREATE POLICY "public_read_skills"
ON public.skills
FOR SELECT
TO public
USING (true);

-- Mentor Skills Policies
DROP POLICY IF EXISTS "public_read_mentor_skills" ON public.mentor_skills;
CREATE POLICY "public_read_mentor_skills"
ON public.mentor_skills
FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "mentors_manage_own_mentor_skills" ON public.mentor_skills;
CREATE POLICY "mentors_manage_own_mentor_skills"
ON public.mentor_skills
FOR ALL
TO authenticated
USING (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
);

-- Courses Policies
DROP POLICY IF EXISTS "public_read_active_courses" ON public.courses;
CREATE POLICY "public_read_active_courses"
ON public.courses
FOR SELECT
TO public
USING (is_active = true);

DROP POLICY IF EXISTS "mentors_manage_own_courses" ON public.courses;
CREATE POLICY "mentors_manage_own_courses"
ON public.courses
FOR ALL
TO authenticated
USING (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
);

-- Availability Slots Policies
DROP POLICY IF EXISTS "public_read_availability_slots" ON public.availability_slots;
CREATE POLICY "public_read_availability_slots"
ON public.availability_slots
FOR SELECT
TO public
USING (is_available = true);

DROP POLICY IF EXISTS "mentors_manage_own_availability_slots" ON public.availability_slots;
CREATE POLICY "mentors_manage_own_availability_slots"
ON public.availability_slots
FOR ALL
TO authenticated
USING (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
);

-- Sessions Policies
DROP POLICY IF EXISTS "public_read_sessions" ON public.sessions;
CREATE POLICY "public_read_sessions"
ON public.sessions
FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "mentors_manage_own_sessions" ON public.sessions;
CREATE POLICY "mentors_manage_own_sessions"
ON public.sessions
FOR ALL
TO authenticated
USING (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
);

-- Bookings Policies
DROP POLICY IF EXISTS "users_manage_own_bookings" ON public.bookings;
CREATE POLICY "users_manage_own_bookings"
ON public.bookings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "mentors_view_their_bookings" ON public.bookings;
CREATE POLICY "mentors_view_their_bookings"
ON public.bookings
FOR SELECT
TO authenticated
USING (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
);

-- Reviews Policies
DROP POLICY IF EXISTS "public_read_reviews" ON public.reviews;
CREATE POLICY "public_read_reviews"
ON public.reviews
FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "users_manage_own_reviews" ON public.reviews;
CREATE POLICY "users_manage_own_reviews"
ON public.reviews
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Experiences Policies
DROP POLICY IF EXISTS "public_read_experiences" ON public.experiences;
CREATE POLICY "public_read_experiences"
ON public.experiences
FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "mentors_manage_own_experiences" ON public.experiences;
CREATE POLICY "mentors_manage_own_experiences"
ON public.experiences
FOR ALL
TO authenticated
USING (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    mentor_id IN (
        SELECT id FROM public.mentors WHERE user_id = auth.uid()
    )
);

-- 7. TRIGGERS
-- =====================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS on_review_created ON public.reviews;
CREATE TRIGGER on_review_created
    AFTER INSERT ON public.reviews
    FOR EACH ROW
    EXECUTE FUNCTION public.update_mentor_rating();

DROP TRIGGER IF EXISTS on_review_updated ON public.reviews;
CREATE TRIGGER on_review_updated
    AFTER UPDATE ON public.reviews
    FOR EACH ROW
    EXECUTE FUNCTION public.update_mentor_rating();

DROP TRIGGER IF EXISTS on_booking_completed ON public.bookings;
CREATE TRIGGER on_booking_completed
    AFTER UPDATE ON public.bookings
    FOR EACH ROW
    WHEN (NEW.status = 'completed'::public.booking_status)
    EXECUTE FUNCTION public.update_mentor_session_count();

DROP TRIGGER IF EXISTS generate_booking_confirmation ON public.bookings;
CREATE TRIGGER generate_booking_confirmation
    BEFORE INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.generate_confirmation_code();

-- 8. MOCK DATA
-- =====================================================

DO $$
DECLARE
    user1_uuid UUID := gen_random_uuid();
    user2_uuid UUID := gen_random_uuid();
    user3_uuid UUID := gen_random_uuid();
    mentor1_uuid UUID;
    mentor2_uuid UUID;
    mentor3_uuid UUID;
    category1_uuid UUID := gen_random_uuid();
    category2_uuid UUID := gen_random_uuid();
    category3_uuid UUID := gen_random_uuid();
    skill1_uuid UUID := gen_random_uuid();
    skill2_uuid UUID := gen_random_uuid();
    skill3_uuid UUID := gen_random_uuid();
    course1_uuid UUID := gen_random_uuid();
    course2_uuid UUID := gen_random_uuid();
    session1_uuid UUID := gen_random_uuid();
    session2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users (trigger creates user_profiles automatically)
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (user1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'mentor1@unchaai.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Sarah Johnson', 'role', 'mentor', 'phone', '+1234567890'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'mentor2@unchaai.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Michael Chen', 'role', 'mentor', 'phone', '+1234567891'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user3_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@unchaai.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'John Doe', 'role', 'user', 'phone', '+1234567892'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null)
    ON CONFLICT (id) DO NOTHING;

    -- Create categories
    INSERT INTO public.categories (id, name, description, icon_url, display_order) VALUES
        (category1_uuid, 'Software Development', 'Learn programming and software engineering', 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400', 1),
        (category2_uuid, 'Data Science', 'Master data analysis and machine learning', 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400', 2),
        (category3_uuid, 'Product Management', 'Build and launch successful products', 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400', 3)
    ON CONFLICT (id) DO NOTHING;

    -- Create skills
    INSERT INTO public.skills (id, name, category_id) VALUES
        (skill1_uuid, 'Flutter', category1_uuid),
        (skill2_uuid, 'Python', category2_uuid),
        (skill3_uuid, 'Product Strategy', category3_uuid)
    ON CONFLICT (id) DO NOTHING;

    -- Create mentors
    INSERT INTO public.mentors (id, user_id, title, company, years_of_experience, hourly_rate, rating, total_reviews, expertise_level, status, is_featured)
    VALUES
        (gen_random_uuid(), user1_uuid, 'Senior Flutter Developer', 'Google', 8, 150.00, 4.8, 24, 'expert'::public.expertise_level, 'active'::public.mentor_status, true),
        (gen_random_uuid(), user2_uuid, 'Data Science Lead', 'Meta', 10, 180.00, 4.9, 32, 'expert'::public.expertise_level, 'active'::public.mentor_status, true)
    ON CONFLICT (user_id) DO NOTHING
    RETURNING id INTO mentor1_uuid;

    -- Get mentor IDs
    SELECT id INTO mentor1_uuid FROM public.mentors WHERE user_id = user1_uuid LIMIT 1;
    SELECT id INTO mentor2_uuid FROM public.mentors WHERE user_id = user2_uuid LIMIT 1;

    IF mentor1_uuid IS NOT NULL AND mentor2_uuid IS NOT NULL THEN
        -- Create mentor categories
        INSERT INTO public.mentor_categories (mentor_id, category_id) VALUES
            (mentor1_uuid, category1_uuid),
            (mentor2_uuid, category2_uuid)
        ON CONFLICT (mentor_id, category_id) DO NOTHING;

        -- Create mentor skills
        INSERT INTO public.mentor_skills (mentor_id, skill_id, proficiency_level) VALUES
            (mentor1_uuid, skill1_uuid, 'expert'::public.expertise_level),
            (mentor2_uuid, skill2_uuid, 'expert'::public.expertise_level)
        ON CONFLICT (mentor_id, skill_id) DO NOTHING;

        -- Create courses
        INSERT INTO public.courses (id, mentor_id, title, description, duration_minutes, price, category_id, is_active) VALUES
            (course1_uuid, mentor1_uuid, 'Flutter Masterclass', 'Learn Flutter from basics to advanced', 60, 100.00, category1_uuid, true),
            (course2_uuid, mentor2_uuid, 'Data Science Fundamentals', 'Master data analysis with Python', 90, 120.00, category2_uuid, true)
        ON CONFLICT (id) DO NOTHING;

        -- Create availability slots
        INSERT INTO public.availability_slots (mentor_id, day_of_week, start_time, end_time, is_recurring) VALUES
            (mentor1_uuid, 1, '09:00:00', '17:00:00', true),
            (mentor1_uuid, 3, '09:00:00', '17:00:00', true),
            (mentor2_uuid, 2, '10:00:00', '18:00:00', true),
            (mentor2_uuid, 4, '10:00:00', '18:00:00', true)
        ON CONFLICT (id) DO NOTHING;

        -- Create sessions
        INSERT INTO public.sessions (id, mentor_id, course_id, title, description, scheduled_at, duration_minutes, status, meeting_url) VALUES
            (session1_uuid, mentor1_uuid, course1_uuid, 'Flutter Basics Session', 'Introduction to Flutter widgets', now() + interval '2 days', 60, 'upcoming'::public.session_status, 'https://meet.google.com/abc-defg-hij'),
            (session2_uuid, mentor2_uuid, course2_uuid, 'Python for Data Science', 'Learn pandas and numpy', now() + interval '3 days', 90, 'upcoming'::public.session_status, 'https://meet.google.com/xyz-uvwx-rst')
        ON CONFLICT (id) DO NOTHING;

        -- Create bookings
        INSERT INTO public.bookings (user_id, session_id, mentor_id, course_id, status, amount_paid) VALUES
            (user3_uuid, session1_uuid, mentor1_uuid, course1_uuid, 'confirmed'::public.booking_status, 100.00),
            (user3_uuid, session2_uuid, mentor2_uuid, course2_uuid, 'confirmed'::public.booking_status, 120.00)
        ON CONFLICT (id) DO NOTHING;

        -- Create reviews
        INSERT INTO public.reviews (user_id, mentor_id, rating, comment, is_verified) VALUES
            (user3_uuid, mentor1_uuid, 5, 'Excellent mentor! Very knowledgeable and patient.', true),
            (user3_uuid, mentor2_uuid, 5, 'Great session! Learned a lot about data science.', true)
        ON CONFLICT (user_id, booking_id) DO NOTHING;

        -- Create experiences
        INSERT INTO public.experiences (mentor_id, company, position, description, start_date, end_date, is_current) VALUES
            (mentor1_uuid, 'Google', 'Senior Flutter Developer', 'Leading Flutter development team', '2020-01-01', NULL, true),
            (mentor2_uuid, 'Meta', 'Data Science Lead', 'Managing data science projects', '2018-06-01', NULL, true)
        ON CONFLICT (id) DO NOTHING;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data insertion failed: %', SQLERRM;
END $$;