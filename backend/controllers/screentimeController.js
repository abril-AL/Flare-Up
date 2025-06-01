const { getSupabaseClient } = require('../utils/supabase');

const addScreentime = async (req, res) => {
    try {
      const token = req.headers.token || req.headers.authorization;
  
      console.log('Using token:', token); // ✅ Moved inside function
  
      if (!token) {
        return res.status(401).json({ error: 'No token provided' });
      }
  
      const supabase = getSupabaseClient(token);
      console.log('Calling supabase.auth.getUser()...');
  
      const { data: { user }, error: userError } = await supabase.auth.getUser(token);
      console.log('Got user:', user);
  
      if (userError || !user) {
        console.error('Auth failed:', userError);
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
        .insert([insertData])
        .select()
        .single();
  
      if (error) {
        console.error('Insert error:', error);
        return res.status(500).json({
          error: 'Insert failed',
          details: error.message,
        });
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

        const supabase = await getSupabaseClient(token); // ✅ correctly awaits the client
        ;

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

module.exports = {
    addScreentime,
    getScreentime
};
