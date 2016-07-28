$(document).ready(function functionName() {
  new Vue({
    el: '#app',
    data: {
      repos: [],
      badge_repo: "your-user-name/awesome-project"
    },
    ready: function() {
      var that = this;
      $.ajax({
        url: "/api/v1/repositories",
        success: function(repos) {
          that.repos = repos
        }
      });
    }
  })
});
