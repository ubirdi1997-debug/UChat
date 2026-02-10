import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authService, UserProfile } from '../utils/auth';

interface AuthContextType {
  isAuthenticated: boolean;
  user: UserProfile | null;
  login: () => Promise<void>;
  logout: () => void;
  handleCallback: () => Promise<boolean>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState<UserProfile | null>(null);

  useEffect(() => {
    // Check authentication status on mount
    const authenticated = authService.isAuthenticated();
    
    // For demo mode, set a default user
    if (!authenticated) {
      const demoUser: UserProfile = {
        id: 'demo-user-' + Math.random().toString(36).substr(2, 9),
        email: 'demo@uchat.example.com',
        name: 'Demo User',
        picture: undefined,
      };
      setUser(demoUser);
      setIsAuthenticated(true);
    } else {
      setIsAuthenticated(authenticated);
      setUser(authService.getUserProfile());
    }
  }, []);

  const login = async () => {
    await authService.login();
  };

  const logout = () => {
    authService.logout();
    // Reset to demo user
    const demoUser: UserProfile = {
      id: 'demo-user-' + Math.random().toString(36).substr(2, 9),
      email: 'demo@uchat.example.com',
      name: 'Demo User',
      picture: undefined,
    };
    setUser(demoUser);
    setIsAuthenticated(true);
  };

  const handleCallback = async () => {
    const success = await authService.handleCallback();
    if (success) {
      setIsAuthenticated(true);
      setUser(authService.getUserProfile());
    }
    return success;
  };

  const value: AuthContextType = {
    isAuthenticated,
    user,
    login,
    logout,
    handleCallback,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
