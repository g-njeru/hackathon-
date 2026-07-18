# Supabase Quickstart

Set up Supabase for auth, database, storage, and realtime in minutes.

---

## What is Supabase?

A managed platform that gives you:
- **PostgreSQL database** with a web dashboard
- **Auth** (email, OAuth, magic links, phone)
- **Realtime** subscriptions (listen for DB changes)
- **Storage** (file uploads with access control)
- **Edge Functions** (serverless Python/TypeScript)

Think of it as Firebase, but open-source and built on PostgreSQL.

---

## Setup

### 1. Create project

1. Go to [supabase.com](https://supabase.com) and sign up
2. Click "New Project"
3. Choose a name, set a database password
4. Pick a region close to your users
5. Wait ~2 minutes for provisioning

### 2. Get your keys

In the project dashboard → Settings → API:

```
Project URL:  https://xxxx.supabase.co
Anon Key:     eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Service Key:  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Never expose the Service Key in frontend code.**

### 3. Add to your `.env`

```bash
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIs...  # Backend only
```

---

## Authentication

### Email/Password (React)

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securepassword'
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'securepassword'
})

// Sign out
await supabase.auth.signOut()

// Get current user
const { data: { user } } = await supabase.auth.getUser()
```

### OAuth (Google)

```javascript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google'
})
```

### Magic Link

```javascript
const { data, error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com'
})
```

### FastAPI (Backend)

```python
from supabase import create_client

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)

# Verify JWT from request header
from fastapi import Header, HTTPException

async def get_current_user(authorization: str = Header(...)):
    token = authorization.replace("Bearer ", "")
    user = supabase.auth.get_user(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user
```

---

## Database

### Create table via Dashboard

1. Go to Table Editor
2. Click "New Table"
3. Add columns with types
4. Enable Row Level Security (RLS)

### Row Level Security (RLS)

RLS ensures users can only access their own data.

```sql
-- Enable RLS
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Users can only read their own documents
CREATE POLICY "Users read own docs" ON documents
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own documents
CREATE POLICY "Users insert own docs" ON documents
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own documents
CREATE POLICY "Users update own docs" ON documents
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own documents
CREATE POLICY "Users delete own docs" ON documents
  FOR DELETE USING (auth.uid() = user_id);
```

### Query from frontend

```javascript
// Insert
const { data, error } = await supabase
  .from('documents')
  .insert({ title: 'My Doc', content: 'Hello', user_id: user.id })

// Select
const { data, error } = await supabase
  .from('documents')
  .select('*')
  .eq('user_id', user.id)

// Update
const { data, error } = await supabase
  .from('documents')
  .update({ title: 'Updated' })
  .eq('id', docId)

// Delete
const { data, error } = await supabase
  .from('documents')
  .delete()
  .eq('id', docId)
```

---

## Realtime

### Subscribe to table changes (React)

```javascript
const channel = supabase
  .channel('documents')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'documents' }, (payload) => {
    console.log('Change:', payload)
    // payload.eventType: 'INSERT', 'UPDATE', or 'DELETE'
    // payload.new: the new row
    // payload.old: the old row
  })
  .subscribe()

// Cleanup
supabase.removeChannel(channel)
```

---

## Storage

### Upload file

```javascript
const { data, error } = await supabase.storage
  .from('uploads')
  .upload('document.pdf', file)
```

### Get public URL

```javascript
const { data } = supabase.storage
  .from('uploads')
  .getPublicUrl('document.pdf')
```

### Storage RLS

```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users upload" ON storage.objects
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow public read
CREATE POLICY "Public read" ON storage.objects
  FOR SELECT USING (true);
```

---

## When to Use Supabase

| Use Case | Why Supabase |
|---|---|
| User auth | Built-in, handles OAuth/magic links/email |
| File storage | S3-compatible, with access control |
| Realtime features | Live updates without WebSockets setup |
| Quick prototyping | No backend auth code needed |
| Row-level security | Declarative access control in SQL |

---

## Docker Compose Alternative

If you want to self-host Supabase locally:

```bash
git clone https://github.com/supabase/supabase
cd supabase/docker
cp .env.example .env
docker-compose up -d
```

This runs the full Supabase stack locally (database, auth, storage, realtime, dashboard).
