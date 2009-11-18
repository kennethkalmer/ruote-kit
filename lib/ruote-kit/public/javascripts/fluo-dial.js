
/*
 *  OpenWFEru - open source ruby workflow and bpm engine
 *  (c) 2008 John Mettraux
 *
 *  OpenWFEru is freely distributable under the terms 
 *  of a BSD-style license.
 *  For details, see the OpenWFEru web site: http://openwferu.rubyforge.org
 *
 *  Made in Japan
 */

//
// example usage :
//
//    var d = FluoDial.newDialog
//        ("upload new version of expression (as YAML file)", 500, 105);
//
//    var f = new Element
//        ("form", { "method": "POST", "enctype": "multipart/form-data" });
//    var fi = new Element
//        ("input", { "type": "file", "name": "expression", "size": "50" });
//    var si = new Element
//        ("input", { "type": "submit", "value": "upload" });
//    f.appendChild(fi);
//    f.appendChild(si);
//    d.body.appendChild(f);
//

var FluoDial = function() {

  //
  // private methods

  function resizeItem (id, width, height) {
    var item = $(id);
    item.setStyle({ "width": ""+width+"px" });
    item.setStyle({ "height": ""+height+"px" });
  }

  function centerItem (id) {

    var item = $(id);

    var w = item.getDimensions()["width"];
    var h = item.getDimensions()["height"];

    if (centerItem.arguments.length > 1) {
      w = centerItem.arguments[1];
      h = centerItem.arguments[2];
    }

    var l = (window.innerWidth - w) / 2;
    var t = (window.innerHeight - h) / 2;

    item.setStyle({ "left": ""+l+"px" });
    item.setStyle({ "top": ""+t+"px" });
  }

  function resizeAndCenterItem (id, width, height) {

    resizeItem(id, width, height);
    centerItem(id, width, height);
  }

  function newRectangle (id, cclass, width, height) {

    var r = $(id);

    if (r) {
      r.childElements().each(function (elt) {
        elt.remove();
      });
      r.show();
    }
    else {
      r = new Element("div", { "id": id, "class": cclass });
    }

    resizeAndCenterItem(r, width, height);

    return r;
  }

  function newDialog (title, width, height) {
  
    var sheet = newRectangle
      ("dial_sheet", "dial_sheet", width, height);
    var dialog = newRectangle
      ("dial_dialog", "dial_dialog", width-20, height-20);

    document.body.appendChild(sheet);
    document.body.appendChild(dialog);

    var header = new Element
      ("div", { "class": "dial_header" });
    var body = new Element
      ("div", { "id": dialog.id+"_body", "class": "dial_body" });

    dialog.appendChild(header);
    dialog.appendChild(body);

    dialog.header = header;
    dialog.body = body;

    dialog.close = function () {
      sheet.hide();
      dialog.hide();
    };
    dialog.show = function () {
      sheet.show();
      dialog.show();
    };
    dialog.resize = function (w, h) {
      resizeAndCenterItem(sheet, w, h);
      resizeAndCenterItem(dialog, w-20, h-20);
    };
    dialog.stealElement = function (el) {
      if ( ! (el instanceof HTMLElement)) el = document.getElementById(el);
      this.body.appendChild(el);
      //el.parentNode = dialog.body;
    }

    var htitle = new Element("div", { "class": "dial_title" });
    htitle.appendChild(document.createTextNode(title));
    header.appendChild(htitle);

    var hmenu = new Element("div", { "class": "dial_menu" });
    var hclose = new Element
      ("a", 
       { "href": "#", 
         "title": "close this dialog",
         "onclick": "$('dial_dialog').close(); return false;" });
    hclose.innerHTML = "close";
    hmenu.appendChild(hclose);
    header.appendChild(hmenu);

    return dialog;
  }

  return {

    //
    // public methods

    newDialog: newDialog
  };
}();

