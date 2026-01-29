-- =====================================================
-- Storage Buckets for Profile Pictures and Documents
-- =====================================================

-- Create private bucket for user profile pictures
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-pictures',
    'profile-pictures',
    false,  -- PRIVATE
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO NOTHING;

-- Create private bucket for mentor documents
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'mentor-documents',
    'mentor-documents',
    false,  -- PRIVATE
    10485760, -- 10MB
    ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- RLS: Users manage their own profile pictures
DROP POLICY IF EXISTS "users_manage_own_profile_pictures" ON storage.objects;
CREATE POLICY "users_manage_own_profile_pictures"
ON storage.objects
FOR ALL
TO authenticated
USING (bucket_id = 'profile-pictures' AND owner = auth.uid())
WITH CHECK (bucket_id = 'profile-pictures' AND owner = auth.uid());

-- RLS: Public can view profile pictures
DROP POLICY IF EXISTS "public_view_profile_pictures" ON storage.objects;
CREATE POLICY "public_view_profile_pictures"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profile-pictures');

-- RLS: Mentors manage their own documents
DROP POLICY IF EXISTS "mentors_manage_own_documents" ON storage.objects;
CREATE POLICY "mentors_manage_own_documents"
ON storage.objects
FOR ALL
TO authenticated
USING (bucket_id = 'mentor-documents' AND owner = auth.uid())
WITH CHECK (bucket_id = 'mentor-documents' AND owner = auth.uid());