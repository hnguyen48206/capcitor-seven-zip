import { registerPlugin } from '@capacitor/core';

import type { SevenzipPlugin } from './definitions';

const Sevenzip = registerPlugin<SevenzipPlugin>('Sevenzip', {
  web: () => import('./web').then((m) => new m.SevenzipWeb()),
});

export * from './definitions';
export { Sevenzip };
