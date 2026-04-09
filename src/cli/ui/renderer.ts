import chalk from 'chalk';
import Table from 'cli-table3';
import type { ArtefactStatus } from '../../core/artefact-manager.js';

export function renderArtefactTable(statuses: ArtefactStatus[]): string {
  const table = new Table({
    head: [chalk.bold('Artefakt'), chalk.bold('Durum')],
    colWidths: [30, 12],
  });

  for (const s of statuses) {
    const status = !s.exists
      ? chalk.red('eksik')
      : s.isEmpty
        ? chalk.yellow('bos')
        : chalk.green('dolu');
    table.push([s.name, status]);
  }

  return table.toString();
}

export function renderSuccess(message: string): void {
  console.log(chalk.green('  ✓ ') + message);
}

export function renderError(message: string): void {
  console.error(chalk.red('  ✗ ') + message);
}

export function renderWarning(message: string): void {
  console.log(chalk.yellow('  ⚠ ') + message);
}

export function renderInfo(message: string): void {
  console.log(chalk.blue('  ℹ ') + message);
}

export function renderBanner(): void {
  console.log('');
  console.log(chalk.bold('  Ulak OS') + chalk.dim(' v2.0.0'));
  console.log(chalk.dim('  Vendor-neutral prompt operating system'));
  console.log('');
}
