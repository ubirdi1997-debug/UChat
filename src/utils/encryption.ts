/**
 * End-to-end encryption utilities using Web Crypto API
 */

export class EncryptionService {
  private keyPair: CryptoKeyPair | null = null;

  /**
   * Generate a new key pair for encryption
   */
  async generateKeyPair(): Promise<CryptoKeyPair> {
    this.keyPair = await window.crypto.subtle.generateKey(
      {
        name: 'RSA-OAEP',
        modulusLength: 2048,
        publicExponent: new Uint8Array([1, 0, 1]),
        hash: 'SHA-256',
      },
      true,
      ['encrypt', 'decrypt']
    );
    return this.keyPair;
  }

  /**
   * Export public key to share with other users
   */
  async exportPublicKey(publicKey?: CryptoKey): Promise<string> {
    const key = publicKey || this.keyPair?.publicKey;
    if (!key) {
      throw new Error('No public key available');
    }
    const exported = await window.crypto.subtle.exportKey('spki', key);
    return btoa(String.fromCharCode(...new Uint8Array(exported)));
  }

  /**
   * Import a public key from another user
   */
  async importPublicKey(keyStr: string): Promise<CryptoKey> {
    const keyData = Uint8Array.from(atob(keyStr), c => c.charCodeAt(0));
    return await window.crypto.subtle.importKey(
      'spki',
      keyData,
      {
        name: 'RSA-OAEP',
        hash: 'SHA-256',
      },
      true,
      ['encrypt']
    );
  }

  /**
   * Encrypt a message using recipient's public key
   */
  async encryptMessage(message: string, recipientPublicKey: CryptoKey): Promise<string> {
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    const encrypted = await window.crypto.subtle.encrypt(
      {
        name: 'RSA-OAEP',
      },
      recipientPublicKey,
      data
    );
    return btoa(String.fromCharCode(...new Uint8Array(encrypted)));
  }

  /**
   * Decrypt a message using own private key
   */
  async decryptMessage(encryptedMessage: string): Promise<string> {
    if (!this.keyPair?.privateKey) {
      throw new Error('No private key available');
    }
    const encryptedData = Uint8Array.from(atob(encryptedMessage), c => c.charCodeAt(0));
    const decrypted = await window.crypto.subtle.decrypt(
      {
        name: 'RSA-OAEP',
      },
      this.keyPair.privateKey,
      encryptedData
    );
    const decoder = new TextDecoder();
    return decoder.decode(decrypted);
  }

  /**
   * Generate a symmetric key for group chat encryption
   */
  async generateSymmetricKey(): Promise<CryptoKey> {
    return await window.crypto.subtle.generateKey(
      {
        name: 'AES-GCM',
        length: 256,
      },
      true,
      ['encrypt', 'decrypt']
    );
  }

  getKeyPair(): CryptoKeyPair | null {
    return this.keyPair;
  }
}

export const encryptionService = new EncryptionService();
