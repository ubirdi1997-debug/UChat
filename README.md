# UChat

A modern, encrypted end-to-end chatting application built with React, TypeScript, and Progressive Web App (PWA) technologies.

## Features

- 🔐 **End-to-End Encryption**: Messages are encrypted using RSA-OAEP (2048-bit) encryption via the Web Crypto API
- 💬 **Real-time Chat**: WebSocket-based real-time messaging using Socket.io
- 🔒 **OAuth 2.0 / OIDC**: Secure authentication with PKCE flow support
- 📱 **Progressive Web App**: Installable, offline-capable with service worker caching
- 🎨 **Modern UI**: Material-UI components with responsive design
- ⚡ **Fast & Lightweight**: Built with Vite for optimal performance

## Tech Stack

- **Frontend Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **UI Library**: Material-UI (MUI)
- **Routing**: React Router v6
- **Real-time Communication**: Socket.io Client
- **PWA**: Workbox for service worker and caching
- **Encryption**: Web Crypto API (RSA-OAEP, AES-GCM)
- **Authentication**: OAuth 2.0 / OpenID Connect with PKCE

## Getting Started

### Prerequisites

- Node.js 18+ and npm/yarn/pnpm
- A WebSocket server (for real-time chat functionality)
- An OAuth 2.0 / OIDC provider (for authentication)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ubirdi1997-debug/UChat.git
cd UChat
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment (optional):
   - Update OAuth configuration in `src/utils/auth.ts`
   - Update WebSocket server URL in `src/utils/websocket.ts`

### Development

Run the development server:
```bash
npm run dev
```

The app will be available at `http://localhost:3000`

### Building for Production

Build the application:
```bash
npm run build
```

Preview the production build:
```bash
npm run preview
```

### Linting

Run ESLint:
```bash
npm run lint
```

## Project Structure

```
UChat/
├── src/
│   ├── components/          # React components
│   │   ├── ChatLayout.tsx   # Main chat layout with sidebar
│   │   ├── ChatWindow.tsx   # Chat messages and input
│   │   └── LoginPage.tsx    # Authentication page
│   ├── contexts/            # React contexts
│   │   ├── AuthContext.tsx  # Authentication state management
│   │   └── ChatContext.tsx  # Chat state management
│   ├── utils/               # Utility functions
│   │   ├── auth.ts          # OAuth 2.0 / OIDC implementation
│   │   ├── encryption.ts    # E2E encryption utilities
│   │   └── websocket.ts     # WebSocket service
│   ├── App.tsx              # Main app component
│   ├── main.tsx             # Application entry point
│   └── index.css            # Global styles
├── public/                  # Static assets
├── index.html               # HTML template
├── vite.config.ts          # Vite configuration
├── tsconfig.json           # TypeScript configuration
└── package.json            # Project dependencies
```

## Architecture

### Authentication Flow

1. User clicks "Login with OAuth"
2. App generates PKCE challenge and redirects to OAuth provider
3. User authenticates with OAuth provider
4. OAuth provider redirects back with authorization code
5. App exchanges code for access tokens
6. User profile is loaded from ID token

### Encryption Flow

1. Each user generates an RSA key pair on login
2. Public keys are exchanged with chat participants
3. Messages are encrypted with recipient's public key
4. Only the recipient can decrypt with their private key
5. For group chats, symmetric AES-GCM keys can be used

### WebSocket Communication

1. Client connects to WebSocket server with access token
2. Client joins specific chat rooms
3. Messages are sent/received in real-time
4. Connection status is monitored and displayed

## PWA Features

- **Service Worker**: Automatic caching of static assets
- **Offline Support**: App shell cached for offline access
- **Installable**: Can be installed as a standalone app
- **Manifest**: Configured for Android and iOS home screen
- **Auto-update**: Service worker updates automatically

## Security Considerations

### Current Demo Implementation

⚠️ **Important**: This is a demonstration implementation. For production use:

1. **Backend Required**: Implement a secure backend server
   - Store user data and chat history securely
   - Validate and sanitize all inputs
   - Implement rate limiting and CSRF protection

2. **OAuth Configuration**: 
   - Configure real OAuth 2.0 provider (Auth0, Okta, etc.)
   - Store client secrets securely (never in frontend)
   - Use environment variables for configuration

3. **WebSocket Security**:
   - Implement authentication middleware
   - Use WSS (WebSocket Secure) in production
   - Validate all incoming messages

4. **Encryption Improvements**:
   - Implement key rotation
   - Store private keys securely (encrypted at rest)
   - Add forward secrecy with temporary session keys
   - Implement key verification (safety numbers)

5. **Additional Security**:
   - Implement HTTPS (TLS) everywhere
   - Add Content Security Policy (CSP) headers
   - Enable HTTP Strict Transport Security (HSTS)
   - Implement proper session management

## Configuration

### OAuth 2.0 Setup

Update `src/utils/auth.ts` with your OAuth provider details:

```typescript
export const authConfig: AuthConfig = {
  clientId: 'your-client-id',
  authorizationEndpoint: 'https://your-auth-server/oauth/authorize',
  tokenEndpoint: 'https://your-auth-server/oauth/token',
  redirectUri: window.location.origin + '/callback',
  scope: 'openid profile email',
};
```

### WebSocket Server Setup

Update `src/utils/websocket.ts` with your WebSocket server URL:

```typescript
export class WebSocketService {
  constructor(serverUrl: string = 'https://your-websocket-server') {
    this.serverUrl = serverUrl;
  }
}
```

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- All modern browsers with:
  - ES2020 support
  - Web Crypto API
  - Service Worker API
  - WebSocket support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is provided as-is for demonstration purposes.

## Demo Mode

The application runs in demo mode by default, which means:
- OAuth authentication is simulated (no real OAuth server required)
- WebSocket connections will fail without a backend server
- Encryption functionality is fully working using Web Crypto API
- The UI and all components are fully functional

To use in production, configure:
1. A real OAuth 2.0 / OIDC provider
2. A WebSocket backend server
3. A database for storing user data and messages
4. Proper security measures as outlined above

## Roadmap

- [ ] Add message persistence with backend
- [ ] Implement file sharing with encryption
- [ ] Add voice/video calling
- [ ] Implement message reactions and threading
- [ ] Add push notifications
- [ ] Implement group chat management
- [ ] Add message search functionality
- [ ] Implement user presence indicators
- [ ] Add message read receipts
- [ ] Support for message editing and deletion 
