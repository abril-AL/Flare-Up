const { getSupabaseClient } = require('../utils/supabase');
const { startOfWeek, endOfWeek, subWeeks } = require('date-fns');

const generateDrop = async (supabase, userId, weekStart, weekEnd) => {
  console.log('Debug - Generating drop for:', {
    userId,
    weekStart: weekStart.toISOString(),
    weekEnd: weekEnd.toISOString()
  });

  // Fetch this week's screentime entries
  const { data: entries, error } = await supabase
    .from('screentime')
    .select('*')
    .eq('user_id', userId)
    .gte('date', weekStart.toISOString())
    .lte('date', weekEnd.toISOString());

  if (error) {
    console.error('Error fetching screentime entries:', error);
    return null;
  }

  console.log('Debug - Found screentime entries:', entries);

  // Calculate total screen time
  const totalMinutes = entries.reduce((sum, entry) => sum + (entry.duration || 0), 0);
  
  // Calculate app frequency
  const appFrequency = {};
  entries.forEach(entry => {
    if (entry.category) {
      appFrequency[entry.category] = (appFrequency[entry.category] || 0) + 1;
    }
  });

  console.log('Debug - App frequency:', appFrequency);

  // Find apps with highest frequency
  const sortedApps = Object.entries(appFrequency)
    .sort((a, b) => b[1] - a[1]); // Sort by frequency, descending

  // Get the highest frequency
  const highestFrequency = sortedApps[0]?.[1] || 0;

  // Get all apps that share the highest frequency (handling ties)
  const mostUsedApps = sortedApps
    .filter(([_, freq]) => freq === highestFrequency)
    .map(([app]) => app)
    .join(', ');

  const dropData = {
    user_id: userId,
    week_start: weekStart.toISOString(),
    week_end: weekEnd.toISOString(),
    total_minutes: totalMinutes,
    average_daily_hours: +(totalMinutes / 7 / 60).toFixed(2),
    most_used_apps: mostUsedApps,
    usage_frequency: highestFrequency,
    created_at: new Date().toISOString()
  };

  console.log('Debug - Generated drop data:', dropData);
  return dropData;
};

const createDrop = async (req, res) => {
  try {
    const token = req.headers.token || req.headers.authorization;
    if (!token) return res.status(401).json({ error: 'No token provided' });

    const supabase = getSupabaseClient(token);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    
    if (userError || !user) {
      return res.status(401).json({ error: 'Invalid session' });
    }

    // Calculate week boundaries
    const today = new Date();
    const weekStart = startOfWeek(today, { weekStartsOn: 1 });
    const weekEnd = endOfWeek(today, { weekStartsOn: 1 });

    // Generate drop data
    const dropData = await generateDrop(supabase, user.id, weekStart, weekEnd);
    if (!dropData) {
      return res.status(500).json({ error: 'Failed to generate drop data' });
    }

    // Store drop in database
    const { data, error } = await supabase
      .from('drops')
      .upsert([dropData], { onConflict: ['user_id', 'week_start'] })
      .select()
      .single();

    if (error) {
      console.error('Drop creation error:', error);
      return res.status(500).json({ error: 'Failed to create drop' });
    }

    res.status(201).json(data);
  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ error: error.message });
  }
};


const getLatestDrop = async (req, res) => {
  try {
    // ✅ Parse and sanitize token
    const rawAuth = req.headers.token || req.headers.authorization;
    if (!rawAuth) return res.status(401).json({ error: 'No token provided' });

    const token = rawAuth.startsWith('Bearer ') ? rawAuth.slice(7) : rawAuth;
    console.log('Debug - Received token:', token.substring(0, 20) + '...');

    const supabase = getSupabaseClient(token);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);

    if (userError || !user) {
      console.log('Debug - Auth Error:', userError || 'No user returned');
      return res.status(401).json({ error: 'Invalid session' });
    }

    const userId = req.params.userId;
    if (user.id.toLowerCase() !== userId.toLowerCase()) {
      console.log('Debug - User ID mismatch:', { requestedId: userId, actualId: user.id });
      return res.status(403).json({ error: 'Unauthorized access' });
    }

    console.log('Debug - Authenticated user:', user.id);

    // ✅ Fetch latest drop
    const { data: latestDrop, error: dropError } = await supabase
      .from('drops')
      .select('*')
      .eq('user_id', userId.toLowerCase())
      .order('week_start', { ascending: false })
      .limit(1)
      .single();

    if (dropError && dropError.code !== 'PGRST116') {
      console.error('Error fetching drop:', dropError);
      return res.status(500).json({ error: 'Failed to fetch drop' });
    }

    if (!latestDrop) {
      console.log('Debug - No existing drop found, generating new one');
      const today = new Date();
      const weekStart = startOfWeek(today, { weekStartsOn: 1 });
      const weekEnd = endOfWeek(today, { weekStartsOn: 1 });

      const newDrop = await generateDrop(supabase, userId, weekStart, weekEnd);

      if (!newDrop) {
        const fallback = {
          date: today.toISOString().split('T')[0],
          total_minutes: 0,
          average_daily_hours: 0,
          weekly_change: null,
          most_used_apps: "",
          usage_frequency: 0,
          missing_this_week: true,
          missing_last_week: true
        };
        return res.json(fallback);
      }

      const { data: storedDrop, error: storeError } = await supabase
        .from('drops')
        .upsert([newDrop])
        .select()
        .single();

      if (storeError) {
        console.error('Error storing drop:', storeError);
        return res.status(500).json({ error: 'Failed to store drop' });
      }

      const response = {
        date: new Date().toISOString().split('T')[0],
        total_minutes: storedDrop.total_minutes,
        average_daily_hours: storedDrop.average_daily_hours,
        weekly_change: null,
        most_used_apps: storedDrop.most_used_apps,
        usage_frequency: storedDrop.usage_frequency,
        missing_this_week: storedDrop.total_minutes === 0,
        missing_last_week: true
      };
      return res.json(response);
    }

    // ✅ Compare with previous week
    const prevWeekStart = subWeeks(new Date(latestDrop.week_start), 1);
    const { data: prevDrop } = await supabase
      .from('drops')
      .select('total_minutes')
      .eq('user_id', userId)
      .eq('week_start', prevWeekStart.toISOString())
      .single();

    const weeklyChange = prevDrop && prevDrop.total_minutes > 0
      ? (latestDrop.total_minutes - prevDrop.total_minutes) / prevDrop.total_minutes
      : null;

    const response = {
      date: new Date(latestDrop.week_start).toISOString().split('T')[0],
      total_minutes: latestDrop.total_minutes,
      average_daily_hours: latestDrop.average_daily_hours,
      weekly_change: weeklyChange,
      most_used_apps: latestDrop.most_used_apps,
      usage_frequency: latestDrop.usage_frequency,
      missing_this_week: latestDrop.total_minutes === 0,
      missing_last_week: !prevDrop || prevDrop.total_minutes === 0
    };

    return res.json(response);
  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = { getLatestDrop };


const createDropForWeek = async (req, res) => {
  try {
    const token = req.headers.token || req.headers.authorization;
    if (!token) return res.status(401).json({ error: 'No token provided' });

    const supabase = getSupabaseClient(token);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    
    if (userError || !user) {
      return res.status(401).json({ error: 'Invalid session' });
    }

    // Use the specified week
    const weekStart = new Date('2024-05-23');
    const weekEnd = new Date('2024-05-29');

    console.log('Creating drop for week:', {
      userId: user.id,
      weekStart: weekStart.toISOString(),
      weekEnd: weekEnd.toISOString()
    });

    // Generate drop data for the specified week
    const dropData = await generateDrop(supabase, user.id, weekStart, weekEnd);
    if (!dropData) {
      return res.status(500).json({ error: 'Failed to generate drop data' });
    }

    // Store drop in database
    const { data, error } = await supabase
      .from('drops')
      .upsert([dropData], { onConflict: ['user_id', 'week_start'] })
      .select()
      .single();

    if (error) {
      console.error('Drop creation error:', error);
      return res.status(500).json({ error: 'Failed to create drop' });
    }

    res.status(201).json(data);
  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  createDrop,
  getLatestDrop,
  createDropForWeek
}; 