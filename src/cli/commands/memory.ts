import type { Command } from 'commander';
import path from 'path';
import chalk from 'chalk';
import Table from 'cli-table3';
import { loadConfig } from './init.js';
import { createMemorySearch } from '../../memory/search.js';
import { createMemoryStore } from '../../memory/store.js';
import { renderError, renderInfo } from '../ui/renderer.js';

export function registerMemory(program: Command): void {
  const memory = program
    .command('memory')
    .description('Proje hafızası yönetimi');

  memory
    .command('list')
    .description('Hafızadaki öğrenmeleri listeler')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .option('-n, --limit <number>', 'Gösterilecek kayıt sayısı', '20')
    .action((options: { path: string; limit: string }) => {
      const projectPath = path.resolve(options.path);
      const config = loadConfig(projectPath);

      if (!config) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      const dbPath = path.join(projectPath, config.memory.path);
      const store = createMemoryStore(dbPath);
      const learnings = store.getLearnings();
      store.close();

      if (learnings.length === 0) {
        renderInfo('Hafızada kayıt yok. Önce: ulak run director');
        return;
      }

      const table = new Table({
        head: [
          chalk.bold('#'),
          chalk.bold('Kategori'),
          chalk.bold('Özet'),
          chalk.bold('Tarih'),
        ],
        colWidths: [5, 15, 50, 12],
      });

      const limit = parseInt(options.limit, 10);
      for (const l of learnings.slice(0, limit)) {
        table.push([
          l.id,
          l.category,
          l.summary.substring(0, 47) + (l.summary.length > 47 ? '...' : ''),
          l.createdAt.substring(0, 10),
        ]);
      }

      console.log(table.toString());
      console.log(`\n  Toplam: ${learnings.length} kayıt\n`);
    });

  memory
    .command('search <query>')
    .description('Hafızada arama yapar')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .option('-n, --limit <number>', 'Sonuç limiti', '10')
    .action((query: string, options: { path: string; limit: string }) => {
      const projectPath = path.resolve(options.path);
      const config = loadConfig(projectPath);

      if (!config) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      const dbPath = path.join(projectPath, config.memory.path);
      const search = createMemorySearch(dbPath);
      const limit = parseInt(options.limit, 10);
      const results = search.search(query, limit);

      if (results.length === 0) {
        renderInfo(`"${query}" için sonuç bulunamadı`);
        return;
      }

      for (const r of results) {
        console.log(chalk.dim(`  session #${r.sessionId}`) + chalk.cyan(` [${r.category}]`) + ` ${r.summary}`);
      }
      console.log(`\n  ${results.length} sonuç\n`);
    });
}
