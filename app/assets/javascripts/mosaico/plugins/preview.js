"use strict";

// used for live preview in iframe.
ko.bindingHandlers.bindIframe.init = function(element, valueAccessor) {
  function bindIframe(local) {
    try {
      var iframe = element.contentDocument;
      iframe.open();
      iframe.write(ko.bindingHandlers.bindIframe.tpl);
      iframe.close();

      try {
        var iframedoc = iframe.body;

        if (iframedoc) {
          var html = iframe.getElementsByTagName("HTML");

          ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
            ko.cleanNode(html[0] || iframedoc);
          });

          var wrap = function(toWrap) {
            switch(Object.prototype.toString.call(toWrap)) {
              case '[object Function]':
                var func = function() {
                  // assume we should unwrap if called
                  if (ko.isObservable(toWrap)) {
                    return wrap(ko.utils.unwrapObservable(toWrap));
                  } else {
                    return wrap(toWrap.call(arguments));
                  }
                };

                $.extend(func, toWrap);
                return func;

              case '[object Object]':
                var wrappedObj = {};

                for (var key in toWrap) {
                  if (toWrap.hasOwnProperty(key)) {
                    wrappedObj[key] = wrap(toWrap[key]);
                  }
                }

                return wrappedObj;

              case '[object Array]':
                var wrappedArr = [];

                for (var i = 0; i < toWrap.length; i ++) {
                  wrappedArr[i] = wrap(toWrap[i]);
                }

                return wrappedArr;

              case '[object String]':
                console.log('wrapped string!');
                // do something here, maybe liquid transformations?
                // better solution might be to maintain a shadow model for
                // presentation purposes
                return toWrap;

              default:
                return toWrap;
            }
          }

          ko.applyBindings(wrap(valueAccessor()), html[0] || iframedoc);
        } else {
          console.log("no iframedoc", local);
        }
      } catch (e) {
        console.log("error reading iframe.body", e, local);
        throw e;
      }
    } catch (e) {
      console.log("error reading iframe contentDocument", e, local);
      throw e;
      // ignored
    }
  }

  bindIframe("first call");
};
