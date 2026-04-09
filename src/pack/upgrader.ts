import { loadPack } from './loader.js';

export interface UpgradeResult {
  success: boolean;
  fromVersion: string | null;
  toVersion: string;
  changes: UpgradeChange[];
}

export interface UpgradeChange {
  type: 'added' | 'modified' | 'removed';
  file: string;
}

export interface UpgradeCheckResult {
  available: boolean;
  currentVersion: string | null;
  latestVersion: string | null;
}

/**
 * Check if an upgrade is available.
 *
 * Reads the local pack.json version and compares it against the source.
 * Currently a stub — actual npm/git source checking will be implemented
 * when the package is published to npm.
 */
export async function checkUpgrade(
  projectPath: string,
  _source?: string,
): Promise<UpgradeCheckResult> {
  const manifest = loadPack(projectPath);
  const currentVersion = manifest?.version ?? null;

  // Stub: real implementation will query npm registry or git remote
  return {
    available: false,
    currentVersion,
    latestVersion: currentVersion,
  };
}

/**
 * Perform an upgrade from the specified source.
 *
 * Currently a stub — returns success: false with a descriptive message.
 * The actual upgrade flow (download, diff, apply, validate) will be
 * implemented when the pack distribution pipeline is ready.
 */
export async function upgrade(
  projectPath: string,
  _source?: string,
): Promise<UpgradeResult> {
  const manifest = loadPack(projectPath);

  return {
    success: false,
    fromVersion: manifest?.version ?? null,
    toVersion: manifest?.version ?? '0.0.0',
    changes: [],
  };
}
