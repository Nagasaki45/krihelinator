import Vue from "vue"
import $ from "jquery"

new Vue({
  el: '#app',
  data: {
    repos: [],
    languages: [],
    badge_repo: "your-user-name/awesome-project"
  },
  ready: function() {
    this.setFromAjax("repos", "/api/v1/repositories");
    this.setFromAjax("languages", "/api/v1/languages");
  },
  methods: {
    filterByLanguage: function(language) {
      var url = "/api/v1/repositories?language=" + encodeURIComponent(language);
      this.setFromAjax("repos", url);
    },
    setFromAjax: function(what, url) {
      var that = this;
      $.ajax({
        url: url,
        success: function(data) {
          that[what] = data
        }
      });
    }
  }
});
