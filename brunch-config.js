exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css"
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
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
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    afterBrunch: [
      // Copy octicon fonts to priv/static/css manually
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
      bootstrap: ["dist/css/bootstrap.min.css",],
      octicons: ["build/font/"]
    }
  }
};
