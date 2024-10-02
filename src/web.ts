import { WebPlugin } from '@capacitor/core';

import type { SevenzipPlugin } from './definitions';

export class SevenzipWeb extends WebPlugin implements SevenzipPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
