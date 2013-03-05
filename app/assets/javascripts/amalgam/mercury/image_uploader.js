Mercury.uploader.upload = function () {
  var image_options,formData, xhr,
    _this = this;
  xhr = new XMLHttpRequest;
  image_options = this.options;
  jQuery.each(['onloadstart', 'onprogress', 'onload', 'onabort', 'onerror'], function(index, eventName) {
    return xhr.upload[eventName] = function(event) {
      return _this.uploaderEvents[eventName].call(_this, event);
    };
  });
  xhr.onload = function(event) {
    var response, src;
    if (event.currentTarget.status >= 400) {
      _this.updateStatus('Error: Unable to upload the file');
      Mercury.notify('Unable to process response: %s', event.currentTarget.status);
      return _this.hide();
    } else {
      try {
        response = Mercury.config.uploading.handler ? Mercury.config.uploading.handler(event.target.responseText) : jQuery.parseJSON(event.target.responseText);
        src = response.url || response.image.url;
        uid = response.id || response.image.id;
        if (!src) {
          throw 'Malformed response from server.';
        }
        Mercury.trigger('action', {
          action: 'insertImage',
          value: {
            src: src,
            uid: uid
          }
        });
        return _this.hide();
      } catch (error) {
        _this.updateStatus('Error: Unable to upload the file');
        Mercury.notify('Unable to process response: %s', error);
        return _this.hide();
      }
    }
  };
  xhr.open('post', Mercury.config.uploading.url, true);
  xhr.setRequestHeader('Accept', 'application/json, text/javascript, text/html, application/xml, text/xml, */*');
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
  xhr.setRequestHeader(Mercury.config.csrfHeader, Mercury.csrfToken);
  if (Mercury.uploader.fileReaderSupported()) {
    return this.file.readAsBinaryString(function(result) {
      var multipart;
      multipart = new Mercury.uploader.MultiPartPost(Mercury.config.uploading.inputName, _this.file, result, image_options);
      _this.file.updateSize(multipart.delta);
      xhr.setRequestHeader('Content-Type', 'multipart/form-data; boundary=' + multipart.boundary);
      return xhr.sendAsBinary(multipart.body);
    });
  } else {
    formData = new FormData();
    formData.append(Mercury.config.uploading.inputName, this.file.file, this.file.file.name);
    return xhr.send(formData);
  }
}