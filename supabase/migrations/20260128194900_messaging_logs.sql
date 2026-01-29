-- =====================================================
-- Messaging Logs Table for Twilio WhatsApp Integration
-- =====================================================

-- Message Type ENUM
DROP TYPE IF EXISTS public.message_type CASCADE;
CREATE TYPE public.message_type AS ENUM ('booking_confirmation', 'session_reminder_24h', 'session_reminder_1h', 'follow_up');

-- Message Status ENUM
DROP TYPE IF EXISTS public.message_status CASCADE;
CREATE TYPE public.message_status AS ENUM ('pending', 'sent', 'delivered', 'failed', 'read');

-- Messaging Logs Table
CREATE TABLE IF NOT EXISTS public.messaging_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.sessions(id) ON DELETE CASCADE,
    message_type public.message_type NOT NULL,
    phone_number TEXT NOT NULL,
    message_content TEXT NOT NULL,
    twilio_message_sid TEXT,
    status public.message_status DEFAULT 'pending'::public.message_status,
    error_message TEXT,
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_messaging_logs_user_id ON public.messaging_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_messaging_logs_booking_id ON public.messaging_logs(booking_id);
CREATE INDEX IF NOT EXISTS idx_messaging_logs_session_id ON public.messaging_logs(session_id);
CREATE INDEX IF NOT EXISTS idx_messaging_logs_status ON public.messaging_logs(status);
CREATE INDEX IF NOT EXISTS idx_messaging_logs_message_type ON public.messaging_logs(message_type);
CREATE INDEX IF NOT EXISTS idx_messaging_logs_created_at ON public.messaging_logs(created_at);

-- Enable RLS
ALTER TABLE public.messaging_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "users_view_own_messaging_logs" ON public.messaging_logs;
CREATE POLICY "users_view_own_messaging_logs"
ON public.messaging_logs
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

DROP POLICY IF EXISTS "system_manage_messaging_logs" ON public.messaging_logs;
CREATE POLICY "system_manage_messaging_logs"
ON public.messaging_logs
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_messaging_logs_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Trigger for updated_at
DROP TRIGGER IF EXISTS messaging_logs_updated_at_trigger ON public.messaging_logs;
CREATE TRIGGER messaging_logs_updated_at_trigger
BEFORE UPDATE ON public.messaging_logs
FOR EACH ROW
EXECUTE FUNCTION public.update_messaging_logs_updated_at();