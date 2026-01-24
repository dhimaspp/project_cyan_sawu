-- =====================================================
-- Project Cyan: Sawu Seagrass dMRV Database Schema
-- =====================================================
-- This migration creates the complete database structure
-- for the Digital Monitoring, Reporting, and Verification system
-- =====================================================

-- =====================================================
-- 1. PROFILES TABLE (User Data)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  full_name TEXT,
  email TEXT,
  role TEXT DEFAULT 'verifier' CHECK (role IN ('verifier', 'admin')),
  wallet_address TEXT UNIQUE,
  reputation_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Profiles are viewable by everyone (transparency)"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Index for faster wallet lookups
CREATE INDEX IF NOT EXISTS idx_profiles_wallet_address 
  ON public.profiles(wallet_address);

-- Index for role-based queries
CREATE INDEX IF NOT EXISTS idx_profiles_role 
  ON public.profiles(role);

-- =====================================================
-- 2. CAMPAIGNS TABLE (Project Locations)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.campaigns (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  target_polygon JSONB, -- GeoJSON coordinates for the survey area
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused')),
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;

-- RLS Policies for campaigns
CREATE POLICY "Campaigns are viewable by everyone"
  ON public.campaigns FOR SELECT
  USING (true);

CREATE POLICY "Only admins can insert campaigns"
  ON public.campaigns FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Only admins can update campaigns"
  ON public.campaigns FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Index for status filtering
CREATE INDEX IF NOT EXISTS idx_campaigns_status 
  ON public.campaigns(status);

-- Index for GeoJSON queries
CREATE INDEX IF NOT EXISTS idx_campaigns_target_polygon 
  ON public.campaigns USING GIN(target_polygon);

-- =====================================================
-- 3. FIELD_REPORTS TABLE (Carbon Data/Evidence)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.field_reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  campaign_id UUID REFERENCES public.campaigns(id) ON DELETE SET NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- Core Data
  photo_url TEXT NOT NULL,
  gps_lat DOUBLE PRECISION NOT NULL,
  gps_long DOUBLE PRECISION NOT NULL,
  
  -- Verification Data
  captured_at TIMESTAMPTZ NOT NULL,
  device_info TEXT,
  
  -- Web3 Proof
  data_hash TEXT NOT NULL UNIQUE, -- SHA256 hash generated on client
  on_chain_tx TEXT, -- Blockchain transaction hash (filled by admin later)
  
  -- Status & Workflow
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
  rejection_reason TEXT,
  verified_by UUID REFERENCES public.profiles(id),
  verified_at TIMESTAMPTZ,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_coordinates CHECK (
    gps_lat >= -90 AND gps_lat <= 90 AND
    gps_long >= -180 AND gps_long <= 180
  )
);

-- Enable RLS
ALTER TABLE public.field_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies for field_reports
CREATE POLICY "Field reports are viewable by everyone (transparency)"
  ON public.field_reports FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert their own reports"
  ON public.field_reports FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins and verifiers can update report status"
  ON public.field_reports FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role IN ('admin', 'verifier')
    )
  );

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_field_reports_user_id 
  ON public.field_reports(user_id);

CREATE INDEX IF NOT EXISTS idx_field_reports_campaign_id 
  ON public.field_reports(campaign_id);

CREATE INDEX IF NOT EXISTS idx_field_reports_status 
  ON public.field_reports(status);

CREATE INDEX IF NOT EXISTS idx_field_reports_data_hash 
  ON public.field_reports(data_hash);

CREATE INDEX IF NOT EXISTS idx_field_reports_captured_at 
  ON public.field_reports(captured_at DESC);

-- Spatial index for GPS coordinates
CREATE INDEX IF NOT EXISTS idx_field_reports_gps 
  ON public.field_reports(gps_lat, gps_long);

-- =====================================================
-- 4. TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to profiles
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to campaigns
DROP TRIGGER IF EXISTS update_campaigns_updated_at ON public.campaigns;
CREATE TRIGGER update_campaigns_updated_at
  BEFORE UPDATE ON public.campaigns
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to field_reports
DROP TRIGGER IF EXISTS update_field_reports_updated_at ON public.field_reports;
CREATE TRIGGER update_field_reports_updated_at
  BEFORE UPDATE ON public.field_reports
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Function to update reputation score when report is verified/rejected
CREATE OR REPLACE FUNCTION update_reputation_score()
RETURNS TRIGGER AS $$
BEGIN
  -- Only update if status changed to verified or rejected
  IF OLD.status = 'pending' AND NEW.status IN ('verified', 'rejected') THEN
    IF NEW.status = 'verified' THEN
      -- Add 10 points for verified report
      UPDATE public.profiles
      SET reputation_score = reputation_score + 10
      WHERE id = NEW.user_id;
    ELSIF NEW.status = 'rejected' THEN
      -- Subtract 50 points for rejected report
      UPDATE public.profiles
      SET reputation_score = reputation_score - 50
      WHERE id = NEW.user_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update reputation
DROP TRIGGER IF EXISTS on_report_status_change ON public.field_reports;
CREATE TRIGGER on_report_status_change
  AFTER UPDATE ON public.field_reports
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION update_reputation_score();

-- =====================================================
-- 5. STORAGE BUCKETS
-- =====================================================

-- Create storage bucket for evidence photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('evidence-photos', 'evidence-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for evidence-photos bucket
CREATE POLICY "Authenticated users can upload evidence photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'evidence-photos' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Evidence photos are publicly readable (transparency)"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'evidence-photos');

CREATE POLICY "Users can update their own photos"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'evidence-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'evidence-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- =====================================================
-- 6. HELPER FUNCTIONS & VIEWS
-- =====================================================

-- View for report statistics
CREATE OR REPLACE VIEW public.report_statistics AS
SELECT
  user_id,
  COUNT(*) as total_reports,
  COUNT(*) FILTER (WHERE status = 'verified') as verified_count,
  COUNT(*) FILTER (WHERE status = 'rejected') as rejected_count,
  COUNT(*) FILTER (WHERE status = 'pending') as pending_count,
  AVG(EXTRACT(EPOCH FROM (verified_at - created_at))) FILTER (WHERE status = 'verified') as avg_verification_time_seconds
FROM public.field_reports
GROUP BY user_id;

-- View for campaign statistics
CREATE OR REPLACE VIEW public.campaign_statistics AS
SELECT
  c.id as campaign_id,
  c.title,
  c.status,
  COUNT(fr.id) as total_reports,
  COUNT(fr.id) FILTER (WHERE fr.status = 'verified') as verified_reports,
  COUNT(DISTINCT fr.user_id) as unique_contributors
FROM public.campaigns c
LEFT JOIN public.field_reports fr ON c.id = fr.campaign_id
GROUP BY c.id, c.title, c.status;

-- Function to get nearby reports
CREATE OR REPLACE FUNCTION get_nearby_reports(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_km DOUBLE PRECISION DEFAULT 1.0
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  photo_url TEXT,
  gps_lat DOUBLE PRECISION,
  gps_long DOUBLE PRECISION,
  distance_km DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    fr.id,
    fr.user_id,
    fr.photo_url,
    fr.gps_lat,
    fr.gps_long,
    (
      6371 * acos(
        cos(radians(lat)) * cos(radians(fr.gps_lat)) *
        cos(radians(fr.gps_long) - radians(lng)) +
        sin(radians(lat)) * sin(radians(fr.gps_lat))
      )
    ) as distance_km
  FROM public.field_reports fr
  WHERE (
    6371 * acos(
      cos(radians(lat)) * cos(radians(fr.gps_lat)) *
      cos(radians(fr.gps_long) - radians(lng)) +
      sin(radians(lat)) * sin(radians(fr.gps_lat))
    )
  ) <= radius_km
  ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. INITIAL DATA (Optional)
-- =====================================================

-- Insert a default campaign for testing
INSERT INTO public.campaigns (title, description, status)
VALUES (
  'Zona A - Laut Sawu',
  'Initial seagrass monitoring campaign in Sawu Sea',
  'active'
)
ON CONFLICT DO NOTHING;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- To apply this migration in Supabase:
-- 1. Go to SQL Editor in Supabase Dashboard
-- 2. Paste this entire SQL script
-- 3. Click "Run" to execute
-- 
-- Notes:
-- - All tables have RLS enabled for security
-- - Storage bucket policies ensure authenticated uploads
-- - Triggers automatically maintain updated_at timestamps
-- - Reputation system rewards verified reports and penalizes fraud
-- =====================================================
