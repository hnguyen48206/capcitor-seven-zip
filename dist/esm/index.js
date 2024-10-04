import { registerPlugin } from '@capacitor/core';
const Sevenzip = registerPlugin('Sevenzip', {
    web: () => import('./web').then((m) => new m.SevenzipWeb()),
});
export * from './definitions';
export { Sevenzip };
//# sourceMappingURL=index.js.map