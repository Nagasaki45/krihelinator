exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {joinTo: "js/app.js"},
    stylesheets: {joinTo: "css/app.css"}
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    afterBrunch: [
      // Copy octicon fonts to priv/static/css manually
      "cp node_modules/octicons/build/font/octicons.eot priv/static/css/",
      "cp node_modules/octicons/build/font/octicons.ttf priv/static/css/",
      "cp node_modules/octicons/build/font/octicons.woff priv/static/css/",
      "cp node_modules/octicons/build/font/octicons.woff2 priv/static/css/"
    ]
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    globals: {
      jQuery: 'jquery'
    },
    styles: {
      bootstrap: ["dist/css/bootstrap.css"],
      octicons: ["build/font/octicons.css"]
    }
  }
};
