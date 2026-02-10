import React from 'react';
import {
  Box,
  Button,
  Container,
  Typography,
  Paper,
  Stack,
} from '@mui/material';
import LockIcon from '@mui/icons-material/Lock';
import ChatIcon from '@mui/icons-material/Chat';
import SecurityIcon from '@mui/icons-material/Security';
import { useAuth } from '../contexts/AuthContext';

const LoginPage: React.FC = () => {
  const { login } = useAuth();

  const handleLogin = async () => {
    try {
      await login();
    } catch (error) {
      console.error('Login failed:', error);
    }
  };

  return (
    <Container maxWidth="sm">
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          py: 4,
        }}
      >
        <Paper
          elevation={3}
          sx={{
            p: 4,
            width: '100%',
            borderRadius: 2,
          }}
        >
          <Stack spacing={3} alignItems="center">
            <ChatIcon sx={{ fontSize: 60, color: 'primary.main' }} />
            <Typography variant="h3" component="h1" gutterBottom>
              UChat
            </Typography>
            <Typography variant="h6" color="text.secondary" textAlign="center">
              Encrypted End-to-End Chatting Application
            </Typography>

            <Stack spacing={2} sx={{ width: '100%', mt: 3 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <LockIcon color="primary" />
                <Typography variant="body1">
                  End-to-end encryption for secure messaging
                </Typography>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <ChatIcon color="primary" />
                <Typography variant="body1">
                  Real-time messaging with WebSockets
                </Typography>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <SecurityIcon color="primary" />
                <Typography variant="body1">
                  Secure OAuth 2.0 / OIDC authentication
                </Typography>
              </Box>
            </Stack>

            <Button
              variant="contained"
              size="large"
              fullWidth
              onClick={handleLogin}
              sx={{ mt: 4 }}
            >
              Login with OAuth
            </Button>

            <Typography variant="caption" color="text.secondary" textAlign="center">
              Demo mode: OAuth server is not configured. Click to see the login flow.
            </Typography>
          </Stack>
        </Paper>
      </Box>
    </Container>
  );
};

export default LoginPage;
