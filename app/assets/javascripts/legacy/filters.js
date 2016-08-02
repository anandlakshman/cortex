angular.module('cortex.filters', [
  'cortex.vendor.moment'
])

// Turns underscores into spaces, capitalizes first letter of string
.filter('humanize', function () {
  return function (string) {
    string = string.split('_').join(' ').toLowerCase();
    return string.charAt(0).toUpperCase() + string.slice(1);
  };
})

// Turns Media into its HTML representation
.filter('mediaToHtml', function () {
  return function (media) {
    var outputHtml;

    if (media.content_type === 'image') {
      outputHtml = '<p><a href="' +
        media.url +
        '"><img alt="' +
        (media.alt || '') +
        '" src="' +
        media.url +
        '" data-media-id="' +
        media.id +
        '"></a></p>';
    }
    else {
      outputHtml = '<a href="' +
        media.url +
        '" data-media-id="' +
        media.id +
        '">' +
        media.name +
        '</a>';
    }

    return outputHtml;
  };
})

.filter('tagList', function () {
  return function (tags) {
    return _.map(tags, function (t) {
      return t.name;
    }).join(', ');
  };
})

.filter('prettifyArrayString', function () {
  return function (arrayString) {
    return JSON.parse(arrayString).join(", ")
  };
})

.filter('publishStatus', function (moment) {
  return function (value, draft) {
    if (!value || draft) {
      return 'Draft';
    }
    var publishedAt = moment(value);
    var now = moment();
    return publishedAt.diff(now) <= 0 ? 'Published' : 'Scheduled';
  };
})

// https://gist.github.com/thomseddon/3511330
.filter('bytes', function () {
  return function (bytes, precision) {

    if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) {
      return '-';
    }

    if (typeof precision === 'undefined') {
      precision = 1;
    }

    var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'],
      number = Math.floor(Math.log(bytes) / Math.log(1024));

    return (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) + ' ' + units[number];
  };
})

.filter('slugify', function () {
  return function (value, delim) {
    if (!value) {
      return '';
    }
    delim = delim || "-";
    return value.toLowerCase().replace(/[^\w ]+/g, '').replace(/ +/g, delim);
  };
})

.filter('postEditState', function () {
  return function (post, sref) {
    var state = "cortex.posts.edit.sections." + post.type.replace('Post', '').toLowerCase();
    if (sref) {
      state = state + "({postId: " + post.id + "})";
    }
    return state;
  };
})

.filter('trustAsResourceUrl', function ($sce) {
  return function (url) {
    return $sce.trustAsResourceUrl(url);
  }
})

.filter('postNewState', function () {
  return function (post) {
    return "cortex.posts.new.sections." + post.type.replace('Post', '').toLowerCase();
  };
});