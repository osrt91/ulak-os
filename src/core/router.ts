import fs from 'fs';
import path from 'path';

export type ProjectState = 'GREENFIELD' | 'BROWNFIELD' | 'HYBRID';
export type InterventionMode =
  | 'CREATE'
  | 'REPAIR'
  | 'EXTEND'
  | 'REFACTOR'
  | 'MIGRATE'
  | 'RESCUE'
  | 'REPACKAGE';

export interface RouteResult {
  state: ProjectState;
  mode: InterventionMode;
  confidence: number;
  reason: string;
}

/**
 * Rule collision priority order (from rule-collision-matrix.md).
 * Higher index = lower priority.
 */
const RULE_PRIORITY: readonly string[] = [
  'security',
  'evidence',
  'reversibility',
  'validation',
  'pack quality',
  'ux',
  'aesthetics',
] as const;

/**
 * Keyword groups that map to intervention modes.
 * First match wins, so order matters only within a single intent string.
 */
const KEYWORD_MAP: ReadonlyArray<{
  keywords: readonly string[];
  mode: InterventionMode;
}> = [
  { keywords: ['fix', 'bug', 'repair', 'düzelt'], mode: 'REPAIR' },
  { keywords: ['rescue', 'kurtar', 'save'], mode: 'RESCUE' },
  { keywords: ['migrate', 'taşı', 'move'], mode: 'MIGRATE' },
  { keywords: ['refactor', 'temizle', 'clean'], mode: 'REFACTOR' },
  { keywords: ['extend', 'ekle', 'add'], mode: 'EXTEND' },
  { keywords: ['package', 'paketle', 'repackage'], mode: 'REPACKAGE' },
  { keywords: ['komple', 'sıfırdan', 'create', 'new'], mode: 'CREATE' },
];

/**
 * Detect project state by inspecting the file system at `projectPath`.
 *
 * - BROWNFIELD: `reports/current/` exists and contains non-empty artefact files.
 * - GREENFIELD: neither `reports/` nor `src/` directories exist.
 * - HYBRID: everything else.
 */
export function detectProjectState(projectPath: string): ProjectState {
  const reportsDir = path.join(projectPath, 'reports');
  const reportsCurrentDir = path.join(projectPath, 'reports', 'current');
  const srcDir = path.join(projectPath, 'src');

  const hasReports = fs.existsSync(reportsDir);
  const hasSrc = fs.existsSync(srcDir);

  // GREENFIELD: no reports/ and no src/
  if (!hasReports && !hasSrc) {
    return 'GREENFIELD';
  }

  // BROWNFIELD: reports/current/ has filled artefacts
  if (fs.existsSync(reportsCurrentDir)) {
    try {
      const files = fs.readdirSync(reportsCurrentDir);
      const hasFilledArtefacts = files.some((file) => {
        if (!file.endsWith('.md')) return false;
        const content = fs.readFileSync(
          path.join(reportsCurrentDir, file),
          'utf-8',
        );
        // A filled artefact has more than just template headers
        const nonHeaderLines = content
          .split('\n')
          .filter(
            (line) =>
              line.trim() !== '' &&
              !line.startsWith('#') &&
              line.trim() !== '-',
          );
        return nonHeaderLines.length > 0;
      });

      if (hasFilledArtefacts) {
        return 'BROWNFIELD';
      }
    } catch {
      // If we can't read the directory, fall through to HYBRID
    }
  }

  return 'HYBRID';
}

/**
 * Route an intent string to an intervention mode given the current project state.
 *
 * The intent is matched against keyword groups. The first matching group
 * determines the mode. If nothing matches the default is CREATE.
 */
export function routeIntent(intent: string, state: ProjectState): RouteResult {
  const normalised = intent.toLowerCase();

  for (const { keywords, mode } of KEYWORD_MAP) {
    const matched = keywords.find((kw) => normalised.includes(kw));
    if (matched) {
      return {
        state,
        mode,
        confidence: 0.9,
        reason: `Keyword "${matched}" matched in intent → ${mode}`,
      };
    }
  }

  // Default fallback
  return {
    state,
    mode: 'CREATE',
    confidence: 0.5,
    reason: 'No keyword matched; defaulting to CREATE',
  };
}

/**
 * Resolve a collision between two rules by returning the higher-priority one.
 *
 * Priority is determined by the order defined in `rule-collision-matrix.md`:
 *   security > evidence > reversibility > validation > pack quality > UX > aesthetics
 *
 * If a rule is not found in the priority list it is treated as lowest priority.
 */
export function resolveCollision(ruleA: string, ruleB: string): string {
  const normA = ruleA.toLowerCase().trim();
  const normB = ruleB.toLowerCase().trim();

  const indexA = RULE_PRIORITY.findIndex((r) => normA.includes(r));
  const indexB = RULE_PRIORITY.findIndex((r) => normB.includes(r));

  // Lower index = higher priority. -1 means not found → treat as lowest.
  const priorityA = indexA === -1 ? RULE_PRIORITY.length : indexA;
  const priorityB = indexB === -1 ? RULE_PRIORITY.length : indexB;

  // If equal priority, prefer ruleA (first argument wins ties).
  return priorityA <= priorityB ? ruleA : ruleB;
}
