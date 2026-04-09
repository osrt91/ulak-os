import { execSync, exec } from 'child_process';
import fs from 'fs';
import path from 'path';
import type { VendorAdapter, SendOptions } from './base.js';

export class CodexAdapter implements VendorAdapter {
  name = 'codex' as const;

  detect(projectPath: string): boolean {
    const resolved = path.resolve(projectPath);
    return (
      fs.existsSync(path.join(resolved, 'AGENTS.md')) &&
      fs.existsSync(
        path.join(resolved, '.github', 'copilot-instructions.md'),
      )
    );
  }

  isInstalled(): boolean {
    // Try codex first, then copilot
    try {
      execSync('codex --version', { stdio: 'pipe' });
      return true;
    } catch {
      try {
        execSync('copilot --version', { stdio: 'pipe' });
        return true;
      } catch {
        return false;
      }
    }
  }

  getVersion(): string | null {
    try {
      return execSync('codex --version', {
        stdio: 'pipe',
        encoding: 'utf-8',
      }).trim();
    } catch {
      try {
        return execSync('copilot --version', {
          stdio: 'pipe',
          encoding: 'utf-8',
        }).trim();
      } catch {
        return null;
      }
    }
  }

  /**
   * Resolve the available CLI binary name.
   * Prefers `codex` over `copilot`.
   */
  private resolveBinary(): string {
    try {
      execSync('codex --version', { stdio: 'pipe' });
      return 'codex';
    } catch {
      return 'copilot';
    }
  }

  async sendPrompt(prompt: string, options?: SendOptions): Promise<string> {
    return new Promise((resolve, reject) => {
      const cwd = options?.cwd ?? process.cwd();
      const timeout = options?.timeout ?? 300_000;
      const bin = this.resolveBinary();

      const escaped = prompt.replace(/"/g, '\\"');
      exec(
        `${bin} --print "${escaped}"`,
        { cwd, timeout, maxBuffer: 10 * 1024 * 1024 },
        (error, stdout, _stderr) => {
          if (error) {
            reject(new Error(`Codex/Copilot CLI error: ${error.message}`));
          } else {
            resolve(stdout);
          }
        },
      );
    });
  }
}
