import Database from 'better-sqlite3';

export interface SearchResult {
  id: number;
  sessionId: number;
  category: string;
  summary: string;
  detail: string;
  tags: string[];
  rank: number;
}

export interface MemorySearch {
  search(query: string, limit?: number): SearchResult[];
  searchByCategory(category: string): SearchResult[];
  searchByTag(tag: string): SearchResult[];
}

interface SearchRow {
  id: number;
  session_id: number;
  category: string;
  summary: string;
  detail: string;
  tags: string;
  rank: number;
}

function parseTags(raw: string): string[] {
  try {
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

function mapSearchRow(row: SearchRow): SearchResult {
  return {
    id: row.id,
    sessionId: row.session_id,
    category: row.category,
    summary: row.summary,
    detail: row.detail,
    tags: parseTags(row.tags),
    rank: row.rank,
  };
}

export function createMemorySearch(dbPath: string): MemorySearch {
  const db = new Database(dbPath, { readonly: true });

  const ftsSearch = db.prepare(`
    SELECT l.id, l.session_id, l.category, l.summary, l.detail, l.tags, fts.rank
    FROM learnings_fts fts
    JOIN learnings l ON l.id = fts.rowid
    WHERE learnings_fts MATCH ?
    ORDER BY rank
    LIMIT ?
  `);

  const categorySearch = db.prepare(`
    SELECT id, session_id, category, summary, detail, tags, 0 AS rank
    FROM learnings
    WHERE category = ?
    ORDER BY created_at DESC
  `);

  const tagSearch = db.prepare(`
    SELECT id, session_id, category, summary, detail, tags, 0 AS rank
    FROM learnings
    WHERE tags LIKE ?
    ORDER BY created_at DESC
  `);

  return {
    search(query: string, limit = 20): SearchResult[] {
      const rows = ftsSearch.all(query, limit) as SearchRow[];
      return rows.map(mapSearchRow);
    },

    searchByCategory(category: string): SearchResult[] {
      const rows = categorySearch.all(category) as SearchRow[];
      return rows.map(mapSearchRow);
    },

    searchByTag(tag: string): SearchResult[] {
      const pattern = `%"${tag}"%`;
      const rows = tagSearch.all(pattern) as SearchRow[];
      return rows.map(mapSearchRow);
    },
  };
}
