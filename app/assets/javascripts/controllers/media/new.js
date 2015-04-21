angular.module('cortex.controllers.media.new', [
    'ui.router.state',
    'ui.bootstrap.datepicker',
    'ui.bootstrap.progressbar',
    'ui.bootstrap.tabs',
    'ui.bootstrap.dropdown',
    'angular-flash.service',
    'angularFileUpload',
    'ngTagsInput',
    'cortex.settings',
    'cortex.services.cortex',
    'cortex.directives.fileSelector',
    'cortex.directives.youtubeSelector',
    'cortex.directives.showErrors'
])

.controller('MediaNewCtrl', function($scope, $timeout, $upload, $state, $q, flash, cortex, settings) {

  $scope.data            = $scope.data || {};
  $scope.data.currentTab = 'file';
  $scope.data.media      = new cortex.media();
  $scope.data.media.tag_list = [];
  $scope.data.upload     = {
    progress: 0
  };

  // angular-bootstrap datepicker settings
  $scope.datepicker = {
    format: 'yyyy/MM/dd',
    expireAtOpen: false,
    open: function(datepicker) {
      $timeout(function(){
        $scope.datepicker[datepicker] = true;
      });
    }
  };

  function saveFile() {
    var d = $q.defer();

    $scope.data.media.type = 'Media';
    var file = $scope.data.media.$file;

    if (!file) {
      d.reject('No file present.');
    }
    else {
      var uploadError = false;
      var httpConfig  = {
        url: settings.cortex_base_url + '/media',
        method: 'POST',
        fields: {media: $scope.data.media},
        file: file,
        fileFormDataName: 'media[attachment]',
        formDataAppender: function(formData, key, value) {
          if (key === 'media') {
            angular.forEach(value, function(v, k) {
              formData.append('media[' + k + ']', v);
            });
          }
        }
      };

      $scope.data.upload.progress = 1;
      $scope.data.upload = $upload.upload(httpConfig)
          .then(
          function(media) { //Success
            d.resolve();
          },
          function(error, status) { //Error
            uploadError                 = true;
            $scope.data.upload.progress = 0;
            $scope.data.upload.file     = null;

            if (status === 422) {
              d.reject('Selected file type is not supported. Please choose a different file.');
            }
            else {
              d.reject('Unhandled error');
            }
          },
          function(e) { //Progress
            if (uploadError) { return; }
            $scope.data.upload.progress = parseInt(100.0 * e.loaded / e.total);
          }
        );
    }

    return d.promise;
  }
  // </saveFile()>

  function saveYoutube() {
    $scope.data.media.type     = 'Youtube';
    $scope.data.media.video_id = $scope.data.media.$youtube;
    return $scope.data.media.$save();
  }

  $scope.saveMedia = function() {
    var tab = $scope.currentTab;
    var save;

    $scope.$broadcast('validateShowErrors');

    $scope.data.media.tag_list = $scope.data.media.tag_list.map(function(tag) { return tag.name; });

    if (tab === 'file') {
      save = saveFile;
    }
    else if (tab === 'youtube') {
      save = saveYoutube;
    }
    else {
      flash.error = 'Unknown media-type tab "' + selectedTab + '"';
      return;
    }

    save().then(
      function() {
        flash.success = $scope.data.media.name + ' created';
        $state.go('^.manage.components');
      },
      function(error) {
        flash.error = error;
      });
  };

  $scope.selectTab = function(tab) {
    $scope.currentTab = tab;
  };

  $scope.cancel = function() {
    $state.go('^.manage.components');
  };

  $scope.loadTags = function (search) {
    return cortex.media.tags({s: search}).$promise;
  };

  $scope.data.popularTags = cortex.media.tags({popular: true});

  // Adds a tag to tag_list if it doesn't already exist in array
  $scope.addTag = function(tag) {
    if (_.some($scope.data.media.tag_list, function(t) { return t.name == tag.name; })) {
      return;
    }
    $scope.data.media.tag_list.push({name: tag.name, id: tag.id});
  };
});