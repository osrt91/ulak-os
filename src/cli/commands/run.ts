import type { Command } from 'commander';
import path from 'path';
import ora from 'ora';
import { loadConfig } from './init.js';
import { detectVendor } from '../../adapters/base.js';
import { ARTEFACT_CHAIN, parseArtefacts, writeArtefact } from '../../core/artefact-manager.js';
import { createSessionManager } from '../../core/session.js';
import { extractLearnings } from '../../core/learning-extractor.js';
import { createMemoryStore } from '../../memory/store.js';
import { renderSuccess, renderError } from '../ui/renderer.js';

export function registerRun(program: Command): void {
  program
    .command('run <target>')
    .description('Artefakt veya komut çalıştır (director, intake, all, ...)')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .action(async (target: string, options: { path: string }) => {
      const projectPath = path.resolve(options.path);
      const config = loadConfig(projectPath);

      if (!config) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      // Get vendor adapter
      const adapter = detectVendor(projectPath, config.vendor);
      if (!adapter) {
        renderError(`Vendor "${config.vendor}" tespit edilemedi.`);
        process.exit(1);
      }

      if (!adapter.isInstalled()) {
        renderError(`${adapter.name} CLI kurulu değil.`);
        process.exit(1);
      }

      // Start session
      const dbPath = path.join(projectPath, config.memory.path);
      const sessionMgr = createSessionManager(dbPath);
      const session = sessionMgr.start(projectPath, adapter.name, target);

      const spinner = ora(`${adapter.name} çalıştırılıyor...`).start();

      try {
        // Build prompt based on target
        let prompt: string;
        if (target === 'director' || target === 'all') {
          prompt = '/director komple';
        } else if (ARTEFACT_CHAIN.includes(target as any)) {
          prompt = `Generate the "${target}" artefact for this project. Follow the Ulak OS core contract.`;
        } else {
          prompt = target;
        }

        // Send to vendor CLI
        const rawOutput = await adapter.sendPrompt(prompt, { cwd: projectPath });
        spinner.succeed(`${adapter.name} tamamlandı`);

        // Parse artefacts from output
        const artefacts = parseArtefacts(rawOutput);
        const outputDir = path.join(projectPath, config.artefacts.outputDir);
        const store = createMemoryStore(dbPath);

        let count = 0;
        for (const [name, content] of artefacts) {
          writeArtefact(outputDir, name, content);
          store.saveArtefact(session.id, name, content);
          count++;

          // Extract learnings
          const learnings = extractLearnings(name, content);
          for (const l of learnings) {
            store.saveLearning(session.id, l.category, l.summary, l.detail, l.tags);
          }
        }

        store.close();
        sessionMgr.finish(session.id);

        if (count > 0) {
          renderSuccess(`${count} artefakt üretildi → ${config.artefacts.outputDir}/`);
        } else {
          renderSuccess('Komut çalıştırıldı (artefakt parse edilemedi — ham çıktı reports/ altında)');
          // Write raw output as fallback
          const fs = await import('fs');
          const rawPath = path.join(outputDir, `${target}-raw.md`);
          fs.writeFileSync(rawPath, rawOutput);
        }

        renderSuccess(`Hafızaya kaydedildi (session #${session.id})`);
      } catch (error) {
        spinner.fail('Hata oluştu');
        renderError((error as Error).message);
        sessionMgr.finish(session.id);
        process.exit(1);
      }
    });
}
