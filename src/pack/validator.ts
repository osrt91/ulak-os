import fs from 'fs';
import path from 'path';

export interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

export interface ValidationError {
  file: string;
  line?: number;
  message: string;
}

export interface ValidationWarning {
  file: string;
  message: string;
}

/**
 * Create an empty ValidationResult.
 */
function emptyResult(): ValidationResult {
  return { valid: true, errors: [], warnings: [] };
}

/**
 * Merge multiple ValidationResults into one.
 */
function mergeResults(...results: ValidationResult[]): ValidationResult {
  const merged = emptyResult();
  for (const r of results) {
    merged.errors.push(...r.errors);
    merged.warnings.push(...r.warnings);
  }
  merged.valid = merged.errors.length === 0;
  return merged;
}

/**
 * Recursively collect files matching a predicate under a directory.
 */
function walkFiles(dir: string, predicate: (name: string) => boolean): string[] {
  const results: string[] = [];

  if (!fs.existsSync(dir)) {
    return results;
  }

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      // Skip node_modules and dist
      if (entry.name === 'node_modules' || entry.name === 'dist') continue;
      results.push(...walkFiles(fullPath, predicate));
    } else if (predicate(entry.name)) {
      results.push(fullPath);
    }
  }

  return results;
}

/**
 * Validate all JSON files in .claude/ and .mcp.json parse correctly.
 * Check that .toml files in .gemini/ exist (TOML parsing is optional).
 */
export function validateSchemas(projectPath: string): ValidationResult {
  const result = emptyResult();

  // Validate .claude/ JSON files
  const claudeDir = path.join(projectPath, '.claude');
  const jsonFiles = walkFiles(claudeDir, (name) => name.endsWith('.json'));

  // Also check .mcp.json at project root
  const mcpJsonPath = path.join(projectPath, '.mcp.json');
  if (fs.existsSync(mcpJsonPath)) {
    jsonFiles.push(mcpJsonPath);
  }

  for (const file of jsonFiles) {
    try {
      const raw = fs.readFileSync(file, 'utf-8');
      JSON.parse(raw);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : 'Invalid JSON';
      result.errors.push({ file, message: `JSON parse error: ${message}` });
    }
  }

  // Check .gemini/ TOML files exist
  const geminiDir = path.join(projectPath, '.gemini');
  const tomlFiles = walkFiles(geminiDir, (name) => name.endsWith('.toml'));
  for (const file of tomlFiles) {
    try {
      fs.accessSync(file, fs.constants.R_OK);
    } catch {
      result.warnings.push({
        file,
        message: 'TOML file exists but is not readable',
      });
    }
  }

  if (tomlFiles.length === 0 && fs.existsSync(geminiDir)) {
    result.warnings.push({
      file: geminiDir,
      message: 'No .toml files found in .gemini/ directory',
    });
  }

  result.valid = result.errors.length === 0;
  return result;
}

/**
 * Validate @import chains in markdown files.
 *
 * Reads all .md files in the project, finds lines matching `^@(.+\.md)$`,
 * and checks that the referenced file exists relative to the project root.
 */
export function validateImports(projectPath: string): ValidationResult {
  const result = emptyResult();
  const importPattern = /^@(.+\.md)$/;

  const mdFiles = walkFiles(projectPath, (name) => name.endsWith('.md'));

  for (const file of mdFiles) {
    let content: string;
    try {
      content = fs.readFileSync(file, 'utf-8');
    } catch {
      result.warnings.push({ file, message: 'Could not read file' });
      continue;
    }

    const lines = content.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const match = importPattern.exec(lines[i].trim());
      if (match) {
        const importPath = match[1];
        const resolvedPath = path.join(projectPath, importPath);

        if (!fs.existsSync(resolvedPath)) {
          result.errors.push({
            file,
            line: i + 1,
            message: `Import target not found: @${importPath} (resolved to ${resolvedPath})`,
          });
        }
      }
    }
  }

  result.valid = result.errors.length === 0;
  return result;
}

/**
 * Validate brand consistency.
 *
 * Searches all .md files for "Claude Ulak" (case-sensitive). Each match
 * is reported as an error — the old internal brand name should not appear
 * in the public release.
 */
export function validateBrand(projectPath: string): ValidationResult {
  const result = emptyResult();
  const brandPattern = 'Claude Ulak';

  const mdFiles = walkFiles(projectPath, (name) => name.endsWith('.md'));

  for (const file of mdFiles) {
    let content: string;
    try {
      content = fs.readFileSync(file, 'utf-8');
    } catch {
      result.warnings.push({ file, message: 'Could not read file' });
      continue;
    }

    const lines = content.split('\n');
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].includes(brandPattern)) {
        result.errors.push({
          file,
          line: i + 1,
          message: `Legacy brand name "${brandPattern}" found`,
        });
      }
    }
  }

  result.valid = result.errors.length === 0;
  return result;
}

/**
 * Run all validations and merge the results.
 */
export function validateAll(projectPath: string): ValidationResult {
  return mergeResults(
    validateSchemas(projectPath),
    validateImports(projectPath),
    validateBrand(projectPath),
  );
}
