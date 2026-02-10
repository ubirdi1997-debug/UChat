# Production Configuration Guide

This guide explains how to configure UChat for production deployment.

## Overview

The UChat application requires three main components for production:
1. **Frontend Application** (this repository)
2. **WebSocket Server** (for real-time chat)
3. **OAuth 2.0 Provider** (for authentication)

## Environment Configuration

### 1. Create Environment Files

Create a `.env` file in the root directory:

```env
# OAuth Configuration
VITE_OAUTH_CLIENT_ID=your-client-id-here
VITE_OAUTH_AUTH_ENDPOINT=https://your-auth-server.com/oauth/authorize
VITE_OAUTH_TOKEN_ENDPOINT=https://your-auth-server.com/oauth/token
VITE_OAUTH_REDIRECT_URI=https://your-domain.com/callback
VITE_OAUTH_SCOPE=openid profile email

# WebSocket Server
VITE_WEBSOCKET_URL=wss://your-websocket-server.com

# API Configuration (optional)
VITE_API_BASE_URL=https://your-api.com/api/v1
```

### 2. Update Auth Configuration

Edit `src/utils/auth.ts`:

```typescript
export const authConfig: AuthConfig = {
  clientId: import.meta.env.VITE_OAUTH_CLIENT_ID,
  authorizationEndpoint: import.meta.env.VITE_OAUTH_AUTH_ENDPOINT,
  tokenEndpoint: import.meta.env.VITE_OAUTH_TOKEN_ENDPOINT,
  redirectUri: import.meta.env.VITE_OAUTH_REDIRECT_URI || window.location.origin + '/callback',
  scope: import.meta.env.VITE_OAUTH_SCOPE || 'openid profile email',
};
```

### 3. Update WebSocket Configuration

Edit `src/utils/websocket.ts`:

```typescript
export class WebSocketService {
  constructor(serverUrl: string = import.meta.env.VITE_WEBSOCKET_URL || 'ws://localhost:3001') {
    this.serverUrl = serverUrl;
  }
}
```

### 4. Update Context to Use Production Services

Edit `src/contexts/ChatContext.tsx`:

```typescript
// Replace demo service with real service
import { webSocketService } from '../utils/websocket';

// In useEffect:
const wsService = import.meta.env.MODE === 'production' 
  ? webSocketService 
  : demoWebSocketService;
```

## OAuth 2.0 Provider Setup

### Option 1: Auth0

1. Create an Auth0 account at https://auth0.com
2. Create a new application (Single Page Application)
3. Configure settings:
   - **Allowed Callback URLs**: `https://your-domain.com/callback`
   - **Allowed Logout URLs**: `https://your-domain.com`
   - **Allowed Web Origins**: `https://your-domain.com`
4. Copy credentials:
   - Client ID
   - Domain (use for endpoints)

**Endpoints:**
- Authorization: `https://YOUR_DOMAIN.auth0.com/authorize`
- Token: `https://YOUR_DOMAIN.auth0.com/oauth/token`

### Option 2: Okta

1. Create an Okta developer account
2. Create a new application (SPA)
3. Configure:
   - Sign-in redirect URIs: `https://your-domain.com/callback`
   - Sign-out redirect URIs: `https://your-domain.com`
4. Copy credentials

**Endpoints:**
- Authorization: `https://YOUR_DOMAIN.okta.com/oauth2/default/v1/authorize`
- Token: `https://YOUR_DOMAIN.okta.com/oauth2/default/v1/token`

### Option 3: Google OAuth

1. Go to Google Cloud Console
2. Create OAuth 2.0 credentials
3. Configure:
   - Authorized redirect URIs: `https://your-domain.com/callback`
4. Copy Client ID

**Endpoints:**
- Authorization: `https://accounts.google.com/o/oauth2/v2/auth`
- Token: `https://oauth2.googleapis.com/token`

### Option 4: Custom OAuth Server

If you're running your own OAuth server:

1. Ensure it supports OAuth 2.0 with PKCE
2. Configure redirect URIs
3. Enable CORS for your domain
4. Support the following grant types:
   - Authorization Code with PKCE
   - Refresh Token (optional)

## WebSocket Server Setup

### Option 1: Simple Node.js Server

Create a basic Socket.io server:

```javascript
// server.js
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "https://your-domain.com",
    methods: ["GET", "POST"]
  }
});

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join_room', ({ roomId }) => {
    socket.join(roomId);
    console.log(`User ${socket.id} joined room ${roomId}`);
  });

  socket.on('leave_room', ({ roomId }) => {
    socket.leave(roomId);
  });

  socket.on('message', ({ roomId, content }) => {
    const message = {
      id: Date.now().toString(),
      senderId: socket.id,
      senderName: socket.handshake.auth.name || 'User',
      content,
      timestamp: Date.now(),
    };
    io.to(roomId).emit('message', message);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`WebSocket server running on port ${PORT}`);
});
```

Install dependencies:
```bash
npm install express socket.io cors
```

Run:
```bash
node server.js
```

### Option 2: Deploy to Cloud Services

#### Heroku
```bash
heroku create your-websocket-server
git push heroku main
```

#### AWS EC2
1. Launch EC2 instance
2. Install Node.js
3. Deploy server code
4. Configure security groups (port 3001)
5. Use nginx as reverse proxy

#### DigitalOcean
1. Create Droplet
2. Follow similar steps as AWS

### Option 3: Serverless WebSocket

Use AWS API Gateway WebSocket API or similar services for serverless WebSocket handling.

## Build Configuration

### 1. Update Vite Config for Production

Edit `vite.config.ts`:

```typescript
export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        cleanupOutdatedCaches: true,
        skipWaiting: true,
      }
    })
  ],
  build: {
    target: 'es2020',
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'mui-vendor': ['@mui/material', '@emotion/react', '@emotion/styled'],
        }
      }
    }
  }
});
```

### 2. Build for Production

```bash
npm run build
```

Output will be in `dist/` directory.

### 3. Test Production Build Locally

```bash
npm run preview
```

## Deployment Options

### Option 1: Vercel

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Deploy:
```bash
vercel --prod
```

3. Configure environment variables in Vercel dashboard

### Option 2: Netlify

1. Install Netlify CLI:
```bash
npm install -g netlify-cli
```

2. Deploy:
```bash
netlify deploy --prod
```

3. Configure environment variables in Netlify dashboard

### Option 3: AWS S3 + CloudFront

1. Build application
2. Upload `dist/` to S3 bucket
3. Configure bucket for static website hosting
4. Create CloudFront distribution
5. Point domain to CloudFront

### Option 4: Docker

Create `Dockerfile`:

```dockerfile
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Create `nginx.conf`:

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /assets {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Build and run:
```bash
docker build -t uchat .
docker run -p 80:80 uchat
```

## Security Configuration

### 1. Content Security Policy

Add to your hosting configuration:

```
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' wss://your-websocket-server.com https://your-auth-server.com;
  img-src 'self' data: https:;
```

### 2. HTTPS Configuration

**Required for production:**
- Obtain SSL certificate (Let's Encrypt, etc.)
- Configure web server for HTTPS
- Redirect HTTP to HTTPS
- Enable HSTS header

### 3. CORS Configuration

Configure WebSocket server CORS:

```javascript
const io = socketIo(server, {
  cors: {
    origin: ["https://your-domain.com"],
    methods: ["GET", "POST"],
    credentials: true
  }
});
```

## Monitoring & Analytics

### 1. Error Tracking (Sentry)

Install:
```bash
npm install @sentry/react @sentry/tracing
```

Configure in `src/main.tsx`:
```typescript
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: "your-sentry-dsn",
  environment: "production",
  tracesSampleRate: 1.0,
});
```

### 2. Analytics (Google Analytics)

Add to `index.html`:
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### 3. Performance Monitoring

Use browser Performance API or integrate services like:
- New Relic
- Datadog
- AppDynamics

## Scaling Considerations

### Frontend Scaling
- Use CDN for static assets
- Enable gzip/brotli compression
- Implement code splitting
- Lazy load components
- Cache API responses

### WebSocket Scaling
- Use Redis for pub/sub between servers
- Implement sticky sessions
- Consider Socket.io adapter for scaling
- Use load balancer with WebSocket support

### Database (if added)
- Use connection pooling
- Implement caching (Redis)
- Set up read replicas
- Regular backups

## Maintenance

### Regular Updates
```bash
npm update
npm audit fix
```

### Monitoring Checklist
- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Review security alerts
- [ ] Monitor WebSocket connections
- [ ] Check OAuth token refresh rates
- [ ] Review application logs

### Backup Strategy
- Regular database backups
- Configuration backups
- SSL certificate renewal reminders

## Troubleshooting

### Issue: PWA not updating
**Solution:** Increment version in `package.json`, rebuild, and deploy

### Issue: WebSocket disconnects frequently
**Solution:** Check timeout settings, implement reconnection logic, verify load balancer configuration

### Issue: OAuth errors in production
**Solution:** Verify redirect URIs match exactly, check CORS settings, ensure HTTPS

## Conclusion

This configuration guide covers the essential steps for production deployment. Always test thoroughly in a staging environment before deploying to production.

For security best practices and additional configuration options, refer to the official documentation of each service you're using.
