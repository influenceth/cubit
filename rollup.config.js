import cleanup from 'rollup-plugin-cleanup';
import { getBabelOutputPlugin } from '@rollup/plugin-babel';
import { importAssertionsPlugin } from 'rollup-plugin-import-assert';
import { importAssertions } from 'acorn-import-assertions';

const { env: { NODE_ENV } } = process;

const input = './src/index.js';

const output = [
  { file: './build/index.cjs', format: 'cjs', sourcemap: (NODE_ENV !== 'production') },
  { file: './build/index.js', format: 'es', sourcemap: (NODE_ENV !== 'production') }
];

const plugins = [
  cleanup({
    comments: 'none',
    extensions: ['*']
  }),
  getBabelOutputPlugin({ presets: ['@babel/preset-env'] }),
  importAssertionsPlugin()
];

export default {
  acornInjectPlugins: [importAssertions],
  input,
  output,
  plugins
};
