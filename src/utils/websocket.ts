/**
 * WebSocket service for real-time chat
 */
import { io, Socket } from 'socket.io-client';

export interface Message {
  id: string;
  senderId: string;
  senderName: string;
  content: string;
  timestamp: number;
  encrypted?: boolean;
}

export interface ChatRoom {
  id: string;
  name: string;
  participants: string[];
}

export type MessageHandler = (message: Message) => void;
export type ConnectionHandler = (connected: boolean) => void;

export class WebSocketService {
  private socket: Socket | null = null;
  private messageHandlers: MessageHandler[] = [];
  private connectionHandlers: ConnectionHandler[] = [];
  private serverUrl: string;

  constructor(serverUrl: string = 'http://localhost:3001') {
    this.serverUrl = serverUrl;
  }

  /**
   * Connect to WebSocket server
   */
  connect(accessToken?: string): void {
    if (this.socket?.connected) {
      return;
    }

    this.socket = io(this.serverUrl, {
      auth: {
        token: accessToken,
      },
      transports: ['websocket', 'polling'],
    });

    this.socket.on('connect', () => {
      console.log('WebSocket connected');
      this.notifyConnectionHandlers(true);
    });

    this.socket.on('disconnect', () => {
      console.log('WebSocket disconnected');
      this.notifyConnectionHandlers(false);
    });

    this.socket.on('message', (message: Message) => {
      this.notifyMessageHandlers(message);
    });

    this.socket.on('error', (error: Error) => {
      console.error('WebSocket error:', error);
    });
  }

  /**
   * Disconnect from WebSocket server
   */
  disconnect(): void {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }

  /**
   * Send a message
   */
  sendMessage(roomId: string, content: string): void {
    if (!this.socket?.connected) {
      throw new Error('WebSocket not connected');
    }

    this.socket.emit('message', {
      roomId,
      content,
      timestamp: Date.now(),
    });
  }

  /**
   * Join a chat room
   */
  joinRoom(roomId: string): void {
    if (!this.socket?.connected) {
      throw new Error('WebSocket not connected');
    }

    this.socket.emit('join_room', { roomId });
  }

  /**
   * Leave a chat room
   */
  leaveRoom(roomId: string): void {
    if (!this.socket?.connected) {
      throw new Error('WebSocket not connected');
    }

    this.socket.emit('leave_room', { roomId });
  }

  /**
   * Register a message handler
   */
  onMessage(handler: MessageHandler): () => void {
    this.messageHandlers.push(handler);
    return () => {
      this.messageHandlers = this.messageHandlers.filter(h => h !== handler);
    };
  }

  /**
   * Register a connection status handler
   */
  onConnectionChange(handler: ConnectionHandler): () => void {
    this.connectionHandlers.push(handler);
    return () => {
      this.connectionHandlers = this.connectionHandlers.filter(h => h !== handler);
    };
  }

  /**
   * Check if connected
   */
  isConnected(): boolean {
    return this.socket?.connected || false;
  }

  /**
   * Notify all message handlers
   */
  private notifyMessageHandlers(message: Message): void {
    this.messageHandlers.forEach(handler => {
      try {
        handler(message);
      } catch (error) {
        console.error('Error in message handler:', error);
      }
    });
  }

  /**
   * Notify all connection handlers
   */
  private notifyConnectionHandlers(connected: boolean): void {
    this.connectionHandlers.forEach(handler => {
      try {
        handler(connected);
      } catch (error) {
        console.error('Error in connection handler:', error);
      }
    });
  }
}

export const webSocketService = new WebSocketService();
