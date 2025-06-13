const supabase = require('../supabase');
require('dotenv').config();

exports.signup = async (req, res) => {
  try {
    const { email, password, username, goal_screen_time, profile_picture } = req.body;

    if (!email || !password || !username || !goal_screen_time) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // 1. Create Auth user
    const { data: userData, error: signupError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    });

    if (signupError) {
      console.error('[Auth signup error]', signupError.message);
      return res.status(400).json({ error: signupError.message });
    }

    if (!userData?.user?.id) {
      console.error('[Auth user missing in response]');
      return res.status(500).json({ error: 'Unexpected error creating user' });
    }

    const userId = userData.user.id;

    // 2. Upload profile picture if provided
    let profileUrl = '';
    if (profile_picture) {
      try {
        const buffer = Buffer.from(profile_picture, 'base64');
        const fileName = `${userId}.jpg`;

        const { error: uploadError } = await supabase.storage
          .from('profile-pics')
          .upload(fileName, buffer, {
            contentType: 'image/jpeg',
            upsert: true
          });

        if (uploadError) {
          console.error('[Profile upload error]', uploadError.message);
          return res.status(400).json({ error: uploadError.message });
        }

        profileUrl = `${process.env.SUPABASE_URL}/storage/v1/object/public/profile-pics/${fileName}`;
      } catch (uploadException) {
        console.error('[Profile upload exception]', uploadException);
        return res.status(400).json({ error: 'Failed to upload profile picture' });
      }
    }

    // 3. Insert into users table
    const { error: insertError } = await supabase
      .from('users')
      .insert([
        {
          id: userId,
          email,
          username,
          goal_screen_time,
          profile_picture: profileUrl
        }
      ]);

    if (insertError) {
      console.error('[User insert error]', insertError.message);
      return res.status(400).json({ error: insertError.message });
    }

    res.status(201).json({ message: 'Signup successful', user_id: userId });
  } catch (err) {
    console.error('[Unexpected signup exception]', err);
    res.status(500).json({ error: err.message || 'Something went wrong during signup' });
  }
};

exports.getUserIdByUsername = async (req, res) => {
  const { username } = req.params;

  if (!username) {
    return res.status(400).json({ error: 'Missing username' });
  }

  const { data, error } = await supabase
    .from('users')
    .select('id')
    .eq('username', username)
    .single(); // because usernames are unique

  if (error || !data) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json({ id: data.id });
};

