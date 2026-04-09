#!/usr/bin/env node

import { Command } from 'commander';
import { registerInit } from './commands/init.js';
import { registerRun } from './commands/run.js';
import { registerStatus } from './commands/status.js';
import { registerValidate } from './commands/validate.js';
import { registerMemory } from './commands/memory.js';
import { registerConfig } from './commands/config.js';
import { registerUpgrade } from './commands/upgrade.js';
import { registerExport } from './commands/export.js';

const program = new Command();

program
  .name('ulak')
  .description('Ulak OS — Vendor-neutral prompt operating system CLI')
  .version('2.0.0');

registerInit(program);
registerRun(program);
registerStatus(program);
registerValidate(program);
registerMemory(program);
registerConfig(program);
registerUpgrade(program);
registerExport(program);

program.parse();
