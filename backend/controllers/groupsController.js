const supabase = require('../supabase');

// Create a group with optional invited users
exports.createGroup = async (req, res) => {
  try {
    const { name, created_by, invite_user_ids = [] } = req.body;

    const { data: group, error: groupError } = await supabase
      .from('groups')
      .insert([{ name, created_by }])
      .select()
      .single();

    if (groupError) return res.status(400).json({ error: groupError.message });

    // Add creator to memberships
    await supabase
      .from('group_memberships')
      .insert([{ user_id: created_by, group_id: group.id }]);

    // Add invites
    if (invite_user_ids.length > 0) {
      const invites = invite_user_ids.map(user_id => ({
        user_id,
        group_id: group.id,
        invited_by: created_by,
      }));
      await supabase.from('group_invites').insert(invites);
    }

    res.json({ group });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};

// Invite a user to a group
exports.sendGroupInvite = async (req, res) => {
  try {
    const { user_id, group_id, invited_by } = req.body;

    const { error } = await supabase
      .from('group_invites')
      .insert([{ user_id, group_id, invited_by }]);

    if (error) return res.status(400).json({ error: error.message });
    res.json({ message: 'Invite sent' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Accept a group invite
exports.acceptGroupInvite = async (req, res) => {
  try {
    const { user_id, group_id } = req.body;

    // Remove invite
    await supabase
      .from('group_invites')
      .delete()
      .eq('user_id', user_id)
      .eq('group_id', group_id);

    // Add to membership
    const { error } = await supabase
      .from('group_memberships')
      .insert([{ user_id, group_id }]);

    if (error) return res.status(400).json({ error: error.message });

    res.json({ message: 'Joined group' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Decline a group invite
exports.declineGroupInvite = async (req, res) => {
  try {
    const { user_id, group_id } = req.body;

    const { error } = await supabase
      .from('group_invites')
      .delete()
      .eq('user_id', user_id)
      .eq('group_id', group_id);

    if (error) return res.status(400).json({ error: error.message });

    res.json({ message: 'Invite declined' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get all groups a user is in
exports.getUserGroups = async (req, res) => {
  try {
    const { user_id } = req.params;

    const { data, error } = await supabase
      .from('group_memberships')
      .select('group_id, groups:group_id (id, name, wager)')
      .eq('user_id', user_id);

    if (error) return res.status(400).json({ error: error.message });

    const groups = data.map(entry => entry.groups);
    res.json({ groups });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get groups a user is in, with name + member profile pictures
exports.getUserGroupDetails = async (req, res) => {
  try {
    const { user_id } = req.params;

    // Step 1: Get the groups the user is a member of
    const { data: memberships, error: membershipError } = await supabase
      .from('group_memberships')
      .select('group_id, groups:group_id (id, name)')
      .eq('user_id', user_id);

    if (membershipError) {
      console.error("❌ Membership fetch error:", membershipError);
      return res.status(400).json({ error: membershipError.message });
    }

    const groupList = [];

    for (const membership of memberships) {
      const group = membership.groups;

      // Step 2: Fetch members' profile pictures for this group
      const { data: members, error: memberError } = await supabase
        .from('group_memberships')
        .select('users:user_id (profile_picture)')
        .eq('group_id', group.id);

      if (memberError) {
        console.error("❌ Member fetch error:", memberError);
        return res.status(400).json({ error: memberError.message });
      }

      const memberPics = members.map(entry => entry.users?.profile_picture || 'defaultProfile');

      groupList.push({
        id: group.id,
        name: group.name,
        members: memberPics
      });
    }

    return res.json({ groups: groupList });
  } catch (err) {
    console.error('❌ Exception:', err);
    return res.status(500).json({ error: err.message || 'Something went wrong' });
  }
};



// Get all members of a group
exports.getGroupMembers = async (req, res) => {
  try {
    const { group_id } = req.params;

    const { data, error } = await supabase
      .from('group_memberships')
      .select('user_id, users:user_id (id, email, current_streak, current_screen_time)')
      .eq('group_id', group_id);

    if (error) return res.status(400).json({ error: error.message });

    const members = data.map(entry => entry.users);
    res.json({ members });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
