import type { Command } from 'commander';
import fs from 'fs';
import path from 'path';
import { detectVendor } from '../../adapters/base.js';
import { renderSuccess, renderError, renderWarning, renderBanner } from '../ui/renderer.js';

export interface UlakConfig {
  version: string;
  vendor: string;
  promptPack: string;
  memory: {
    backend: string;
    path: string;
  };
  artefacts: {
    outputDir: string;
  };
}

function getDefaultConfig(vendor: string): UlakConfig {
  return {
    version: '2.0.0',
    vendor,
    promptPack: 'ulak-os@2.0.0',
    memory: {
      backend: 'sqlite',
      path: '.ulak/memory.db',
    },
    artefacts: {
      outputDir: 'reports/current',
    },
  };
}

export function loadConfig(projectPath: string): UlakConfig | null {
  const configPath = path.join(projectPath, 'ulak.config.json');
  if (!fs.existsSync(configPath)) return null;
  return JSON.parse(fs.readFileSync(configPath, 'utf-8')) as UlakConfig;
}

export function saveConfig(projectPath: string, config: UlakConfig): void {
  const configPath = path.join(projectPath, 'ulak.config.json');
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2) + '\n');
}

export function registerInit(program: Command): void {
  program
    .command('init')
    .description('Projeye Ulak OS kurar, vendor detect eder')
    .option('-v, --vendor <vendor>', 'Vendor seçimi (claude, codex, gemini)')
    .option('-p, --path <path>', 'Proje dizini', '.')
    .action((options: { vendor?: string; path: string }) => {
      const projectPath = path.resolve(options.path);

      renderBanner();

      // Check if already initialized
      if (fs.existsSync(path.join(projectPath, 'ulak.config.json'))) {
        renderWarning('Proje zaten başlatılmış (ulak.config.json mevcut)');
        return;
      }

      // Detect or use provided vendor
      let vendorName = options.vendor;
      if (!vendorName) {
        const adapter = detectVendor(projectPath);
        if (adapter) {
          vendorName = adapter.name;
          renderSuccess(`Vendor detected: ${vendorName}`);
        } else {
          renderError('Vendor tespit edilemedi. --vendor bayrağı kullanın.');
          process.exit(1);
        }
      }

      // Create config
      const config = getDefaultConfig(vendorName);
      saveConfig(projectPath, config);
      renderSuccess('ulak.config.json oluşturuldu');

      // Create .ulak directory
      const ulakDir = path.join(projectPath, '.ulak');
      const sessionsDir = path.join(ulakDir, 'sessions');
      if (!fs.existsSync(ulakDir)) fs.mkdirSync(ulakDir, { recursive: true });
      if (!fs.existsSync(sessionsDir)) fs.mkdirSync(sessionsDir, { recursive: true });
      renderSuccess('.ulak/ dizini hazır');

      // Ensure reports/current exists
      const reportsDir = path.join(projectPath, config.artefacts.outputDir);
      if (!fs.existsSync(reportsDir)) fs.mkdirSync(reportsDir, { recursive: true });
      renderSuccess('reports/current/ hazır');

      console.log('');
      renderSuccess(`Hazır! Şimdi: ulak run director`);
    });
}
