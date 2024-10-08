const path = require('path');

module.exports = {
  test: /\.vue(\.erb)?$/,
  use: [{
    loader: 'vue-loader'
  }],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, '../../../app/javascript/')
    }
  }
}
