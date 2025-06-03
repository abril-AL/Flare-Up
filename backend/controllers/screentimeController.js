const { getSupabaseClient } = require('../utils/supabase');

const addScreentime = async (req, res) => {
  try {
    const token = req.headers.token || req.headers.authorization;
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const supabase = getSupabaseClient(token);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return res.status(401).json({ error: 'Invalid token or auth session missing' });
    }

    const { duration, date, category } = req.body;
    const insertData = {
      user_id: user.id.toLowerCase(),
      duration,
      date,
      category,
    };

    const { data, error } = await supabase
      .from('screentime')
      .upsert([insertData], { onConflict: ['user_id', 'date'] })
      .select()
      .single();

    if (error) {
      console.error('Upsert error:', error);
      return res.status(500).json({ error: 'Upsert failed', details: error.message });
    }

    return res.status(201).json(data);
  } catch (error) {
    console.error('Server error:', error);
    return res.status(500).json({ error: error.message });
  }
};

const getScreentime = async (req, res) => {
  try {
    const token = req.headers.token || req.headers.authorization;
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const supabase = getSupabaseClient(token);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return res.status(401).json({ error: 'Invalid token or auth session missing' });
    }

    const { userId } = req.params;
    if (user.id !== userId) {
      return res.status(403).json({ error: 'Unauthorized to access this data' });
    }

    const { data, error } = await supabase
      .from('screentime')
      .select('*')
      .eq('user_id', userId);

    if (error) {
      console.error('Query error:', error);
      return res.status(500).json({ error: error.message });
    }

    res.json(data);
  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ error: error.message });
  }
};

const checkScreentime = async (req, res) => {
  try {
    const token = req.headers.token || req.headers.authorization;
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const supabase = getSupabaseClient(token);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    const { date } = req.query;
    if (!date) {
      return res.status(400).json({ error: 'Missing date' });
    }

    const { data, error } = await supabase
      .from('screentime')
      .select('*')
      .eq('user_id', user.id)
      .eq('date', date)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('Check error:', error);
      return res.status(500).json({ error: error.message });
    }

    return res.status(200).json({ exists: !!data });
  } catch (err) {
    console.error('Server error:', err);
    return res.status(500).json({ error: err.message });
  }
};

// const { getSupabaseClient } = require('../utils/supabase');
const { startOfWeek, endOfWeek, subWeeks } = require('date-fns');


const getLatestDrop = async (req, res) => {
  try {
    const token = req.headers.token || req.headers.authorization;
    if (!token) return res.status(401).json({ error: 'No token provided' });

    console.log('Debug - Received token:', token);
    
    const supabase = getSupabaseClient(token);
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    
    if (userError) {
      console.log('Debug - Auth Error:', userError);
      return res.status(401).json({ error: 'Invalid session' });
    }
    if (!user) {
      console.log('Debug - No user found');
      return res.status(401).json({ error: 'Invalid session' });
    }

    console.log('Debug - Authenticated user:', user.id);
    
    const userId = req.params.userId;
    if (user.id.toLowerCase() !== userId.toLowerCase()) {
      console.log('Debug - User ID mismatch:', { requestedId: userId, actualId: user.id });
      return res.status(403).json({ error: 'Unauthorized access' });
    }

    const today = new Date();
    const thisWeekStart = startOfWeek(today, { weekStartsOn: 1 });
    const thisWeekEnd = endOfWeek(today, { weekStartsOn: 1 });

    const lastWeekStart = subWeeks(thisWeekStart, 1);
    const lastWeekEnd = subWeeks(thisWeekEnd, 1);

    console.log('Debug - Date ranges:', {
      thisWeek: { start: thisWeekStart, end: thisWeekEnd },
      lastWeek: { start: lastWeekStart, end: lastWeekEnd }
    });

    // Fetch this week's entries
    const thisWeekResult = await supabase
      .from('screentime')
      .select('*')
      .eq('user_id', userId.toLowerCase())
      .gte('date', thisWeekStart.toISOString())
      .lte('date', thisWeekEnd.toISOString());

    console.log('Debug - This week query result:', {
      data: thisWeekResult.data,
      error: thisWeekResult.error
    });

    // Fetch last week's entries
    const lastWeekResult = await supabase
      .from('screentime')
      .select('*')
      .eq('user_id', userId.toLowerCase())
      .gte('date', lastWeekStart.toISOString())
      .lte('date', lastWeekEnd.toISOString());

    console.log('Debug - Last week query result:', {
      data: lastWeekResult.data,
      error: lastWeekResult.error
    });

    const thisWeekData = thisWeekResult.data || [];
    const lastWeekData = lastWeekResult.data || [];

    const sumMinutes = (entries) => entries.reduce((sum, e) => sum + (e.duration || 0), 0);
    const thisWeekTotal = sumMinutes(thisWeekData);
    const lastWeekTotal = sumMinutes(lastWeekData);

    // Calculate most used app from category field
    const appUsage = {};
    thisWeekData.forEach(entry => {
      if (entry.category) {
        appUsage[entry.category] = (appUsage[entry.category] || 0) + entry.duration;
      }
    });

    // Find the app with the most minutes
    const mostUsedApp = Object.entries(appUsage)
      .sort((a, b) => b[1] - a[1])[0] || [null, null];

    const response = {
      date: new Date().toISOString().split('T')[0],
      total_minutes: thisWeekTotal,
      average_daily_hours: +(thisWeekTotal / 7 / 60).toFixed(2),
      weekly_change: lastWeekTotal ? (thisWeekTotal - lastWeekTotal) / lastWeekTotal : null,
      most_used_app: mostUsedApp[0],
      most_used_app_minutes: mostUsedApp[1],
      missing_this_week: thisWeekData.length === 0,
      missing_last_week: lastWeekData.length === 0
    };

    console.log('Debug - Sending response:', response);
    return res.json(response);
  } catch (error) {
    console.error('Drop error:', error);
    res.status(500).json({ error: error.message });
  }
};


module.exports = {
  addScreentime,
  getScreentime,
  checkScreentime,
  getLatestDrop
};
