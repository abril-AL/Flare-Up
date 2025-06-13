const { supabase } = require('../utils/supabase');

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

        // 23505 is the PostgreSQL error code for unique constraint violation
      if (error.code === '23505') {
       return res.status(409).json({ error: 'Friend request already sent' });
    }

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

    // Join on sender_id -> users
    const { data, error } = await supabase
      .from('friend_requests')
      .select(`
        sender_id,
        users:sender_id (
          id,
          name,
          username,
          profile_picture
        )
      `)
      .eq('receiver_id', user_id);

    if (error) {
      console.error("Supabase query error:", error);
      return res.status(400).json({ error: error.message || 'Something went wrong' });
    }

    // Format the results into the SwiftUI `FriendRequest` shape
    const requests = data.map(entry => ({
      name: entry.users.name,
      username: `@${entry.users.username}`, // match your dummy data format
      profile_picture: entry.users.profile_picture || "defaultProfile" // fallback in case it's null
    }));

    res.json({ requests });
  } catch (err) {
    console.error('Caught exception:', err);
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};


// controllers/friendsController.js
exports.getRankedFriends = async (req, res) => {
  const { userId } = req.params;
  console.log("Getting ranked friends for user:", userId);

  try {
    // Step 1: Get list of friend IDs
    const { data: friendIdsData, error: friendsError } = await supabase
      .from('friends')
      .select('friend_id')
      .eq('user_id', userId);

    if (friendsError) {
      console.error("Error fetching friend IDs:", friendsError);
      return res.status(500).json({ error: friendsError.message });
    }

    if (!friendIdsData || friendIdsData.length === 0) {
      console.warn("No friends found for user:", userId);
      return res.status(200).json([]);
    }

    const friendIds = friendIdsData.map(f => f.friend_id);
    console.log("Found friend IDs:", friendIds);

    // Step 2: Fetch friend user data including 'username'
    const { data: friendsData, error: usersError } = await supabase
      .from('users')
      .select('id, name, username, profile_picture, curr_drop_screentime')
      .in('id', friendIds);

    if (usersError) {
      console.error("Error fetching users for friend IDs:", usersError);
      return res.status(500).json({ error: usersError.message });
    }

    console.log("Fetched friend user data:", friendsData);

    // Step 3: Sort and format response
    const sortedFriends = friendsData
      .sort((a, b) => (a.curr_drop_screentime ?? 0) - (b.curr_drop_screentime ?? 0))
      .map((user, index) => ({
        id: user.id,
        rank: index + 1,
        name: user.name,
        username: user.username, // ✅ now included
        hours: user.curr_drop_screentime,
        imageName: user.profile_picture,
      }));

    res.status(200).json(sortedFriends);
  } catch (err) {
    console.error("Unexpected error:", err);
    res.status(500).json({ error: err.message });
  }
};











