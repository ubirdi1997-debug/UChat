/**
 * OAuth 2.0 / OIDC authentication utilities
 */

export interface AuthConfig {
  clientId: string;
  authorizationEndpoint: string;
  tokenEndpoint: string;
  redirectUri: string;
  scope: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken?: string;
  idToken?: string;
  expiresIn: number;
  tokenType: string;
}

export interface UserProfile {
  id: string;
  email: string;
  name: string;
  picture?: string;
}

export class AuthService {
  private config: AuthConfig;
  private tokens: AuthTokens | null = null;
  private profile: UserProfile | null = null;

  constructor(config: AuthConfig) {
    this.config = config;
    this.loadTokensFromStorage();
  }

  /**
   * Initiate OAuth 2.0 authorization code flow
   */
  async login(): Promise<void> {
    const state = this.generateRandomString(32);
    const codeVerifier = this.generateRandomString(128);
    const codeChallenge = await this.generateCodeChallenge(codeVerifier);

    // Store state and code verifier for later verification
    sessionStorage.setItem('oauth_state', state);
    sessionStorage.setItem('oauth_code_verifier', codeVerifier);

    const params = new URLSearchParams({
      client_id: this.config.clientId,
      redirect_uri: this.config.redirectUri,
      response_type: 'code',
      scope: this.config.scope,
      state: state,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256',
    });

    window.location.href = `${this.config.authorizationEndpoint}?${params.toString()}`;
  }

  /**
   * Handle OAuth callback and exchange code for tokens
   */
  async handleCallback(): Promise<boolean> {
    const params = new URLSearchParams(window.location.search);
    const code = params.get('code');
    const state = params.get('state');
    const storedState = sessionStorage.getItem('oauth_state');
    const codeVerifier = sessionStorage.getItem('oauth_code_verifier');

    if (!code || !state || state !== storedState || !codeVerifier) {
      console.error('Invalid OAuth callback');
      return false;
    }

    try {
      await this.exchangeCodeForTokens(code, codeVerifier);
      sessionStorage.removeItem('oauth_state');
      sessionStorage.removeItem('oauth_code_verifier');
      return true;
    } catch (error) {
      console.error('Token exchange failed:', error);
      return false;
    }
  }

  /**
   * Exchange authorization code for access tokens
   */
  private async exchangeCodeForTokens(code: string, codeVerifier: string): Promise<void> {
    const params = new URLSearchParams({
      client_id: this.config.clientId,
      code: code,
      code_verifier: codeVerifier,
      grant_type: 'authorization_code',
      redirect_uri: this.config.redirectUri,
    });

    const response = await fetch(this.config.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params.toString(),
    });

    if (!response.ok) {
      throw new Error('Token exchange failed');
    }

    const data = await response.json();
    this.tokens = {
      accessToken: data.access_token,
      refreshToken: data.refresh_token,
      idToken: data.id_token,
      expiresIn: data.expires_in,
      tokenType: data.token_type,
    };

    this.saveTokensToStorage();
    await this.loadUserProfile();
  }

  /**
   * Logout and clear tokens
   */
  logout(): void {
    this.tokens = null;
    this.profile = null;
    localStorage.removeItem('auth_tokens');
    localStorage.removeItem('user_profile');
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated(): boolean {
    return this.tokens !== null && !this.isTokenExpired();
  }

  /**
   * Get current access token
   */
  getAccessToken(): string | null {
    return this.tokens?.accessToken || null;
  }

  /**
   * Get user profile
   */
  getUserProfile(): UserProfile | null {
    return this.profile;
  }

  /**
   * Load user profile from ID token or userinfo endpoint
   */
  private async loadUserProfile(): Promise<void> {
    if (this.tokens?.idToken) {
      // Decode JWT ID token (simplified, in production use a proper JWT library)
      const payload = this.tokens.idToken.split('.')[1];
      const decoded = JSON.parse(atob(payload));
      this.profile = {
        id: decoded.sub,
        email: decoded.email,
        name: decoded.name,
        picture: decoded.picture,
      };
      localStorage.setItem('user_profile', JSON.stringify(this.profile));
    }
  }

  /**
   * Check if access token is expired
   */
  private isTokenExpired(): boolean {
    // In production, implement proper token expiration check
    return false;
  }

  /**
   * Save tokens to local storage
   */
  private saveTokensToStorage(): void {
    if (this.tokens) {
      localStorage.setItem('auth_tokens', JSON.stringify(this.tokens));
    }
  }

  /**
   * Load tokens from local storage
   */
  private loadTokensFromStorage(): void {
    const stored = localStorage.getItem('auth_tokens');
    if (stored) {
      this.tokens = JSON.parse(stored);
    }
    const storedProfile = localStorage.getItem('user_profile');
    if (storedProfile) {
      this.profile = JSON.parse(storedProfile);
    }
  }

  /**
   * Generate random string for OAuth state and code verifier
   */
  private generateRandomString(length: number): string {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    const values = new Uint8Array(length);
    window.crypto.getRandomValues(values);
    return Array.from(values)
      .map(v => charset[v % charset.length])
      .join('');
  }

  /**
   * Generate PKCE code challenge
   */
  private async generateCodeChallenge(verifier: string): Promise<string> {
    const encoder = new TextEncoder();
    const data = encoder.encode(verifier);
    const hash = await window.crypto.subtle.digest('SHA-256', data);
    return btoa(String.fromCharCode(...new Uint8Array(hash)))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  }
}

// Demo configuration - in production, load from environment variables
export const authConfig: AuthConfig = {
  clientId: 'uchat-demo-client',
  authorizationEndpoint: 'https://demo-auth-server/oauth/authorize',
  tokenEndpoint: 'https://demo-auth-server/oauth/token',
  redirectUri: window.location.origin + '/callback',
  scope: 'openid profile email',
};

export const authService = new AuthService(authConfig);
