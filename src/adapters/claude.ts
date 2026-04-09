import { execSync, exec } from 'child_process';
import fs from 'fs';
import path from 'path';
import type { VendorAdapter, SendOptions } from './base.js';

export class ClaudeAdapter implements VendorAdapter {
  name = 'claude' as const;

  detect(projectPath: string): boolean {
    const resolved = path.resolve(projectPath);
    return (
      fs.existsSync(path.join(resolved, '.claude')) &&
      fs.existsSync(path.join(resolved, 'CLAUDE.md'))
    );
  }

  isInstalled(): boolean {
    try {
      execSync('claude --version', { stdio: 'pipe' });
      return true;
    } catch {
      return false;
    }
  }

  getVersion(): string | null {
    try {
      return execSync('claude --version', {
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
      const timeout = options?.timeout ?? 300_000; // 5 min default

      const escaped = prompt.replace(/"/g, '\\"');
      exec(
        `claude --print "${escaped}"`,
        { cwd, timeout, maxBuffer: 10 * 1024 * 1024 },
        (error, stdout, _stderr) => {
          if (error) {
            reject(new Error(`Claude CLI error: ${error.message}`));
          } else {
            resolve(stdout);
          }
        },
      );
    });
  }
}
