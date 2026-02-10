import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from 'react';
import { webSocketService, Message } from '../utils/websocket';
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
    if (isAuthenticated) {
      // Connect to WebSocket when authenticated
      webSocketService.connect();

      // Subscribe to connection changes
      const unsubscribeConnection = webSocketService.onConnectionChange(setIsConnected);

      // Subscribe to messages
      const unsubscribeMessages = webSocketService.onMessage((message) => {
        setMessages(prev => [...prev, message]);
      });

      return () => {
        unsubscribeConnection();
        unsubscribeMessages();
        webSocketService.disconnect();
      };
    }
  }, [isAuthenticated]);

  const sendMessage = useCallback((content: string) => {
    if (!currentRoom) {
      console.error('No room selected');
      return;
    }
    webSocketService.sendMessage(currentRoom, content);
  }, [currentRoom]);

  const joinRoom = useCallback((roomId: string) => {
    if (currentRoom) {
      webSocketService.leaveRoom(currentRoom);
    }
    webSocketService.joinRoom(roomId);
    setCurrentRoom(roomId);
    setMessages([]); // Clear messages when switching rooms
  }, [currentRoom]);

  const leaveRoom = useCallback(() => {
    if (currentRoom) {
      webSocketService.leaveRoom(currentRoom);
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
