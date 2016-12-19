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
    ],

    // Where to compile files to
    public: "priv/static"
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  }
};
