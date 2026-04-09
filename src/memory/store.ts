import Database from 'better-sqlite3';
import crypto from 'crypto';

const MIGRATION_SQL = `
CREATE TABLE IF NOT EXISTS sessions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  project     TEXT NOT NULL,
  vendor      TEXT NOT NULL,
  command     TEXT NOT NULL,
  started_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  finished_at DATETIME
);

CREATE TABLE IF NOT EXISTS artefacts (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id  INTEGER REFERENCES sessions(id),
  name        TEXT NOT NULL,
  content     TEXT,
  hash        TEXT,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS learnings (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id  INTEGER REFERENCES sessions(id),
  category    TEXT,
  summary     TEXT NOT NULL,
  detail      TEXT,
  tags        TEXT,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE VIRTUAL TABLE IF NOT EXISTS learnings_fts USING fts5(
  summary, detail, tags,
  content='learnings', content_rowid='id'
);

CREATE TRIGGER IF NOT EXISTS learnings_ai AFTER INSERT ON learnings BEGIN
  INSERT INTO learnings_fts(rowid, summary, detail, tags)
  VALUES (new.id, new.summary, new.detail, new.tags);
END;

CREATE TRIGGER IF NOT EXISTS learnings_ad AFTER DELETE ON learnings BEGIN
  INSERT INTO learnings_fts(learnings_fts, rowid, summary, detail, tags)
  VALUES ('delete', old.id, old.summary, old.detail, old.tags);
END;
`;

export interface StoredArtefact {
  id: number;
  sessionId: number;
  name: string;
  content: string;
  hash: string;
  createdAt: string;
}

export interface StoredLearning {
  id: number;
  sessionId: number;
  category: string;
  summary: string;
  detail: string;
  tags: string[];
  createdAt: string;
}

export interface MemoryStore {
  saveArtefact(sessionId: number, name: string, content: string): void;
  getArtefacts(sessionId?: number): StoredArtefact[];
  saveLearning(
    sessionId: number,
    category: string,
    summary: string,
    detail: string,
    tags: string[],
  ): void;
  getLearnings(sessionId?: number): StoredLearning[];
  close(): void;
}

interface ArtefactRow {
  id: number;
  session_id: number;
  name: string;
  content: string;
  hash: string;
  created_at: string;
}

interface LearningRow {
  id: number;
  session_id: number;
  category: string;
  summary: string;
  detail: string;
  tags: string;
  created_at: string;
}

function mapArtefactRow(row: ArtefactRow): StoredArtefact {
  return {
    id: row.id,
    sessionId: row.session_id,
    name: row.name,
    content: row.content,
    hash: row.hash,
    createdAt: row.created_at,
  };
}

function mapLearningRow(row: LearningRow): StoredLearning {
  let tags: string[] = [];
  try {
    tags = JSON.parse(row.tags);
  } catch {
    tags = [];
  }
  return {
    id: row.id,
    sessionId: row.session_id,
    category: row.category,
    summary: row.summary,
    detail: row.detail,
    tags,
    createdAt: row.created_at,
  };
}

export function createMemoryStore(dbPath: string): MemoryStore {
  const db = new Database(dbPath);

  // Enable WAL mode for better concurrent read performance
  db.pragma('journal_mode = WAL');

  // Run migration
  db.exec(MIGRATION_SQL);

  // Prepared statements
  const insertArtefact = db.prepare(
    `INSERT INTO artefacts (session_id, name, content, hash) VALUES (?, ?, ?, ?)`,
  );

  const selectArtefactsBySession = db.prepare(
    `SELECT id, session_id, name, content, hash, created_at FROM artefacts WHERE session_id = ? ORDER BY created_at ASC`,
  );

  const selectAllArtefacts = db.prepare(
    `SELECT id, session_id, name, content, hash, created_at FROM artefacts ORDER BY created_at ASC`,
  );

  const insertLearning = db.prepare(
    `INSERT INTO learnings (session_id, category, summary, detail, tags) VALUES (?, ?, ?, ?, ?)`,
  );

  const selectLearningsBySession = db.prepare(
    `SELECT id, session_id, category, summary, detail, tags, created_at FROM learnings WHERE session_id = ? ORDER BY created_at ASC`,
  );

  const selectAllLearnings = db.prepare(
    `SELECT id, session_id, category, summary, detail, tags, created_at FROM learnings ORDER BY created_at ASC`,
  );

  return {
    saveArtefact(sessionId: number, name: string, content: string): void {
      const hash = crypto.createHash('sha256').update(content).digest('hex');
      insertArtefact.run(sessionId, name, content, hash);
    },

    getArtefacts(sessionId?: number): StoredArtefact[] {
      const rows =
        sessionId !== undefined
          ? (selectArtefactsBySession.all(sessionId) as ArtefactRow[])
          : (selectAllArtefacts.all() as ArtefactRow[]);
      return rows.map(mapArtefactRow);
    },

    saveLearning(
      sessionId: number,
      category: string,
      summary: string,
      detail: string,
      tags: string[],
    ): void {
      const tagsJSON = JSON.stringify(tags);
      insertLearning.run(sessionId, category, summary, detail, tagsJSON);
    },

    getLearnings(sessionId?: number): StoredLearning[] {
      const rows =
        sessionId !== undefined
          ? (selectLearningsBySession.all(sessionId) as LearningRow[])
          : (selectAllLearnings.all() as LearningRow[]);
      return rows.map(mapLearningRow);
    },

    close(): void {
      db.close();
    },
  };
}
