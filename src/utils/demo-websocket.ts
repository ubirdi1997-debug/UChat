/**
 * Demo WebSocket service that simulates real-time chat without a backend
 */
import { Message } from './websocket';

export type MessageHandler = (message: Message) => void;
export type ConnectionHandler = (connected: boolean) => void;

export class DemoWebSocketService {
  private messageHandlers: MessageHandler[] = [];
  private connectionHandlers: ConnectionHandler[] = [];
  private connected = false;
  private messageIdCounter = 0;

  /**
   * Simulate connection to WebSocket server
   */
  connect(): void {
    if (this.connected) {
      return;
    }

    // Simulate connection delay
    setTimeout(() => {
      this.connected = true;
      console.log('Demo WebSocket connected');
      this.notifyConnectionHandlers(true);

      // Send welcome message
      setTimeout(() => {
        this.simulateIncomingMessage({
          id: `demo-${this.messageIdCounter++}`,
          senderId: 'system',
          senderName: 'System',
          content: 'Welcome to UChat! This is a demo mode without a backend server.',
          timestamp: Date.now(),
        });
      }, 1000);
    }, 500);
  }

  /**
   * Disconnect from WebSocket server
   */
  disconnect(): void {
    if (this.connected) {
      this.connected = false;
      console.log('Demo WebSocket disconnected');
      this.notifyConnectionHandlers(false);
    }
  }

  /**
   * Send a message (simulated)
   */
  sendMessage(_roomId: string, content: string): void {
    if (!this.connected) {
      throw new Error('WebSocket not connected');
    }

    // Echo the message back
    const message: Message = {
      id: `demo-${this.messageIdCounter++}`,
      senderId: 'current-user',
      senderName: 'You',
      content,
      timestamp: Date.now(),
    };

    this.simulateIncomingMessage(message);

    // Simulate a response from another user
    setTimeout(() => {
      const responses = [
        'That\'s interesting!',
        'I agree!',
        'Tell me more...',
        'Cool!',
        'Nice!',
        'Thanks for sharing!',
      ];
      const randomResponse = responses[Math.floor(Math.random() * responses.length)];

      this.simulateIncomingMessage({
        id: `demo-${this.messageIdCounter++}`,
        senderId: 'demo-user',
        senderName: 'Demo User',
        content: randomResponse,
        timestamp: Date.now(),
        encrypted: true,
      });
    }, 1000 + Math.random() * 2000);
  }

  /**
   * Join a chat room (simulated)
   */
  joinRoom(roomId: string): void {
    if (!this.connected) {
      throw new Error('WebSocket not connected');
    }

    console.log('Joined room:', roomId);

    // Send a welcome message for the room
    setTimeout(() => {
      this.simulateIncomingMessage({
        id: `demo-${this.messageIdCounter++}`,
        senderId: 'system',
        senderName: 'System',
        content: `Welcome to the ${roomId} room! Messages here are encrypted end-to-end.`,
        timestamp: Date.now(),
      });
    }, 500);
  }

  /**
   * Leave a chat room (simulated)
   */
  leaveRoom(): void {
    console.log('Left room');
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
    return this.connected;
  }

  /**
   * Simulate an incoming message
   */
  private simulateIncomingMessage(message: Message): void {
    this.notifyMessageHandlers(message);
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

export const demoWebSocketService = new DemoWebSocketService();
