import fs from 'fs';
import path from 'path';
import { ClaudeAdapter } from './claude.js';
import { CodexAdapter } from './codex.js';
import { GeminiAdapter } from './gemini.js';

export interface SendOptions {
  cwd?: string;
  timeout?: number;
}

export interface VendorAdapter {
  name: string;
  detect(projectPath: string): boolean;
  sendPrompt(prompt: string, options?: SendOptions): Promise<string>;
  isInstalled(): boolean;
  getVersion(): string | null;
}

/**
 * Return all known vendor adapters.
 */
export function getAdapters(): VendorAdapter[] {
  return [new ClaudeAdapter(), new CodexAdapter(), new GeminiAdapter()];
}

/**
 * Detect which vendor adapter to use.
 *
 * Priority:
 *  1. Explicit configVendor override
 *  2. `.claude/` + `CLAUDE.md`   -> claude
 *  3. `AGENTS.md` + `.github/copilot-instructions.md` -> codex
 *  4. `.gemini/` dir             -> gemini
 *  5. null
 */
export function detectVendor(
  projectPath: string,
  configVendor?: string,
): VendorAdapter | null {
  const adapters = getAdapters();

  // 1. Explicit config override
  if (configVendor) {
    const match = adapters.find(
      (a) => a.name === configVendor.toLowerCase(),
    );
    if (match) return match;
  }

  // 2-4. Auto-detect by project markers (ordered)
  const resolvedPath = path.resolve(projectPath);

  // Claude markers
  if (
    fs.existsSync(path.join(resolvedPath, '.claude')) &&
    fs.existsSync(path.join(resolvedPath, 'CLAUDE.md'))
  ) {
    return adapters.find((a) => a.name === 'claude') ?? null;
  }

  // Codex / Copilot markers
  if (
    fs.existsSync(path.join(resolvedPath, 'AGENTS.md')) &&
    fs.existsSync(
      path.join(resolvedPath, '.github', 'copilot-instructions.md'),
    )
  ) {
    return adapters.find((a) => a.name === 'codex') ?? null;
  }

  // Gemini markers
  if (fs.existsSync(path.join(resolvedPath, '.gemini'))) {
    return adapters.find((a) => a.name === 'gemini') ?? null;
  }

  return null;
}
