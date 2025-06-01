const { getSupabaseClient } = require('../utils/supabase');

const getUser = async (req, res) => {
    const token = req.headers.authorization;
    if (!token) return res.status(401).json({ error: 'Missing token' });

    const supabase = getSupabaseClient(token);
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error || !user) return res.status(401).json({ error: 'Unauthorized' });

    const { data, error: userFetchError } = await supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single();

    if (userFetchError) return res.status(500).json({ error: userFetchError.message });
    return res.json(data);
};

const updateUser = async (req, res) => {
    const token = req.headers.authorization;
    if (!token) return res.status(401).json({ error: 'Missing token' });

    const supabase = getSupabaseClient(token);
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error || !user) return res.status(401).json({ error: 'Unauthorized' });

    const { name, username, goal_screen_time } = req.body;
    const updates = {
        ...(name && { name }),
        ...(username && { username }),
        ...(goal_screen_time !== undefined && { goal_screen_time })
    };

    const { data: updated, error: updateError } = await supabase
        .from('users')
        .update(updates)
        .eq('id', user.id)
        .select()
        .single();

    if (updateError) return res.status(500).json({ error: updateError.message });
    return res.json(updated);
};

const initializeUserProfile = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.id) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const { name, username, goal_screen_time } = req.body;

    if (!name || !username || typeof goal_screen_time !== 'number') {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const { error } = await supabase
      .from('users')
      .upsert({
        id: user.id,
        name,
        username,
        goal_screen_time,
        current_streak: 0,
        created_at: new Date().toISOString()
      }, { onConflict: ['id'] });

    if (error) {
      console.error('Error saving user profile:', error.message);
      return res.status(500).json({ error: 'Failed to save user profile' });
    }

    return res.status(200).json({ message: 'User profile initialized' });
  } catch (err) {
    console.error('Server error in initializeUserProfile:', err.message);
    return res.status(500).json({ error: 'Server error' });
  }
};



console.log('[PUT] /users/update');
console.log('Headers:', req.headers);
console.log('Body:', req.body);

module.exports = { getUser, updateUser, initializeUserProfile };

