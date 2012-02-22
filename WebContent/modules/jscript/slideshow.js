var ImageSlider = Class.create();
ImageSlider.prototype = {initialize:function(id,target) {
    this.id = id;
    this.target = target;
    this.interv = 3000; //切换间隔时间
    this.interv2 = 0; //切换速度
    this.opac1 = 95; //文字背景的透明度
    this.photoData = new Object();
    this.photoOrder = new Array();
    this.resources = {slider_box:"slider_box_" + this.id,photo_layer:"slider_photo_" + this.id,titlebar:"slider_titlebar_" + this.id,titlespan:"slider_title_" + this.id,buttonbar:"slider_buttonbar_" + this.id};
    this.state = {};
},addImage:function(rec) {
    this.photoData[rec.id] = rec;
    this.photoOrder.push(rec.id);
},clear:function() {
    delete this.photoData;
    this.photoData = new Object();
    this.photoOrder.clear();
},_getImageHtml:function(id) {
    var rec = this.photoData[id];
    var img_html = "";
    if(rec.open_url!="") {
        img_html += "<a href='" + rec.open_url + "'";
        if(this.target!="") {
            img_html += " target='" + this.target + "'";
        }
        img_html += ">";
    }

    img_html += "<img src='" + rec.img_url + "'";
    if(this.border=="1") {
        img_html += " border=1";
    }else {
        img_html += " border=0";
    }
    img_html += " alt='" + rec.img_title + "'>";

    if(rec.open_url!="") {
        img_html += "</a>";
    }

    return img_html;
},_alpha: function(obj, n) {
    if (document.all) {
        obj.style.filter = "alpha(opacity=" + n + ")";
    } else {
        obj.style.opacity = (n / 100);
    }
}, _renderbuttonbar:function(n) {
    var buttonbar = $(this.resources.buttonbar);
    for (var i = 0; i < this.photoOrder.length; i++) {
        buttonbar.childNodes[i].className = "slider_button";
    }
    buttonbar.childNodes[n].className = "slider_button slider_selected";
},_fadeon:function() {
    var photo_layer = $(this.resources.photo_layer);
    var titlespan = $(this.resources.titlespan);
    this.state.opac += 5;
    photo_layer.innerHTML = this._getImageHtml(this.photoOrder[this.state.j]);
    titlespan.innerHTML = this.photoData[this.photoOrder[this.state.j]].img_title;
    this._alpha(photo_layer, this.state.opac);
    if (this.state.scton == 0) {
        this._renderbuttonbar(this.state.j);
        this.state.num = -2;
        this._scrolltxt();
        this.state.scton = 1;
    }

    if (this.state.opac < 100) {
        this.timer = setTimeout(this._fadeon.bind(this), this.interv2)
    } else {
        this.timer2 = setTimeout(this._fadeout.bind(this), this.interv);
    }
},_fadeout:function() {
    var photo_layer = $(this.resources.photo_layer);
    this.state.opac -= 5;
    photo_layer.innerHTML = this._getImageHtml(this.photoOrder[this.state.j]);;
    this._alpha(photo_layer, this.state.opac);
    if (this.state.scton == 0) {
        this.state.num = 2;
        this._scrolltxt();
        this.state.scton = 1;
    }

    if (this.state.opac > 0) {
        this.timer = setTimeout(this._fadeout.bind(this), this.interv2);
    } else {
        if (this.state.j < this.photoOrder.length - 1) {
            this.state.j++;
        } else {
            this.state.j = 0;
        }

        this._fadeon();
    }
},_scrolltxt:function() {
    var titlespan = $(this.resources.titlespan);
    this.state.t += this.state.num;
    titlespan.style.marginTop = this.state.t + "px";
    if (this.state.num < 0 && this.state.t > 3) {
        this.timer3 = setTimeout(this._scrolltxt.bind(this), this.interv2);
    } else if (this.state.num > 0 && this.state.t < 62) {
        this.timer3 = setTimeout(this._scrolltxt.bind(this), this.interv2);
    } else {
        this.state.scton = 0;
    }
},render:function() {
    this.state.opac = 0;
    this.state.j = 0;
    this.state.t = 63;
    this.state.num = 0;
    this.state.scton = 0;

    var div = $(this.resources.slider_box);
    var photo_layer = $(this.resources.photo_layer);
    div.appendChild(photo_layer);

    var titlebar = $(this.resources.titlebar);
    var buttonbar = $(this.resources.buttonbar);
    buttonbar.innerHTML = '';
    var slider_obj = this;
    for (var i = 0; i < this.photoOrder.length; i++) {
        var a = document.createElement("a");
        a.innerHTML = i + 1;
        a.onclick = function() {
            clearTimeout(slider_obj.timer);
            clearTimeout(slider_obj.timer2);
            clearTimeout(slider_obj.timer3);
            slider_obj.state.j = parseInt(this.innerHTML) - 1;
            slider_obj.state.scton = 0;
            slider_obj.state.t = 63;
            slider_obj.state.opac = 0;
            slider_obj._fadeon();
        };
        a.className = "slider_button";
        a.onmouseover = function() {
            this.className = "slider_button slider_selected";
        };
        a.onmouseout = function() {
            this.className = "slider_button";
            slider_obj._renderbuttonbar(slider_obj.state.j);
        };
        buttonbar.appendChild(a);
    }

    var titlespan = $(this.resources.titlespan);
    titlebar.appendChild(titlespan);
    titlebar.appendChild(buttonbar);
    this._alpha(titlebar, this.opac1);

    div.appendChild(titlebar);

    this._fadeon();
},stop:function() {
    clearTimeout(this.timer);
    clearTimeout(this.timer2);
    clearTimeout(this.timer3);
}};
