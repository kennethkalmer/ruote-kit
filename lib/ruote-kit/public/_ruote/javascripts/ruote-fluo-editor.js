
/*
 *  Ruote - open source ruby workflow engine
 *  (c) 2005-2010 John Mettraux
 *
 *  Ruote is freely distributable under the terms of the MIT license.
 *  For details, see the ruote web site: http://ruote.rubyforge.org
 *
 *  This piece of hack was created during the RubyKaigi2008,
 *  between Tsukuba and Akihabara.
 */

//var flow = [ 'process-definition', { 'name': 'toto', 'revision': '1.0' }, [
//    [ 'sequence', {}, [
//      [ 'participant', { 'ref': 'alpha' }, [] ],
//      [ 'bravo', {}, [] ]
//    ]]
//  ]
//]

try {
  HTMLElement.prototype.firstChildOfClass = function (className) {
    for (var i=0; i < this.childNodes.length; i++) {
      var c = this.childNodes[i];
      if (c.className == className) return c;
    }
    return null;
  }
} catch (e) {
  // when testing via spidermonkey
}

String.prototype.tstrip = function () {
  var s = this;
  while (s.charAt(0) == ' ') s = s.substring(1);
  while (s.charAt(s.length - 1) == ' ') s = s.substring(0, s.length - 1);
  return s;
}

var FluoEditor = function () {

  var TEXTS = {
    add_child_expression: 'add a child expression',
    cut_expression: 'cut expression',
    moveup_expression: 'move expression up',
    movedown_expression: 'move expression down',
    paste_expression: 'paste expression here'
  };

  // it's easy to override this var to let FluoEditor point to another root
  //
  //     FluoEditor.imageRoot = 'http://my.image.server.exmaple.com/img'
  //
  var imageRoot = '/images';

  var Attributes = function() {

    function tryParse (s) {
      try { return JSON.parse(s); } catch (e) {}
      return undefined;
    }

    function parse (s) {

      s = s.tstrip();

      var r = tryParse("{" + s + "}");
      if (r != undefined) return r;

      var head = undefined;
      var tail = undefined;

      var m = s.match(/^([^",]+)(.*)$/)
      if (m) {
        r = tryParse(m[1]);
        if (r != undefined) head = r;
        else head = tryParse('"' + m[1] + '"');
        tail = m[2];
      }
      else {
        for (var i = 1; i <= s.length; i++) {
          r = tryParse(s.slice(0, i));
          if (r != undefined) {
            head = r;
            break;
          }
        }
        tail = s.slice(i);
      }

      var h = {};
      h[head] = null;
      m = tail.match(/^[ ,]*(.*)$/);
      var hh = tryParse("{" + m[1] + "}");
      for (var k in hh) { h[k] = hh[k]; }

      return h;
    }

    return { parse: parse };
  }();
  
  var ExpressionHead = function () {

    function createButton (rfeClass, tooltip, callback) {

      var i = document.createElement('a');
      i.callback = callback;
      i.className = 'rfe_button ' + rfeClass;
      i.setAttribute('href', '');
      i.setAttribute('title', tooltip);
      i.setAttribute('onclick', 'this.callback(); return false;');
      return i;
    }

    function addHeadButtons (expdiv) {

      var outOpacity = 0.0;

      var buttons = document.createElement('span');
      buttons.className = 'rfe_buttons';
      buttons.style.opacity = outOpacity;

      var root = findRfeRoot(expdiv);

      expdiv.onmouseover = function () { 
        buttons.style.opacity = 1.0; 
        if (root.onOver) root.onOver(computeExpId(expdiv.parentNode));
      };
      expdiv.onmouseout = function () { 
        buttons.style.opacity = outOpacity; 
        if (root.onOver) root.onOver(null);
      };

      buttons.appendChild(createButton(
        'rfe_add',
        FluoEditor.TEXTS.add_child_expression,
        function () {
          FluoEditor.addExpression(expdiv.parentNode, [ '---', {}, [] ]);
        }));

      if (expdiv.parentNode.parentNode != root) {

        buttons.appendChild(createButton(
          'rfe_cut',
          FluoEditor.TEXTS.cut_expression,
          function () {
            FluoEditor.removeExpression(expdiv.parentNode);
          }));
        buttons.appendChild(createButton(
          'rfe_moveup',
          FluoEditor.TEXTS.moveup_expression,
          function () {
            FluoEditor.moveExpression(expdiv.parentNode, -1);
            buttons.style.opacity = outOpacity;
          }));
        buttons.appendChild(createButton(
          'rfe_movedown',
          FluoEditor.TEXTS.movedown_expression,
          function () {
            FluoEditor.moveExpression(expdiv.parentNode, +1);
            buttons.style.opacity = outOpacity;
          }));
        buttons.appendChild(createButton(
          'rfe_paste',
          FluoEditor.TEXTS.paste_expression,
          function () {
            var clip = document._rfe_clipboard;
            if (clip) FluoEditor.insertExpression(expdiv.parentNode, clip);
          }));
      }

      expdiv.appendChild(buttons);
    }

    var headPattern = /^(\S+)(.*)$/;

    function renderAttributes (h) {

      //var keys = [];
      //for (var k in h) keys.push(k);
      //keys = keys.sort();
      //s = '';
      //for (var i = 0; i < keys.length; i++) {
      //  var k = keys[i];
      //  s += k;
      //  var v = JSON.stringify(h[k]);
      //  if (v != 'null') s += (': ' + v);
      //  s += ', ';
      //}
      //if (s.length > 1) s = s.substring(0, s.length - 2);
      //return s;

      var a = [];

      for (var k in h) {
        var v = h[k];
        if (v == null) {
          a.push(JSON.stringify(k));
          break;
        }
      }
      for (var k in h) {
        var v = h[k];
        if (v == null) continue;
        a.push(JSON.stringify(k) + ': ' + JSON.stringify(v));
      }

      return a.join(', ');
    }

    return {

      render: function (node, exp) {

        var expname = exp[0];

        var text = '';
        if ((typeof exp[2][0]) == 'string') text = exp[2].shift();

        var atts = renderAttributes(exp[1]);

        var d = document.createElement('div');
        d.setAttribute('class', 'rfe_exp');
        node.appendChild(d);

        var sen = document.createElement('span');
        sen.setAttribute('class', 'rfe_exp_span rfe_expression_name');
        sen.appendChild(document.createTextNode(expname));
        d.appendChild(sen);

        var sea = document.createElement('span');
        sea.setAttribute('class', 'rfe_exp_span rfe_expression_atts');
        sea.appendChild(document.createTextNode(' ' + atts));
        d.appendChild(sea);

        addHeadButtons(d);

        var onblur = function () {

          var p = d.parentNode;
          var d2 = ExpressionHead.render(p, ExpressionHead.parse(this.value));
          p.replaceChild(d2, d);

          triggerChange(p); // trigger onChange()...
        };

        // blurring on "enter"
        //
        var onkeyup = function (evt) {

          var e = evt || window.event;
          var c = e.charCode || e.keyCode;
          if (c == 13) this.blur();

          return false;
        }

        // preventing propagation of "enter"
        //
        var onkeypress = function (evt) {

          var e = evt || window.event;
          var c = e.charCode || e.keyCode;

          return (c != 13);
        }

        var onclick = function () {
          d.removeChild(sen);
          var input = document.createElement('input');
          input.setAttribute('type', 'text');
          input.value = expname + ' ' + atts;
          if (text != '') input.value = expname + ' ' + text + ' ' + atts;
          d.replaceChild(input, sea);
          input.onblur = onblur;
          input.onkeyup = onkeyup;
          input.onkeypress = onkeypress;
          input.focus();
        };

        sen.onclick = onclick;
        sea.onclick = onclick;

        return d;
      },

      parse: function (s) {

        var m = s.match(headPattern);

        if (m == null) return [ '---', {}, [] ];

        var attributes = Attributes.parse(m[2]);

        return [ m[1], attributes, [] ];
      },

      toExp: function (node) {

        node = node.firstChild;

        var name = node.childNodes[0].firstChild.nodeValue;
        var atts = node.childNodes[1].firstChild.nodeValue;

        atts = Attributes.parse(atts);

        var children = [];

        return [ name, atts, children ];
      }
    };
  }();

  function asJson (node) {

    if ((typeof node) == 'string') 
      node = document.getElementById(node);

    return JSON.stringify(toTree(node));
  }

  function renderEnding (node, exp) {

    var ending = document.createElement('div');
    ending.className = 'rfe_text';
    if (exp[2].length > 0) ending.appendChild(document.createTextNode('end'));
    node.appendChild(ending);
  }

  function addExpression (parentExpNode, exp) {

    var end = parentExpNode.lastChild;
    var node = renderExpression(parentExpNode, exp);
    parentExpNode.replaceChild(node, end);
    parentExpNode.appendChild(end);

    if (end.childNodes.length == 0)
      end.appendChild(document.createTextNode('end'));

    triggerChange(parentExpNode);
  }

  function removeExpression (expNode) {

    var p = expNode.parentNode;
    p.removeChild(expNode);

    if (p.childNodes.length == 2)
      p.lastChild.removeChild(p.lastChild.firstChild);

    document._rfe_clipboard = toTree(expNode);

    triggerChange(p);
  }

  function renderExpression (parentNode, exp, isRootExp) {

    //
    // draw expression

    var node = document.createElement('div');
    node.className = 'rfe_expression';

    if ( ! isRootExp)
      node.setAttribute('style', 'margin-left: 14px;');

    parentNode.appendChild(node);

    if ( ! (exp instanceof Array)) {
      renderExpressionString(node, exp.toString());
      return;
    }

    ExpressionHead.render(node, exp);

    //
    // draw children

    for (var i=0; i < exp[2].length; i++) renderExpression(node, exp[2][i]);

    //
    // over

    renderEnding(node, exp);

    return node;
  }

  function renderFlow (parentNode, flow) {

    if ((typeof parentNode) == 'string') {
      parentNode = document.getElementById(parentNode);
    }

    parentNode.className = 'rfe_root';

    while(parentNode.firstChild) {
      parentNode.removeChild(parentNode.firstChild);
    }

    renderExpression(parentNode, flow, true);

    parentNode.stack = []; // the undo stack
    parentNode.currentTree = flow;
  }

  function moveExpression (elt, delta) {

    var p = elt.parentNode;

    if (delta == -1) { // move up
      if (elt.previousSibling.className != 'rfe_expression') return;
      p.insertBefore(elt, elt.previousSibling);
    }
    else { // move down
      if (elt.nextSibling.className != 'rfe_expression') return;
      p.insertBefore(elt, elt.nextSibling.nextSibling);
    }

    FluoEditor.triggerChange(p);
  }

  function insertExpression (before, exp) {

    var newNode = renderExpression(before.parentNode, exp);

    before.parentNode.insertBefore(newNode, before);

    FluoEditor.triggerChange(before.parentNode);
  }

  function triggerChange (elt) {

    var rfeRoot = findRfeRoot(elt);
    var tree = toTree(rfeRoot);

    stack(rfeRoot, tree);

    if (rfeRoot.onChange) rfeRoot.onChange(tree);
  }

  function stack(root, tree) {
    root.stack.push(root.currentTree);
    root.currentTree = tree;
  }

  function undo (root) {

    if ((typeof root) == 'string') root = document.getElementById(root);
    if (root.stack.length < 1) return;

    while (root.firstChild != null) root.removeChild(root.firstChild);

    var tree = root.stack.pop();

    root.currentTree = tree;
    renderExpression(root, tree, true);

    if (root.onChange) root.onChange(tree);
  }

  function findRfeRoot (node) {

      if (node.className == 'rfe_root') return node;
      return findRfeRoot(node.parentNode);
  }

  function computeExpId (node, from, expid) {

    if (from == null) {
      from = findRfeRoot(node);
      expid = '';
    }
    if (from == node) return expid.substring(1, expid.length);

    var divs = from.childNodes;
    var childid = -1;

    for (var i=0; i<divs.length; i++) {
      var e = divs[i];
      if (e.nodeType != 1) continue;
      if (e.className != 'rfe_expression') continue;
      childid += 1;
      var ei = computeExpId(node, e, expid + '_' + childid);
      if (ei != null) return ei;
    }

    return null;
  }

  function toTree (node) {

    node.focus();
      //
      // making sure all the input boxes get blurred...

    if (node.className != 'rfe_expression') {
      node = node.firstChildOfClass('rfe_expression');
    }

    //
    // expression itself

    var exp = ExpressionHead.toExp(node);

    //
    // children

    var divs = node.childNodes;

    var children = exp[2];

    for (var i=0; i<divs.length; i++) {
      var e = divs[i];
      if (e.nodeType != 1) continue;
      if (e.className != 'rfe_expression') continue;
      children.push(toTree(e));
    }

    //
    // done

    return exp;
  }

  //
  // public methods
  //
  return {

    TEXTS: TEXTS,

    ExpressionHead: ExpressionHead,
    Attributes: Attributes, // for testing purposes

    renderFlow: renderFlow,
    addExpression: addExpression,
    removeExpression: removeExpression,
    moveExpression: moveExpression,
    insertExpression: insertExpression,
    triggerChange: triggerChange,
    undo: undo,
    asJson: asJson,
    imageRoot: imageRoot
  };
}();

