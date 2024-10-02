export interface SevenzipPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
