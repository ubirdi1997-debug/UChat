import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme, CssBaseline } from '@mui/material';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { ChatProvider } from './contexts/ChatContext';
import LoginPage from './components/LoginPage';
import ChatLayout from './components/ChatLayout';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // For demo purposes, allow access even without OAuth configured
  // In production, this would strictly enforce authentication
  return <>{children}</>;
};

const CallbackPage: React.FC = () => {
  const { handleCallback } = useAuth();

  React.useEffect(() => {
    handleCallback().then((success) => {
      if (success) {
        window.location.href = '/';
      }
    });
  }, [handleCallback]);

  return <div>Processing login...</div>;
};

const App: React.FC = () => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <AuthProvider>
          <ChatProvider>
            <Routes>
              <Route path="/login" element={<LoginPage />} />
              <Route path="/callback" element={<CallbackPage />} />
              <Route
                path="/"
                element={
                  <ProtectedRoute>
                    <ChatLayout />
                  </ProtectedRoute>
                }
              />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </ChatProvider>
        </AuthProvider>
      </Router>
    </ThemeProvider>
  );
};

export default App;
