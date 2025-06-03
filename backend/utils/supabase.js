const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

if (!process.env.SUPABASE_URL || !process.env.SUPABASE_ANON_KEY) {
  console.error('Missing Supabase environment variables:');
  console.error('SUPABASE_URL:', process.env.SUPABASE_URL ? 'Set' : 'Missing');
  console.error('SUPABASE_ANON_KEY:', process.env.SUPABASE_ANON_KEY ? 'Set' : 'Missing');
  throw new Error('Missing required Supabase environment variables');
}

// Create the base Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false
    }
  }
);



// Test the connection
const testConnection = async () => {
  try {
    console.log('Testing Supabase connection...');a
    const { data, error } = await supabase.from('screentime').select('*').limit(1);
    if (error) throw error;
    console.log('Supabase connection successful');
    return true;
  } catch (error) {
    console.error('Supabase connection test failed:', error.message);
    return false;
  }
};
const getSupabaseClient = (accessToken) => {
  if (!accessToken) {
    throw new Error('No access token provided');
  }

  const token = accessToken.startsWith('Bearer ') ? accessToken.slice(7) : accessToken;

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false
      }
    }
  );

  // Set the auth token for this client instance
  supabase.auth.setSession({
    access_token: token,
    refresh_token: ''
  });

  return supabase;
};



module.exports = {
    supabase,
    getSupabaseClient,
    testConnection
};
