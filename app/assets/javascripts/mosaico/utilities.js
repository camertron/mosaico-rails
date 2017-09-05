window.mosaico = window.mosaico || {};

window.mosaico.utilities = {
  urlJoin: function(origSegments) {
    var segments = [];

    for (var i = 0; i < origSegments.length; i ++) {
      if (origSegments[i] == undefined) {
        continue;
      }

      var match = origSegments[i].match(/^\/?(.*?)\/?$/)
      segments.push(match[1]);
    }

    var joined = segments.join('/');

    // handle absolute URLs
    return /^\//.test(origSegments[0]) ? '/' + joined : joined;
  },

  authenticityToken: function() {
    return $('meta[name="csrf-token"]').attr('content');
  }
};
