import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from 'react';
import { Message } from '../utils/websocket';
import { demoWebSocketService } from '../utils/demo-websocket';
import { useAuth } from './AuthContext';

interface ChatContextType {
  messages: Message[];
  isConnected: boolean;
  currentRoom: string | null;
  sendMessage: (content: string) => void;
  joinRoom: (roomId: string) => void;
  leaveRoom: () => void;
}

const ChatContext = createContext<ChatContextType | undefined>(undefined);

export const useChat = () => {
  const context = useContext(ChatContext);
  if (!context) {
    throw new Error('useChat must be used within ChatProvider');
  }
  return context;
};

interface ChatProviderProps {
  children: ReactNode;
}

export const ChatProvider: React.FC<ChatProviderProps> = ({ children }) => {
  const { isAuthenticated } = useAuth();
  const [messages, setMessages] = useState<Message[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [currentRoom, setCurrentRoom] = useState<string | null>(null);

  useEffect(() => {
    // Always connect to demo WebSocket for demo mode
    const wsService = demoWebSocketService;
    
    // Connect to WebSocket
    wsService.connect();

    // Subscribe to connection changes
    const unsubscribeConnection = wsService.onConnectionChange(setIsConnected);

    // Subscribe to messages
    const unsubscribeMessages = wsService.onMessage((message) => {
      setMessages(prev => [...prev, message]);
    });

    return () => {
      unsubscribeConnection();
      unsubscribeMessages();
      wsService.disconnect();
    };
  }, [isAuthenticated]);

  const sendMessage = useCallback((content: string) => {
    if (!currentRoom) {
      console.error('No room selected');
      return;
    }
    demoWebSocketService.sendMessage(currentRoom, content);
  }, [currentRoom]);

  const joinRoom = useCallback((roomId: string) => {
    if (currentRoom) {
      demoWebSocketService.leaveRoom();
    }
    demoWebSocketService.joinRoom(roomId);
    setCurrentRoom(roomId);
    setMessages([]); // Clear messages when switching rooms
  }, [currentRoom]);

  const leaveRoom = useCallback(() => {
    if (currentRoom) {
      demoWebSocketService.leaveRoom();
      setCurrentRoom(null);
      setMessages([]);
    }
  }, [currentRoom]);

  const value: ChatContextType = {
    messages,
    isConnected,
    currentRoom,
    sendMessage,
    joinRoom,
    leaveRoom,
  };

  return <ChatContext.Provider value={value}>{children}</ChatContext.Provider>;
};
