# Testing Guide for UChat

This document provides instructions for testing the UChat application in various modes.

## Quick Start Testing

### 1. Development Mode

Start the development server:
```bash
npm install
npm run dev
```

Open your browser to `http://localhost:3000`

**What to test:**
- Application loads without errors
- Demo user is automatically logged in
- UI is responsive and displays correctly
- Navigation works properly

### 2. Chat Functionality

1. Select a room from the sidebar (General, Random, or Tech Talk)
2. Type a message in the input field
3. Press Enter or click the send button
4. Observe:
   - Your message appears in the chat window
   - A demo response appears after 1-3 seconds
   - Messages are properly formatted with timestamps
   - Connection status shows "Connected" (green)

### 3. PWA Features

#### Service Worker Registration
Check browser console for:
```
ServiceWorker registration successful
```

#### Offline Testing
1. Build the application: `npm run build`
2. Preview: `npm run preview`
3. Open DevTools → Application → Service Workers
4. Check "Offline" mode
5. Reload the page
6. Application should still load (cached)

#### PWA Installation
1. Open in Chrome/Edge
2. Look for install icon in address bar
3. Click to install
4. App launches as standalone

### 4. Authentication Flow

**Demo Mode (Default):**
- User is automatically authenticated with demo credentials
- No OAuth server required
- Can test logout/re-login flow

**Production Mode:**
To test real OAuth:
1. Configure OAuth provider in `src/utils/auth.ts`
2. Update `authConfig` with real endpoints
3. Click "Login with OAuth"
4. Follow OAuth flow
5. Return to app with tokens

### 5. Encryption Testing

The encryption utilities are available but not actively used in demo mode. To test:

```typescript
import { encryptionService } from './src/utils/encryption';

// Generate key pair
await encryptionService.generateKeyPair();

// Export public key
const publicKey = await encryptionService.exportPublicKey();
console.log('Public Key:', publicKey);

// Encrypt a message
const recipientKey = await encryptionService.importPublicKey(publicKey);
const encrypted = await encryptionService.encryptMessage('Hello!', recipientKey);
console.log('Encrypted:', encrypted);

// Decrypt
const decrypted = await encryptionService.decryptMessage(encrypted);
console.log('Decrypted:', decrypted);
```

## UI Testing Checklist

### Responsive Design
- [ ] Works on desktop (1920x1080)
- [ ] Works on tablet (768x1024)
- [ ] Works on mobile (375x667)
- [ ] Sidebar collapses on mobile
- [ ] Messages are readable on all sizes

### Chat Interface
- [ ] Can send messages
- [ ] Can switch rooms
- [ ] Messages display with sender names
- [ ] Timestamps are shown correctly
- [ ] Input field clears after sending
- [ ] Send button disables when input is empty
- [ ] Connection status updates properly

### Navigation
- [ ] Sidebar navigation works
- [ ] Room selection works
- [ ] User menu opens/closes
- [ ] Logout button works
- [ ] Routes work correctly (/, /login, /callback)

### Accessibility
- [ ] Keyboard navigation works
- [ ] Tab order is logical
- [ ] ARIA labels present
- [ ] Color contrast is sufficient
- [ ] Screen reader friendly

## Performance Testing

### Build Size
```bash
npm run build
```

Check `dist/` folder size:
- Total bundle should be < 500KB gzipped
- Service worker files generated
- Manifest present

### Lighthouse Audit

1. Build application: `npm run build`
2. Serve: `npm run preview`
3. Open Chrome DevTools
4. Run Lighthouse audit
5. Check scores:
   - Performance: Should be > 90
   - Accessibility: Should be > 90
   - Best Practices: Should be > 90
   - PWA: Should be 100

### Network Testing

**Throttling:**
1. Open DevTools → Network
2. Set throttling to "Slow 3G"
3. Reload application
4. Verify:
   - App loads within 5 seconds
   - Critical content visible quickly
   - Progressive loading works

**WebSocket Reconnection:**
1. Open DevTools → Network
2. Note "Connected" status
3. Toggle offline
4. Status shows "Disconnected"
5. Toggle back online
6. Auto-reconnects (demo mode simulates this)

## Security Testing

### Content Security Policy
Check headers in production:
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block

### HTTPS Testing
In production:
- [ ] All resources loaded over HTTPS
- [ ] No mixed content warnings
- [ ] WebSocket uses WSS protocol
- [ ] Cookies are secure and httpOnly

### Encryption Verification
Test crypto operations:
```javascript
// In browser console
const { encryptionService } = await import('./src/utils/encryption.ts');
await encryptionService.generateKeyPair();
const key = await encryptionService.exportPublicKey();
console.log('Crypto API works:', !!key);
```

## Browser Compatibility

Test on:
- [ ] Chrome 90+ (Desktop & Mobile)
- [ ] Firefox 88+ (Desktop & Mobile)
- [ ] Safari 14+ (Desktop & iOS)
- [ ] Edge 90+

Check:
- [ ] Service Worker API available
- [ ] Web Crypto API works
- [ ] WebSocket support
- [ ] LocalStorage works
- [ ] SessionStorage works

## Common Issues & Solutions

### Issue: Service Worker not registering
**Solution:** 
- Check browser console for errors
- Ensure running on localhost or HTTPS
- Clear browser cache
- Unregister old service workers

### Issue: WebSocket connection fails
**Solution:**
- Demo mode works without backend
- Check WebSocket server URL in `src/utils/websocket.ts`
- Verify server is running and accessible
- Check CORS configuration

### Issue: OAuth redirect fails
**Solution:**
- Demo mode bypasses OAuth
- Verify redirect URI matches OAuth config
- Check OAuth provider settings
- Ensure client ID is correct

### Issue: Build fails
**Solution:**
- Run `npm install` to ensure dependencies
- Check Node version (18+ required)
- Clear `node_modules` and reinstall
- Check for TypeScript errors: `npm run build`

### Issue: Linting errors
**Solution:**
- Run `npm run lint` to see errors
- Fix reported issues
- Check ESLint configuration
- Ensure TypeScript types are correct

## Automated Testing

While this implementation focuses on manual testing, you can add automated tests:

### Unit Tests (Jest + React Testing Library)
```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom jest
```

### E2E Tests (Playwright)
```bash
npm install --save-dev @playwright/test
```

### Integration Tests
Test key flows:
- Login flow
- Send message flow
- Room switching
- Logout flow

## Production Deployment Testing

Before deploying to production:

1. **Environment Variables**
   - [ ] OAuth credentials configured
   - [ ] WebSocket URL set
   - [ ] API endpoints configured

2. **Build Configuration**
   - [ ] Production build succeeds
   - [ ] No console errors in production
   - [ ] Source maps disabled or secured
   - [ ] Environment-specific configs applied

3. **Monitoring**
   - [ ] Error tracking configured (Sentry, etc.)
   - [ ] Analytics configured
   - [ ] Performance monitoring enabled
   - [ ] Uptime monitoring active

4. **Backup & Recovery**
   - [ ] Database backups configured
   - [ ] Rollback plan ready
   - [ ] Disaster recovery tested

## Performance Benchmarks

Expected performance metrics:

- **First Contentful Paint:** < 1.5s
- **Time to Interactive:** < 3.5s
- **Bundle Size (gzipped):** < 150KB
- **Service Worker Cache:** < 5MB
- **Memory Usage:** < 50MB
- **WebSocket Latency:** < 100ms

## Conclusion

This testing guide covers the essential aspects of testing UChat. For production use, implement comprehensive automated testing and continuous integration/deployment pipelines.

For questions or issues, please refer to the main README.md or open an issue on GitHub.
