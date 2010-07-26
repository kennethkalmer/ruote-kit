
/* under the MIT license */

var Rk = function () {

  function toggle (clickable, togglable, showText, hideText, slide) {

    if (clickable.innerHTML.indexOf(showText) > -1) {
      if (slide) $(togglable).slideDown();
      else $(togglable).show();
      clickable.innerHTML = hideText;
    }
    else {
      if (slide) $(togglable).slideUp();
      else $(togglable).hide();
      clickable.innerHTML = showText;
    }
  }

  return {
    toggle: toggle
  };
}();

