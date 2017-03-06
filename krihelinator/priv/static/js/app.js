new Vue({
  el: '#badge-app',
  data: {
    badge_repo: "your-user-name/awesome-project"
  }
})

new Vue({
  el: '#languages-app',
  data: {
    checkedLanguages: []
  },
  methods: {
    see_history: function() {
      var json = encodeURIComponent(JSON.stringify(this.checkedLanguages));
      window.location.href = 'languages/history?languages=' + json;
    }
  }
})

new List(
    'showcases',
    {
        valueNames: ['name', 'description']
    }
);

new List(
    'languages-app',
    {
        valueNames: ['name']
    }
);
