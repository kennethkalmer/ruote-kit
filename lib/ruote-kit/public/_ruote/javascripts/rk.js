
/* under the MIT license, see LICENSE.txt */

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

  function toggleNext (elt, tagname) {
    if ( ! tagname) {
      $(elt).hide();
      tagname = elt.tagName;
    }
    var next = elt.nextSibling;
    if ( ! next) next = firstSibling(elt);
    if (next.tagName != tagname) toggleNext(next, tagname);
    else $(next).show();
  }
  function firstSibling (elt) {
    if (elt.previousSibling) return firstSibling(elt.previousSibling);
    return elt;
  }

  return {
    toggle: toggle,
    toggleNext: toggleNext
  };
}();

