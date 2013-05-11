
/* under the MIT license, see LICENSE.txt */

var Rk = (function() {

  var self = this;

  this.toggle = function(clickable, togglable, showText, hideText, slide) {

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
  };

  this.toggleNext = function(elt, tagname) {

    if ( ! tagname) {
      $(elt).hide();
      tagname = elt.tagName;
    }
    var next = elt.nextSibling;
    if ( ! next) next = firstSibling(elt);
    if (next.tagName != tagname) toggleNext(next, tagname);
    else $(next).show();
  };

  function firstSibling(elt) {
    // TODO: replace that with appropriate jQueryism

    if (elt.previousSibling) return firstSibling(elt.previousSibling);
    return elt;
  }

  this.fitFluo = function($leftPane) {

    $leftPane = $leftPane || $('#fluo').next();

    $('#fluo').css('width', '' + $('body').width() - $leftPane.width() - 20);
  };

  this.onClickZoom = function(elt) {

    var $elt = $(elt);
    var $svg = $elt.find('svg');
    var scale = parseFloat($svg.attr('data-ruote-fluo-scale'));

    if (isNaN(scale) || scale >= 1.0) return;

    $elt.css('cursor', 'pointer');

    $elt.on('click', function(ev) {

      $('body').prepend($('<div id="overlay" style="display: none;" />'));
      var $overlay = $('#overlay');

      $overlay.css('height', '' + $(document).height() + 'px');
      $overlay.slideDown(function() {

        $('body').prepend($('<div id="zoom" />'));
        var clone = $svg.clone();
        var $zoom = $('#zoom');
        $zoom.append(clone);
        var w = $zoom.width() - 12;
        var h = RuoteFluo.computeHeight($elt, w);
        $(clone).attr('width', '' + w + 'px');
        $(clone).attr('height', '' + h + 'px');

        var close = function(ev) {
          $zoom.remove();
          $overlay.remove();
        }
        $zoom.on('click', close);
        $overlay.on('click', close);
      });
    });
  };

  return this;

}).apply({});

