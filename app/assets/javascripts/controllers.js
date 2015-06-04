(function ($, undefined) {
  $(function () {
    var $body = $("body")
    var controller = $body.data("controller").replace(/\//g, "_");
    var action = $body.data("action");

    var applicationController = Mapt['application'];
    if (applicationController !== undefined) {
      if ($.isFunction(applicationController.init)) {
        applicationController.init();
      }
    }

    var activeController = Mapt[controller];
    if (activeController !== undefined) {
      if ($.isFunction(activeController.init)) {
        activeController.init();
      }

      if ($.isFunction(activeController[action])) {
        activeController[action]();
      }
    }
  });
})(jQuery);