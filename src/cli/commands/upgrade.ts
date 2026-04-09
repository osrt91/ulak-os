import type { Command } from 'commander';
import path from 'path';
import ora from 'ora';
import { loadConfig } from './init.js';
import { checkUpgrade, upgrade } from '../../pack/upgrader.js';
import { renderSuccess, renderError, renderInfo } from '../ui/renderer.js';

export function registerUpgrade(program: Command): void {
  program
    .command('upgrade')
    .description('Prompt pack\'i son sürüme günceller')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .option('-s, --source <source>', 'Pack kaynağı (npm, git URL, yerel dizin)')
    .action(async (options: { path: string; source?: string }) => {
      const projectPath = path.resolve(options.path);
      const config = loadConfig(projectPath);

      if (!config) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      const spinner = ora('Güncel sürüm kontrol ediliyor...').start();

      try {
        const check = await checkUpgrade(projectPath, options.source);

        if (!check.available) {
          spinner.succeed('Zaten güncel');
          renderInfo(`Mevcut sürüm: ${check.currentVersion || 'bilinmiyor'}`);
          return;
        }

        spinner.text = 'Pack güncelleniyor...';
        const result = await upgrade(projectPath, options.source);

        if (result.success) {
          spinner.succeed(`Pack güncellendi: ${result.fromVersion} → ${result.toVersion}`);
          for (const change of result.changes) {
            renderSuccess(`${change.type}: ${change.file}`);
          }
        } else {
          spinner.fail('Güncelleme başarısız');
        }
      } catch (error) {
        spinner.fail('Hata oluştu');
        renderError((error as Error).message);
        process.exit(1);
      }
    });
}
