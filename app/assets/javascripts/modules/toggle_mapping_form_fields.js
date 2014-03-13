(function(Modules) {
  "use strict"

  Modules.ToggleMappingFormFields = function() {

    var that = this;

    that.start = function(element) {

      var form = element,
          httpStatus = form.find('.js-http-status'),
          archiveFields = form.find('.js-for-archive'),
          pendingContentFields = form.find('.js-for-pending'),
          redirectFields = form.find('.js-for-redirect');

      httpStatus.on('change', toggleFormFieldsets);
      toggleFormFieldsets();

      function toggleFormFieldsets() {

        var selectedHTTPStatus = httpStatus.val();

        switch (selectedHTTPStatus) {

          case '301':
            redirectFields.show();
            pendingContentFields.hide();
            archiveFields.hide();
            break;

          case '410':
            redirectFields.hide();
            pendingContentFields.hide();
            archiveFields.show();
            break;

          case '418':
            redirectFields.hide();
            pendingContentFields.show();
            archiveFields.hide();
            break;

          default:
            redirectFields.show();
            pendingContentFields.show();
            archiveFields.show();
            break;
        }
      }
    };
  };

})(GOVUK.Modules);
