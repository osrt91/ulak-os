import type { Command } from 'commander';
import path from 'path';
import { loadConfig } from './init.js';
import { getArtefactStatuses } from '../../core/artefact-manager.js';
import { renderArtefactTable, renderError, renderBanner } from '../ui/renderer.js';

export function registerStatus(program: Command): void {
  program
    .command('status')
    .description('Artefakt zincirinin durumunu gösterir')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .action((options: { path: string }) => {
      const projectPath = path.resolve(options.path);
      const config = loadConfig(projectPath);

      if (!config) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      renderBanner();

      const outputDir = path.join(projectPath, config.artefacts.outputDir);
      const statuses = getArtefactStatuses(outputDir);

      console.log(renderArtefactTable(statuses));

      const filled = statuses.filter(s => s.exists && !s.isEmpty).length;
      const total = statuses.length;
      console.log(`\n  ${filled}/${total} artefakt dolu\n`);
    });
}
