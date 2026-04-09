import fs from 'fs';
import path from 'path';

export const ARTEFACT_CHAIN = [
  'runtime-manifest',
  'assumptions',
  'intake',
  'inventory',
  'evidence-register',
  'research-notes',
  'analysis-findings',
  'target-state',
  'execution-roadmap',
  'validation-plan',
  'pack-gap-register',
  'manager-verdict',
] as const;

export type ArtefactName = (typeof ARTEFACT_CHAIN)[number];

export interface ArtefactStatus {
  name: ArtefactName;
  exists: boolean;
  isEmpty: boolean;
  path: string;
}

/**
 * Build the file path for a given artefact within the output directory.
 */
function artefactPath(outputDir: string, name: ArtefactName): string {
  return path.join(outputDir, `${name}.md`);
}

/**
 * Determine whether a markdown file is "empty" -- i.e. contains only
 * template headers and placeholder dashes with no real content.
 */
function isTemplateOnly(content: string): boolean {
  const lines = content.split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed === '') continue;
    if (trimmed.startsWith('#')) continue;
    if (trimmed === '-') continue;
    if (trimmed === '---') continue;
    // Line has actual content
    return false;
  }
  return true;
}

/**
 * Get the status of every artefact in the chain.
 *
 * For each artefact the function checks whether the corresponding `.md`
 * file exists in `outputDir` and whether it contains real content beyond
 * template scaffolding.
 */
export function getArtefactStatuses(outputDir: string): ArtefactStatus[] {
  return ARTEFACT_CHAIN.map((name) => {
    const filePath = artefactPath(outputDir, name);
    let exists = false;
    let isEmpty = true;

    if (fs.existsSync(filePath)) {
      exists = true;
      try {
        const content = fs.readFileSync(filePath, 'utf-8');
        isEmpty = isTemplateOnly(content);
      } catch {
        isEmpty = true;
      }
    }

    return { name, exists, isEmpty, path: filePath };
  });
}

/**
 * Parse raw vendor CLI output into artefact sections.
 *
 * The parser splits on lines that start with `# ` followed by one of the
 * known artefact names (case-insensitive, with spaces or dashes).  Everything
 * between two such headers belongs to the preceding artefact.
 */
export function parseArtefacts(
  rawOutput: string,
): Map<ArtefactName, string> {
  const result = new Map<ArtefactName, string>();

  // Build a lookup that maps normalised names to ArtefactName values.
  const nameNormalised = new Map<string, ArtefactName>();
  for (const name of ARTEFACT_CHAIN) {
    // "runtime-manifest" → "runtimemanifest" and "runtime manifest"
    nameNormalised.set(name.replace(/-/g, ''), name);
    nameNormalised.set(name.replace(/-/g, ' '), name);
    nameNormalised.set(name, name);
  }

  const lines = rawOutput.split('\n');
  let currentArtefact: ArtefactName | null = null;
  let buffer: string[] = [];

  const flush = (): void => {
    if (currentArtefact !== null) {
      const content = buffer.join('\n').trim();
      if (content.length > 0) {
        result.set(currentArtefact, content);
      }
    }
    buffer = [];
  };

  for (const line of lines) {
    // Check for `# ArtefactName` header
    const headerMatch = line.match(/^#\s+(.+)$/);
    if (headerMatch) {
      const headerText = headerMatch[1].trim().toLowerCase().replace(/-/g, '');
      const headerTextDash = headerMatch[1]
        .trim()
        .toLowerCase()
        .replace(/\s+/g, '-');
      const headerTextSpace = headerMatch[1]
        .trim()
        .toLowerCase()
        .replace(/-/g, ' ');

      const matched =
        nameNormalised.get(headerText) ??
        nameNormalised.get(headerTextDash) ??
        nameNormalised.get(headerTextSpace);

      if (matched) {
        flush();
        currentArtefact = matched;
        continue;
      }
    }
    buffer.push(line);
  }

  // Flush last section
  flush();

  return result;
}

/**
 * Write artefact content to a markdown file.
 *
 * Creates the output directory if it does not exist.
 */
export function writeArtefact(
  outputDir: string,
  name: ArtefactName,
  content: string,
): void {
  fs.mkdirSync(outputDir, { recursive: true });
  const filePath = artefactPath(outputDir, name);
  fs.writeFileSync(filePath, content, 'utf-8');
}

/**
 * Read artefact content from file.
 *
 * Returns `null` if the file does not exist.
 */
export function readArtefact(
  outputDir: string,
  name: ArtefactName,
): string | null {
  const filePath = artefactPath(outputDir, name);
  if (!fs.existsSync(filePath)) {
    return null;
  }
  try {
    return fs.readFileSync(filePath, 'utf-8');
  } catch {
    return null;
  }
}
