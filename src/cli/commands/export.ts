import type { Command } from 'commander';
import fs from 'fs';
import path from 'path';
import { loadConfig } from './init.js';
import { ARTEFACT_CHAIN, readArtefact } from '../../core/artefact-manager.js';
import { renderSuccess, renderError } from '../ui/renderer.js';

export function registerExport(program: Command): void {
  program
    .command('export')
    .description('Artefaktları JSON olarak dışa aktarır')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .option('-f, --format <format>', 'Çıktı formatı (json)', 'json')
    .option('-o, --output <file>', 'Çıktı dosyası')
    .action((options: { path: string; format: string; output?: string }) => {
      const projectPath = path.resolve(options.path);
      const config = loadConfig(projectPath);

      if (!config) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      const outputDir = path.join(projectPath, config.artefacts.outputDir);

      const exportData: Record<string, string | null> = {};
      for (const name of ARTEFACT_CHAIN) {
        exportData[name] = readArtefact(outputDir, name);
      }

      const jsonOutput = JSON.stringify({
        version: config.version,
        exportedAt: new Date().toISOString(),
        artefacts: exportData,
      }, null, 2);

      if (options.output) {
        const outPath = path.resolve(options.output);
        fs.writeFileSync(outPath, jsonOutput);
        renderSuccess(`Dışa aktarıldı: ${outPath}`);
      } else {
        console.log(jsonOutput);
      }
    });
}
