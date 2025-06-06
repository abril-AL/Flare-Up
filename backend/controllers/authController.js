const { supabase, getSupabaseClient } = require('../utils/supabase');

const signIn = async (req, res) => {
    try {
        const { email, password } = req.body;
        console.log('Attempting to sign in with email:', email);
        
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            console.error('Supabase auth error:', error);
            throw error;
        }

        console.log('Sign in successful, user:', data.user.id);
        console.log('Full response data:', JSON.stringify(data, null, 2));
        
        // Send back the exact format from Supabase
        res.status(200).json(data);
    } catch (error) {
        console.error('Sign in error:', error);
        res.status(400).json({
            error: error.message
        });
    }
};

const signUp = async (req, res) => {
    try {
        const { email, password } = req.body;
        console.log('Attempting to sign up with email:', email);
        
        const { data, error } = await supabase.auth.signUp({
            email,
            password,
        });

        if (error) {
            console.error('Supabase auth error:', error);
            throw error;
        }

        console.log('Sign up successful, user:', data.user.id);
        console.log('Full response data:', JSON.stringify(data, null, 2));
        
        // Send back the exact format from Supabase
        res.status(200).json(data);
    } catch (error) {
        console.error('Sign up error:', error);
        res.status(400).json({
            error: error.message
        });
    }
};

const signOut = async (req, res) => {
    try {
        const { token } = req.headers;
        if (!token) {
            return res.status(401).json({ error: 'No token provided' });
        }

        // Get an authorized client
        const authorizedClient = await getSupabaseClient(token);

        // Sign out the user
        const { error } = await authorizedClient.auth.signOut();
        
        if (error) {
            console.error('Error signing out:', error);
            return res.status(500).json({ 
                error: 'Failed to sign out',
                details: error.message 
            });
        }

        res.status(200).json({ message: 'Successfully signed out' });
    } catch (error) {
        console.error('Error in sign out:', error);
        res.status(500).json({ 
            error: 'Internal server error',
            details: error.message 
        });
    }
};

module.exports = {
    signIn,
    signUp,
    signOut
}; 