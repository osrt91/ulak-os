import type { Command } from 'commander';
import path from 'path';
import chalk from 'chalk';
import { loadConfig, saveConfig } from './init.js';
import { renderSuccess, renderError } from '../ui/renderer.js';

export function registerConfig(program: Command): void {
  const config = program
    .command('config')
    .description('Ayarları gösterir/değiştirir');

  config
    .command('show')
    .description('Mevcut ayarları gösterir')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .action((options: { path: string }) => {
      const projectPath = path.resolve(options.path);
      const cfg = loadConfig(projectPath);

      if (!cfg) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      console.log(chalk.bold('\n  Ulak OS Config\n'));
      console.log(JSON.stringify(cfg, null, 2)
        .split('\n')
        .map(line => '  ' + line)
        .join('\n'));
      console.log('');
    });

  config
    .command('set <key> <value>')
    .description('Ayar değiştirir (örn: vendor gemini)')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .action((key: string, value: string, options: { path: string }) => {
      const projectPath = path.resolve(options.path);
      const cfg = loadConfig(projectPath);

      if (!cfg) {
        renderError('ulak.config.json bulunamadı. Önce: ulak init');
        process.exit(1);
      }

      // Support dot notation for nested keys
      const keys = key.split('.');
      let target: any = cfg;
      for (let i = 0; i < keys.length - 1; i++) {
        if (target[keys[i]] === undefined) {
          renderError(`Geçersiz anahtar: ${key}`);
          process.exit(1);
        }
        target = target[keys[i]];
      }

      const lastKey = keys[keys.length - 1];
      if (target[lastKey] === undefined) {
        renderError(`Geçersiz anahtar: ${key}`);
        process.exit(1);
      }

      target[lastKey] = value;
      saveConfig(projectPath, cfg);
      renderSuccess(`${key} = ${value}`);
    });
}
