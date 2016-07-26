$(document).ready(function functionName() {
  new Vue({
    el: '#app',
    data: {
      repos: []
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
