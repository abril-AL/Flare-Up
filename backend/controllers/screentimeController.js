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
      user_id: user.id,
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

module.exports = {
  addScreentime,
  getScreentime,
  checkScreentime,
};
