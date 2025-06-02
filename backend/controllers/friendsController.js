const supabase = require('../supabase');

// Send a friend request from sender_id to receiver_id
exports.sendFriendRequest = async (req, res) => {
  try {
    const { sender_id, receiver_id } = req.body;

    if (!sender_id || !receiver_id) {
      return res.status(400).json({ error: 'Missing sender_id or receiver_id' });
    }

    const { error } = await supabase
      .from('friend_requests')
      .insert([{ sender_id, receiver_id }]);

    if (error){ 
      console.error('Supabase error:', error);
      return res.status(400).json({ error: error.message || 'Something went wrong' });
    }

    res.json({ message: 'Friend request sent' });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};

// Accept a friend request (adds to mutual friends and removes request)
exports.acceptFriendRequest = async (req, res) => {
  try {
    const { sender_id, receiver_id } = req.body;

    if (!sender_id || !receiver_id) {
      return res.status(400).json({ error: 'Missing sender_id or receiver_id' });
    }

    // Remove the friend request
    await supabase
      .from('friend_requests')
      .delete()
      .eq('sender_id', sender_id)
      .eq('receiver_id', receiver_id);

    // Insert mutual friendship entries
    const { error } = await supabase
      .from('friends')
      .insert([
        { user_id: sender_id, friend_id: receiver_id },
        { user_id: receiver_id, friend_id: sender_id }
      ]);

    if (error) return res.status(400).json({ error: error.message || 'Something went wrong' });

    res.json({ message: 'Friend added' });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};

// Decline a friend request (just removes the request)
exports.declineFriendRequest = async (req, res) => {
  try {
    const { sender_id, receiver_id } = req.body;

    if (!sender_id || !receiver_id) {
      return res.status(400).json({ error: 'Missing sender_id or receiver_id' });
    }

    const { error } = await supabase
      .from('friend_requests')
      .delete()
      .eq('sender_id', sender_id)
      .eq('receiver_id', receiver_id);

    if (error) return res.status(400).json({ error: error.message || 'Something went wrong' });

    res.json({ message: 'Friend request declined' });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};

// Remove a friend (removes both directions of friendship)
exports.removeFriend = async (req, res) => {
  try {
    const { user_id, friend_id } = req.body;

    if (!user_id || !friend_id) {
      return res.status(400).json({ error: 'Missing user_id or friend_id' });
    }

    const { error } = await supabase
      .from('friends')
      .delete()
      .or(`and(user_id.eq.${user_id},friend_id.eq.${friend_id}),and(user_id.eq.${friend_id},friend_id.eq.${user_id})`);

    if (error) return res.status(400).json({ error: error.message || 'Something went wrong' });

    res.json({ message: 'Friend removed' });
  } catch (err) {
    console.error('Caught exception:', err);
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};


// Get all friends for a given user
exports.getFriends = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({ error: 'Missing user_id' });
    }

    const { data, error } = await supabase
      .from('friends')
      .select('friend_id, users:friend_id (id, email, current_streak, current_screen_time)')
      .eq('user_id', user_id);

    if (error) return res.status(400).json({ error: error.message || 'Something went wrong' });

    // Return just the user info for each friend
    const friends = data.map(entry => entry.users);

    res.json({ friends });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};

// Get all incoming friend requests for a user
exports.getFriendRequests = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({ error: 'Missing user_id' });
    }

    const { data, error } = await supabase
      .from('friend_requests')
      .select('sender_id, users:sender_id (id, email, current_streak, current_screen_time)')
      .eq('receiver_id', user_id);

    if (error) return res.status(400).json({ error: error.message || 'Something went wrong' });

    const requests = data.map(entry => entry.users);

    res.json({ requests });
  } catch (err) {
    console.error('Caught exception:', err);
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};


exports.getRankedFriends = async (req, res) => {
  const { userId } = req.params;
  try {
    const { data, error } = await supabase
      .from('friends')
      .select('friend_id, users(name, profile_picture, curr_period_screentime)')
      .eq('user_id', userId)
      .order('users.curr_period_screentime', { ascending: true });

    if (error) throw error;

    const friends = data.map((entry, index) => ({
      id: entry.friend_id,
      rank: index + 1,
      name: entry.users.name,
      hours: entry.users.curr_period_screentime,
      imageName: entry.users.profile_picture
    }));

    res.status(200).json(friends);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


