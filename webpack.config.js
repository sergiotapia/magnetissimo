module.exports = {
  entry: './web/static/js/app.js',
  output: {
    path: './priv/static/js',
    filename: 'app.js'
  },

  module: {
    loaders: [{
      test: /\.(js|jsx)$/,
      loader: 'babel',
      exclude: /node_modules/,
      query: {
        presets: ['es2015', 'react']
      }
    }]
  },

  resolve: {
    modulesDirectories: [ 'node_modules', __dirname + '/web/static/js' ],
    extensions: ['', '.js', '.jsx']
  }
}
