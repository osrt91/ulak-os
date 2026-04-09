import Database from 'better-sqlite3';

export interface Session {
  id: number;
  project: string;
  vendor: string;
  command: string;
  startedAt: Date;
  finishedAt: Date | null;
}

export interface SessionManager {
  start(project: string, vendor: string, command: string): Session;
  finish(sessionId: number): void;
  getAll(): Session[];
  getLast(): Session | null;
}

/**
 * Map a raw database row to a Session object.
 */
function rowToSession(row: Record<string, unknown>): Session {
  return {
    id: row['id'] as number,
    project: row['project'] as string,
    vendor: row['vendor'] as string,
    command: row['command'] as string,
    startedAt: new Date(row['started_at'] as string),
    finishedAt: row['finished_at']
      ? new Date(row['finished_at'] as string)
      : null,
  };
}

/**
 * Create a SessionManager backed by a better-sqlite3 database.
 *
 * The sessions table is automatically created if it does not exist.
 */
export function createSessionManager(dbPath: string): SessionManager {
  const db = new Database(dbPath);

  // Enable WAL mode for better concurrent read performance
  db.pragma('journal_mode = WAL');

  // Create the sessions table if it does not exist
  db.exec(`
    CREATE TABLE IF NOT EXISTS sessions (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      project     TEXT    NOT NULL,
      vendor      TEXT    NOT NULL,
      command     TEXT    NOT NULL,
      started_at  TEXT    NOT NULL,
      finished_at TEXT
    )
  `);

  const insertStmt = db.prepare(`
    INSERT INTO sessions (project, vendor, command, started_at)
    VALUES (@project, @vendor, @command, @startedAt)
  `);

  const updateFinishStmt = db.prepare(`
    UPDATE sessions SET finished_at = @finishedAt WHERE id = @id
  `);

  const selectAllStmt = db.prepare(`
    SELECT id, project, vendor, command, started_at, finished_at
    FROM sessions
    ORDER BY id ASC
  `);

  const selectLastStmt = db.prepare(`
    SELECT id, project, vendor, command, started_at, finished_at
    FROM sessions
    ORDER BY id DESC
    LIMIT 1
  `);

  return {
    start(project: string, vendor: string, command: string): Session {
      const startedAt = new Date().toISOString();
      const result = insertStmt.run({
        project,
        vendor,
        command,
        startedAt,
      });

      return {
        id: Number(result.lastInsertRowid),
        project,
        vendor,
        command,
        startedAt: new Date(startedAt),
        finishedAt: null,
      };
    },

    finish(sessionId: number): void {
      const finishedAt = new Date().toISOString();
      updateFinishStmt.run({ id: sessionId, finishedAt });
    },

    getAll(): Session[] {
      const rows = selectAllStmt.all() as Record<string, unknown>[];
      return rows.map(rowToSession);
    },

    getLast(): Session | null {
      const row = selectLastStmt.get() as Record<string, unknown> | undefined;
      if (!row) return null;
      return rowToSession(row);
    },
  };
}
