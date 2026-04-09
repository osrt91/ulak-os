import { execSync, exec } from 'child_process';
import fs from 'fs';
import path from 'path';
import type { VendorAdapter, SendOptions } from './base.js';

export class GeminiAdapter implements VendorAdapter {
  name = 'gemini' as const;

  detect(projectPath: string): boolean {
    const resolved = path.resolve(projectPath);
    return fs.existsSync(path.join(resolved, '.gemini'));
  }

  isInstalled(): boolean {
    try {
      execSync('gemini --version', { stdio: 'pipe' });
      return true;
    } catch {
      return false;
    }
  }

  getVersion(): string | null {
    try {
      return execSync('gemini --version', {
        stdio: 'pipe',
        encoding: 'utf-8',
      }).trim();
    } catch {
      return null;
    }
  }

  async sendPrompt(prompt: string, options?: SendOptions): Promise<string> {
    return new Promise((resolve, reject) => {
      const cwd = options?.cwd ?? process.cwd();
      const timeout = options?.timeout ?? 300_000;

      const escaped = prompt.replace(/"/g, '\\"');
      exec(
        `gemini --print "${escaped}"`,
        { cwd, timeout, maxBuffer: 10 * 1024 * 1024 },
        (error, stdout, _stderr) => {
          if (error) {
            reject(new Error(`Gemini CLI error: ${error.message}`));
          } else {
            resolve(stdout);
          }
        },
      );
    });
  }
}
