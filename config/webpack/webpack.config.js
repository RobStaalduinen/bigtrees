const path = require('path')
const webpack = require('webpack')
const { generateWebpackConfig } = require('shakapacker')
const { VueLoaderPlugin } = require('vue-loader')

const config = generateWebpackConfig()

// Vue alias and extension
config.resolve.alias = {
  ...(config.resolve.alias || {}),
  '@': path.resolve(__dirname, '../../app/javascript/')
}
// Preserve Webpacker 5 behavior: allow extensionless imports of style files
const extraExtensions = ['.vue', '.scss', '.sass', '.css']
for (const ext of extraExtensions) {
  if (!config.resolve.extensions.includes(ext)) {
    config.resolve.extensions.push(ext)
  }
}

// Node polyfills for webpack 5 — xml2js (used by awsS3Utils for S3 XML responses) needs these
config.resolve.fallback = {
  ...(config.resolve.fallback || {}),
  buffer: require.resolve('buffer/'),
  stream: require.resolve('stream-browserify'),
  timers: require.resolve('timers-browserify')
}

// Quiet Bootstrap 4 SCSS deprecation warnings (third-party noise, can't fix without Bootstrap 5 bump)
for (const rule of config.module.rules) {
  if (rule.test && rule.test.toString().includes('scss|sass') && Array.isArray(rule.use)) {
    for (const useEntry of rule.use) {
      if (useEntry && useEntry.loader && useEntry.loader.includes('sass-loader')) {
        useEntry.options = {
          ...(useEntry.options || {}),
          warnRuleAsWarning: false,
          sassOptions: {
            ...((useEntry.options && useEntry.options.sassOptions) || {}),
            quietDeps: true,
            silenceDeprecations: ['legacy-js-api', 'import', 'global-builtin', 'color-functions', 'slash-div', 'if-function']
          }
        }
      }
    }
  }
}

// Vue rule — must be prepended so the generic JS/etc. rules don't shadow it
config.module.rules.unshift({
  test: /\.vue(\.erb)?$/,
  use: [{ loader: 'vue-loader' }]
})

// Suppress the dev-server runtime error overlay (we read console/server logs instead).
// Compile errors still show.
if (config.devServer) {
  config.devServer.client = {
    ...(config.devServer.client || {}),
    overlay: { errors: true, warnings: false, runtimeErrors: false }
  }
}

// Vue loader plugin
config.plugins.push(new VueLoaderPlugin())

// Inject `process` as a module-level global (vue-pdf and other deps reference it without require)
config.plugins.push(new webpack.ProvidePlugin({
  process: require.resolve('process/browser')
}))

module.exports = config
