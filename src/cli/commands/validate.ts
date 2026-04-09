import type { Command } from 'commander';
import path from 'path';
import chalk from 'chalk';
import { validateAll } from '../../pack/validator.js';
import { renderSuccess, renderError, renderWarning } from '../ui/renderer.js';

export function registerValidate(program: Command): void {
  program
    .command('validate')
    .description('Yerel CI kapılarını koşar (schema, import, brand)')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .action((options: { path: string }) => {
      const projectPath = path.resolve(options.path);

      console.log('');
      console.log(chalk.bold('  Ulak OS Validate'));
      console.log('');

      const result = validateAll(projectPath);

      for (const err of result.errors) {
        renderError(`${err.file}${err.line ? ':' + err.line : ''} — ${err.message}`);
      }

      for (const warn of result.warnings) {
        renderWarning(`${warn.file} — ${warn.message}`);
      }

      if (result.valid) {
        renderSuccess('Tüm doğrulamalar geçti');
      } else {
        console.log('');
        renderError(`${result.errors.length} hata bulundu`);
        process.exit(1);
      }
    });
}
