const { supabase } = require('../utils/supabase');

exports.createFlare = async (req, res) => {
    try {
      const { sender_id, recipient_id, status, note } = req.body;
  
      // Validate required fields
      if (!sender_id || !recipient_id || !status) {
        return res.status(400).json({ error: 'Missing required fields: sender_id, recipient_id, or status' });
      }
  
      // Insert flare into the database
      const { data, error } = await supabase
        .from('flares')
        .insert([{
          sender_id,
          recipient_id,
          status,
          note: note || '' // default to empty string if not provided
        }])
        .select(); // returns the inserted row(s)
  
      if (error) {
        console.error('Error inserting flare:', error.message);
        return res.status(400).json({ error: error.message });
      }
  
      res.status(201).json({ message: 'Flare created successfully', flare: data[0] });
    } catch (err) {
      console.error('Unexpected error creating flare:', err);
      res.status(500).json({ error: err.message || 'Unexpected error' });
    }
  };

  exports.getOutgoingFlares = async (req, res) => {
    try {
      const { sender_id } = req.params;
  
      if (!sender_id) {
        return res.status(400).json({ error: 'Missing sender_id' });
      }
  
      const { data, error } = await supabase
        .from('flares')
        .select(`
          id,
          recipient_id,
          status,
          note,
          created_at,
          users:recipient_id (
            id,
            name,
            username,
            profile_picture
          )
        `)
        .eq('sender_id', sender_id)
        .order('created_at', { ascending: false });
  
      if (error) {
        console.error('[Outgoing flares error]', error.message);
        return res.status(400).json({ error: error.message });
      }
  
      const formatted = data.map(entry => ({
        id: entry.id,
        status: entry.status,
        note: entry.note,
        created_at: entry.created_at,
        recipient: {
          id: entry.users.id,
          name: entry.users.name,
          username: entry.users.username,
          profile_picture: entry.users.profile_picture
        }
      }));
  
      res.json({ flares: formatted });
    } catch (err) {
      console.error('[Unexpected error fetching outgoing flares]', err);
      res.status(500).json({ error: err.message || 'Unexpected error' });
    }
  };

  
  exports.getIncomingFlares = async (req, res) => {
    try {
      const { recipient_id } = req.params;
  
      if (!recipient_id) {
        return res.status(400).json({ error: 'Missing recipient_id' });
      }
  
      const { data, error } = await supabase
        .from('flares')
        .select(`
          id,
          sender_id,
          status,
          note,
          created_at,
          users:sender_id (
            id,
            name,
            username,
            profile_picture
          )
        `)
        .eq('recipient_id', recipient_id)
        .order('created_at', { ascending: false });
  
      if (error) {
        console.error('[Incoming flares error]', error.message);
        return res.status(400).json({ error: error.message });
      }
  
      const formatted = data.map(entry => ({
        id: entry.id,
        status: entry.status,
        note: entry.note,
        created_at: entry.created_at,
        sender: {
          id: entry.users.id,
          name: entry.users.name,
          username: entry.users.username,
          profile_picture: entry.users.profile_picture
        }
      }));
  
      res.json({ flares: formatted });
    } catch (err) {
      console.error('[Unexpected error fetching incoming flares]', err);
      res.status(500).json({ error: err.message || 'Unexpected error' });
    }
  };

  exports.deleteFlare = async (req, res) => {
    const { id } = req.params;
  
    try {
      const { error } = await supabase
        .from('flares')
        .delete()
        .eq('id', id);
  
      if (error) throw error;
  
      res.status(200).json({ message: 'Flare deleted successfully' });
    } catch (err) {
      console.error('❌ Error deleting flare:', err);
      res.status(500).json({ error: 'Failed to delete flare' });
    }
  };
  
  