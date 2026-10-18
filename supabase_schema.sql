-- ====================================================================
-- STUDIO SCREEN AI - SUPABASE DATABASE & STORAGE SCHEMA
-- Run this script in your Supabase SQL Editor (https://supabase.com/dashboard)
-- ====================================================================

-- 1. Create Recordings Table
CREATE TABLE IF NOT EXISTS public.recordings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Screen Recording',
    description TEXT,
    duration_seconds INTEGER NOT NULL DEFAULT 0,
    file_size_bytes BIGINT NOT NULL DEFAULT 0,
    storage_path TEXT NOT NULL,
    public_url TEXT NOT NULL,
    thumbnail_url TEXT,
    aspect_ratio TEXT DEFAULT '16:9',
    has_ai_captions BOOLEAN DEFAULT FALSE,
    zoom_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.recordings ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Allow anyone to view public recordings via share link
CREATE POLICY "Public recordings are viewable by everyone" 
ON public.recordings FOR SELECT 
USING (is_public = true OR (auth.uid() = user_id));

-- Allow authenticated users to insert their own recordings
CREATE POLICY "Users can insert their own recordings" 
ON public.recordings FOR INSERT 
WITH CHECK (auth.uid() = user_id OR auth.role() = 'anon');

-- Allow users to update their own recordings
CREATE POLICY "Users can update their own recordings" 
ON public.recordings FOR UPDATE 
USING (auth.uid() = user_id);

-- Allow users to delete their own recordings
CREATE POLICY "Users can delete their own recordings" 
ON public.recordings FOR DELETE 
USING (auth.uid() = user_id);

-- 4. Create Public Storage Bucket for Videos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'recordings', 
    'recordings', 
    true, 
    524288000, -- 500MB max video size
    ARRAY['video/mp4', 'video/webm', 'image/png', 'image/jpeg', 'application/json']
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 5. Storage Policies for Recordings Bucket
-- Allow public read access to uploaded recordings
CREATE POLICY "Public Access for Recordings Bucket" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'recordings');

-- Allow authenticated and anon uploads to the bucket
CREATE POLICY "Allow Uploads to Recordings Bucket" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'recordings');

-- Allow users to delete their own storage objects
CREATE POLICY "Allow Delete in Recordings Bucket" 
ON storage.objects FOR DELETE 
USING (bucket_id = 'recordings' AND (auth.uid() = owner OR auth.role() = 'anon'));

-- Done! Your Supabase database & storage are now fully prepared for StudioScreen AI.
