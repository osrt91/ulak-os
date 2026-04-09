export interface Learning {
  category: 'decision' | 'risk' | 'architecture' | 'bug' | 'pattern';
  summary: string;
  detail: string;
  tags: string[];
}

/**
 * Words that signal a specific learning category.
 */
const CATEGORY_SIGNALS: ReadonlyArray<{
  keywords: readonly string[];
  category: Learning['category'];
}> = [
  { keywords: ['risk', 'threat', 'vulnerability', 'tehdit'], category: 'risk' },
  {
    keywords: ['decision', 'karar', 'chose', 'decided', 'seçim'],
    category: 'decision',
  },
  {
    keywords: ['architecture', 'mimari', 'structure', 'yapı', 'layer', 'katman'],
    category: 'architecture',
  },
  {
    keywords: ['bug', 'hata', 'fix', 'error', 'crash', 'exception', 'düzeltme'],
    category: 'bug',
  },
];

/**
 * Common noise words to exclude from tag extraction.
 */
const STOP_WORDS = new Set([
  'the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been',
  'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
  'would', 'could', 'should', 'may', 'might', 'shall', 'can',
  'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from',
  'as', 'into', 'through', 'during', 'before', 'after', 'above',
  'below', 'between', 'and', 'but', 'or', 'not', 'no', 'nor',
  'so', 'if', 'then', 'than', 'too', 'very', 'just', 'about',
  'up', 'out', 'that', 'this', 'it', 'its', 'all', 'each',
  'every', 'both', 'few', 'more', 'most', 'other', 'some', 'such',
  'only', 'own', 'same', 'also', 'how', 'which', 'when', 'where',
  'who', 'whom', 'what', 'why', 've', 'bir', 'bu', 'ile', 'için',
  'da', 'de', 'den', 'dan', 'olarak',
]);

/**
 * Determine whether a line looks like a meaningful content line
 * (as opposed to a blank line, a pure header, or a separator).
 */
function isSignificantLine(line: string): boolean {
  const trimmed = line.trim();
  if (trimmed === '') return false;
  if (trimmed === '-' || trimmed === '---') return false;
  if (/^#+\s*$/.test(trimmed)) return false;
  // Must have at least a few non-whitespace characters
  return trimmed.length >= 8;
}

/**
 * Detect the category of a line based on keyword signals.
 */
function detectCategory(line: string): Learning['category'] {
  const lower = line.toLowerCase();

  // Check structured prefixes first (e.g., "- **Risk" or "| Risk")
  if (/^[-|]\s*\*?\*?risk/i.test(lower) || /\|\s*risk/i.test(lower)) {
    return 'risk';
  }
  if (
    /^[-|]\s*\*?\*?decision/i.test(lower) ||
    /\|\s*karar/i.test(lower) ||
    /^[-|]\s*\*?\*?karar/i.test(lower)
  ) {
    return 'decision';
  }

  // Fall back to keyword scanning
  for (const { keywords, category } of CATEGORY_SIGNALS) {
    if (keywords.some((kw) => lower.includes(kw))) {
      return category;
    }
  }

  return 'pattern';
}

/**
 * Extract tags from a line by picking meaningful words.
 */
function extractTags(line: string): string[] {
  const words = line
    .replace(/[*|#`\-_>[\](){}:;,."'!?]/g, ' ')
    .split(/\s+/)
    .map((w) => w.toLowerCase().trim())
    .filter((w) => w.length > 2 && !STOP_WORDS.has(w));

  // De-duplicate and limit to a reasonable number
  return [...new Set(words)].slice(0, 8);
}

/**
 * Build a short summary from a line by stripping markdown formatting
 * and truncating to a reasonable length.
 */
function summarise(line: string): string {
  const cleaned = line
    .replace(/^[-|*#>\s]+/, '')
    .replace(/\*\*/g, '')
    .replace(/\|/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  if (cleaned.length <= 120) return cleaned;
  return cleaned.slice(0, 117) + '...';
}

/**
 * Extract structured learnings from artefact content.
 *
 * This is a heuristic extractor: it scans each line for category signals,
 * builds a summary, extracts keyword tags, and returns a `Learning` for
 * every significant line.
 *
 * @param artefactName - The artefact the content belongs to (used for context tagging).
 * @param content      - The raw markdown content of the artefact.
 */
export function extractLearnings(
  artefactName: string,
  content: string,
): Learning[] {
  const learnings: Learning[] = [];
  const lines = content.split('\n');

  for (const line of lines) {
    if (!isSignificantLine(line)) continue;

    const category = detectCategory(line);
    const summary = summarise(line);
    const tags = extractTags(line);

    // Add the artefact name as a contextual tag if not already present
    const normArtefact = artefactName.toLowerCase().replace(/-/g, '');
    if (!tags.some((t) => t.replace(/-/g, '') === normArtefact)) {
      tags.push(artefactName);
    }

    learnings.push({
      category,
      summary,
      detail: line.trim(),
      tags,
    });
  }

  return learnings;
}
