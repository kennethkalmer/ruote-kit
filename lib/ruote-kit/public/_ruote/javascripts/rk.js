
/* under the MIT license */

var RK = function () {

  function toggleParen (clickable, togglable) {

    var m = clickable.innerHTML.match("\((.+)\)");

    if (m) {
      $(togglable).show();
      clickable.innerHTML = m[1];
    }
    else {
      $(togglable).hide();
      clickable.innerHTML = '(' + clickable.innerHTML + ')';
    }
  }

  return {
    toggleParen: toggleParen
  };
}();

