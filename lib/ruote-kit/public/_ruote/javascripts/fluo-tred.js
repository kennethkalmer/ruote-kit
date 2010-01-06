
/*
 *  Ruote - open source ruby workflow engine
 *  (c) 2005-2009 John Mettraux
 *
 *  Ruote is freely distributable under the terms 
 *  of a BSD-style license.
 *  For details, see the OpenWFEru web site: http://openwferu.rubyforge.org
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
  // probably testing via Rhino
}

String.prototype.tstrip = function () {
  var s = this;
  while (s.charAt(0) == ' ') s = s.substring(1);
  while (s.charAt(s.length - 1) == ' ') s = s.substring(0, s.length - 1);
  return s;
}
String.prototype.qstrip = function () {
  var s = this;
  if (s.match(/".*"/)) s = s.substring(1, s.length - 1);
  return s;
}
String.prototype.tqstrip = function () {
  return this.tstrip().qstrip();
}

var FluoTred = function () {

  //
  // it's easy to override this var to let FluoTred point to another root
  //
  //     FluoTred.imageRoot = 'http://my.image.server.exmaple.com/img'
  //
  var imageRoot = '/images';
  
  var ExpressionHead = function () {

    function createButton (imgsrc, tooltip, callback) {

      var i = document.createElement("img");
      i.callback = callback;
      i.className = "tred_button";
      i.setAttribute('src', imgsrc);
      i.setAttribute('title', tooltip);
      i.setAttribute("onclick", "this.callback()");
      return i;
    }

    function addHeadButtons (expdiv) {

      var outOpacity = 0.0;

      var buttons = document.createElement('span');
      buttons.style.opacity = outOpacity;

      var root = findTredRoot(expdiv);

      expdiv.onmouseover = function () { 
        buttons.style.opacity = 1.0; 
        //var root = findTredRoot(expdiv);
        if (root.onOver) root.onOver(computeExpId(expdiv.parentNode));
      };
      expdiv.onmouseout = function () { 
        buttons.style.opacity = outOpacity; 
        //var root = findTredRoot(expdiv);
        if (root.onOver) root.onOver(null);
      };

      buttons.appendChild(createButton(
        FluoTred.imageRoot+'/btn-add.gif',
        'add a child expression',
        function () {
          FluoTred.addExpression(expdiv.parentNode, [ '---', {}, [] ]);
        }));

      if (expdiv.parentNode.parentNode != root) {

        buttons.appendChild(createButton(
          FluoTred.imageRoot+'/btn-cut.gif',
          'cut expression',
          function () {
            FluoTred.removeExpression(expdiv.parentNode);
          }));
        buttons.appendChild(createButton(
          FluoTred.imageRoot+'/btn-moveup.gif',
          'move expression up',
          function () {
            FluoTred.moveExpression(expdiv.parentNode, -1);
            buttons.style.opacity = outOpacity;
          }));
        buttons.appendChild(createButton(
          FluoTred.imageRoot+'/btn-movedown.gif',
          'move expression down',
          function () {
            FluoTred.moveExpression(expdiv.parentNode, +1);
            buttons.style.opacity = outOpacity;
          }));
        buttons.appendChild(createButton(
          FluoTred.imageRoot+'/btn-paste.gif',
          'paste expression here',
          function () {
            var clip = document._tred_clipboard;
            if (clip) FluoTred.insertExpression(expdiv.parentNode, clip);
          }));
      }

      expdiv.appendChild(buttons);
    }

    var headPattern = /^(\S*)( [.]*[^:]*)?( .*)?$/;
    var keyPattern = /([^ :]+|".*") *:/;

    function quoteKeys (s) {
      var ss = '';
      while (s) {
        var m = s.match(keyPattern);
        if ( ! m) {
          ss += s;
          break;
        }
        ss += s.substring(0, m.index - 1);
        var m1 = m[1].tstrip();
        if (m1.match(/^".*"$/)) ss += m1;
        else ss += ('"' + m1 + '"');
        ss += ':';
        s = s.substring(m.index + m[0].length);
      }
      return ss;
    }

    function renderAttributes (h) {
      s = '';
      for (var k in h) {
        s += ('' + k + ': ' + fluoToJson(h[k]) + ', ');
      }
      if (s.length > 1) s = s.substring(0, s.length - 2);
      return s;
    }

    return {

      render: function (node, exp) {

        var expname = exp[0];

        var text = '';
        if ((typeof exp[2][0]) == 'string') text = exp[2].shift();

        //var atts = fluoToJson(exp[1]);
        //atts = atts.substring(1, atts.length - 1);
        var atts = renderAttributes(exp[1]);

        var d = document.createElement('div');
        d.setAttribute('class', 'tred_exp');
        node.appendChild(d);

        var sen = document.createElement('span');
        sen.setAttribute('class', 'tred_exp_span tred_expression_name');
        sen.appendChild(document.createTextNode(expname));
        d.appendChild(sen);

        var ses = document.createElement('span');
        ses.setAttribute('class', 'tred_exp_span tred_expression_string');
        var t = text;
        if (t != '') t = ' ' + t;
        ses.appendChild(document.createTextNode(t));
        d.appendChild(ses);

        var sea = document.createElement('span');
        sea.setAttribute('class', 'tred_exp_span tred_expression_atts');
        sea.appendChild(document.createTextNode(' ' + atts));
        d.appendChild(sea);

        addHeadButtons(d);

        var onblur = function () {

          var p = d.parentNode;
          var d2 = ExpressionHead.render(p, ExpressionHead.parse(this.value));
          p.replaceChild(d2, d);

          triggerChange(p); // trigger onChange()...
        };

        var onkeyup = function (evt) {

          var e = evt || window.event;
          var c = e.charCode || e.keyCode;
          if (c == 13) this.blur();

          return false;
        }

        var onclick = function () {
          d.removeChild(sen);
          d.removeChild(ses);
          var input = document.createElement('input');
          input.setAttribute('type', 'text');
          input.value = expname + ' ' + atts;
          if (text != '') input.value = expname + ' ' + text + ' ' + atts;
          d.replaceChild(input, sea);
          input.onblur = onblur;
          input.onkeyup = onkeyup;
          input.focus();
        };

        sen.onclick = onclick;
        ses.onclick = onclick;
        sea.onclick = onclick;

        return d;
      },

      parseAttributes: function (s) {
        return fluoFromJson("{" + quoteKeys(s) + "}");
      },

      parse: function (s) {

        var m = s.match(headPattern);

        if (m == null) return [ '---', {}, [] ];

        var expname = m[1];

        var children = [];
        if (m[2]) {
          var t = m[2].tstrip();
          if (t.match(/".*"/)) t = t.substring(1, t.length - 1);
          if (t != '') children.push(t);
        }

        atts = ExpressionHead.parseAttributes(m[3]);

        return [ expname, atts, children ];
      },

      toExp: function (node) {

        node = node.firstChild;

        var name = node.childNodes[0].firstChild.nodeValue;
        var text = node.childNodes[1].firstChild.nodeValue;
        var atts = node.childNodes[2].firstChild.nodeValue;

        atts = ExpressionHead.parseAttributes(atts);

        var children = [];
        if (text != '') children.push(text.tstrip()); 
          // child is just a string...

        return [ name, atts, children ];
      }
    };
  }();

  function asJson (node) {

    if ((typeof node) == 'string') 
      node = document.getElementById(node);

    return fluoToJson(toTree(node));
  }

  function renderEnding (node, exp) {

    var ending = document.createElement('div');
    ending.className = 'tred_text';
    if (exp[2].length > 0) ending.appendChild(document.createTextNode('end'));
    node.appendChild(ending);
  }

  function renderExpressionString (node, s) {

    var opening = document.createElement('div');

    var sname = document.createElement('span');
    sname.appendChild(document.createTextNode(s));
    sname.setAttribute('onclick', 'EditableSpan.toInput(this);');
    sname.className = 'tred_expression_string';
    opening.appendChild(sname);

    node.appendChild(opening);
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

    document._tred_clipboard = toTree(expNode);

    triggerChange(p);
  }

  function renderExpression (parentNode, exp, isRootExp) {

    //
    // draw expression

    var node = document.createElement('div');
    node.className = 'tred_expression';

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

    parentNode.className = 'tred_root';

    renderExpression(parentNode, flow, true);

    parentNode.stack = []; // the undo stack
    parentNode.currentTree = flow;
  }

  function moveExpression (elt, delta) {

    var p = elt.parentNode;

    if (delta == -1) { // move up
      if (elt.previousSibling.className != 'tred_expression') return;
      p.insertBefore(elt, elt.previousSibling);
    }
    else { // move down
      if (elt.nextSibling.className != 'tred_expression') return;
      p.insertBefore(elt, elt.nextSibling.nextSibling);
    }

    FluoTred.triggerChange(p);
  }

  function insertExpression (before, exp) {

    var newNode = renderExpression(before.parentNode, exp);

    before.parentNode.insertBefore(newNode, before);

    FluoTred.triggerChange(before.parentNode);
  }

  function triggerChange (elt) {

    var tredRoot = findTredRoot(elt);
    var tree = toTree(tredRoot);

    stack(tredRoot, tree);

    //FluoTred.onChange(tree); 
    if (tredRoot.onChange) tredRoot.onChange(tree);
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

  function findTredRoot (node) {

      if (node.className == 'tred_root') return node;
      return findTredRoot(node.parentNode);
  }

  function computeExpId (node, from, expid) {

    if (from == null) {
      from = findTredRoot(node);
      expid = '';
    }
    if (from == node) return expid.substring(1, expid.length);

    var divs = from.childNodes;
    var childid = -1;

    for (var i=0; i<divs.length; i++) {
      var e = divs[i];
      if (e.nodeType != 1) continue;
      if (e.className != 'tred_expression') continue;
      childid += 1;
      var ei = computeExpId(node, e, expid + '.' + childid);
      if (ei != null) return ei;
    }

    return null;
  }

  function toTree (node) {

    node.focus();
      //
      // making sure all the input boxes get blurred...

    if (node.className != 'tred_expression') {
      node = node.firstChildOfClass('tred_expression');
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
      if (e.className != 'tred_expression') continue;
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

    ExpressionHead: ExpressionHead, // for testing purposes

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

