import fs from 'fs';
import path from 'path';

export interface PackManifest {
  name: string;
  version: string;
  description: string;
  core: string;
  agents: number;
  commands: number;
  skills: number;
  artefacts: string[];
  compatibility: {
    cli: string;
    vendors: string[];
  };
}

/**
 * Safely read a directory, returning an empty array if it doesn't exist.
 */
function safeReaddir(dirPath: string): string[] {
  try {
    return fs.readdirSync(dirPath);
  } catch {
    return [];
  }
}

/**
 * Collect files with a given extension from a directory (non-recursive).
 */
function collectFiles(dirPath: string, ext: string): string[] {
  return safeReaddir(dirPath)
    .filter((f) => f.endsWith(ext))
    .map((f) => path.join(dirPath, f));
}

/**
 * Collect subdirectory names from a directory.
 */
function collectSubdirs(dirPath: string): string[] {
  return safeReaddir(dirPath).filter((f) => {
    try {
      return fs.statSync(path.join(dirPath, f)).isDirectory();
    } catch {
      return false;
    }
  });
}

/**
 * Load pack.json from prompts directory.
 *
 * Falls back to constructing a manifest from the legacy v1 directory
 * structure when pack.json is not present.
 */
export function loadPack(projectPath: string): PackManifest | null {
  const packJsonPath = path.join(projectPath, 'prompts', 'pack.json');

  // Try pack.json first (v2 structure)
  if (fs.existsSync(packJsonPath)) {
    try {
      const raw = fs.readFileSync(packJsonPath, 'utf-8');
      return JSON.parse(raw) as PackManifest;
    } catch {
      return null;
    }
  }

  // Fallback: construct manifest from legacy v1 directory layout
  const coreDir = path.join(projectPath, 'prompts', 'core');
  if (!fs.existsSync(coreDir)) {
    return null;
  }

  // Detect core contract file
  const coreFiles = safeReaddir(coreDir).filter((f) => f.endsWith('.md'));
  const coreFile = coreFiles.length > 0 ? `core/${coreFiles[0]}` : '';

  // Count agents, commands, skills across both v1 and v2 locations
  const agents = listAgents(projectPath);
  const commands = listCommands(projectPath);
  const skills = listSkills(projectPath);

  // Detect artefact templates
  const artefactsDir = path.join(projectPath, 'prompts', 'artefacts');
  const artefacts = safeReaddir(artefactsDir).filter((f) => f.endsWith('.md'));

  // Try to read version from package.json
  let version = '1.0.0';
  const pkgJsonPath = path.join(projectPath, 'package.json');
  if (fs.existsSync(pkgJsonPath)) {
    try {
      const pkg = JSON.parse(fs.readFileSync(pkgJsonPath, 'utf-8'));
      if (typeof pkg.version === 'string') {
        version = pkg.version;
      }
    } catch {
      // keep default
    }
  }

  return {
    name: path.basename(projectPath),
    version,
    description: 'Auto-detected from legacy v1 directory structure',
    core: coreFile,
    agents: agents.length,
    commands: commands.length,
    skills: skills.length,
    artefacts,
    compatibility: {
      cli: '>=2.0.0',
      vendors: ['claude-code'],
    },
  };
}

/**
 * Get the core contract content from the file specified in the manifest.
 */
export function loadCoreContract(
  projectPath: string,
  manifest: PackManifest,
): string | null {
  if (!manifest.core) {
    return null;
  }

  const contractPath = path.join(projectPath, 'prompts', manifest.core);

  try {
    return fs.readFileSync(contractPath, 'utf-8');
  } catch {
    return null;
  }
}

/**
 * List all agent files in the pack.
 *
 * Searches both v2 (`prompts/agents/`) and v1 (`.claude/agents/`) locations.
 */
export function listAgents(projectPath: string): string[] {
  const v2Dir = path.join(projectPath, 'prompts', 'agents');
  const v1Dir = path.join(projectPath, '.claude', 'agents');

  const v2Files = collectFiles(v2Dir, '.md');
  const v1Files = collectFiles(v1Dir, '.md');

  return [...v2Files, ...v1Files];
}

/**
 * List all command files in the pack.
 *
 * Searches both v2 (`prompts/commands/`) and v1 (`.claude/commands/`) locations.
 */
export function listCommands(projectPath: string): string[] {
  const v2Dir = path.join(projectPath, 'prompts', 'commands');
  const v1Dir = path.join(projectPath, '.claude', 'commands');

  const v2Files = collectFiles(v2Dir, '.md');
  const v1Files = collectFiles(v1Dir, '.md');

  return [...v2Files, ...v1Files];
}

/**
 * List all skill directories in the pack.
 *
 * Searches both v2 (`prompts/skills/`) and v1 (`.claude/skills/`) locations.
 */
export function listSkills(projectPath: string): string[] {
  const v2Dir = path.join(projectPath, 'prompts', 'skills');
  const v1Dir = path.join(projectPath, '.claude', 'skills');

  const v2Dirs = collectSubdirs(v2Dir);
  const v1Dirs = collectSubdirs(v1Dir);

  return [...v2Dirs, ...v1Dirs];
}
