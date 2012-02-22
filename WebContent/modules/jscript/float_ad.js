var adFloat = Class.create();
adFloat.prototype = {initialize:function(div_id, left, top, float_left,delay) {
    this.div_id = div_id;
    this.adPosition = {left:left,top:top};
    this.delay = delay;
    var div = $(this.div_id);
    var width = div.getWidth();
    div.style.position = "absolute";
    if (float_left) {
        div.style.left = left + "px";
    } else {
        div.style.left = (document.documentElement.clientWidth - width - left) + "px";
        window.onresize = function() {
            $(this.div_id).style.left = (document.documentElement.clientWidth - width - 8) + "px";
        }.bind(this);
    }
    div.style.top = top + "px";
    this.interId = setInterval(this.scroll.bind(this), this.delay);
},
scroll:function() {
    var div = $(this.div_id);
    this.stmnStartPoint = parseInt(div.style.top);
    this.stmnEndPoint = document.documentElement.scrollTop + this.adPosition.top;
    if (navigator.userAgent.indexOf("Chrome") > 0) {
        this.stmnEndPoint = document.body.scrollTop + this.adPosition.top;
    }
    if (this.stmnStartPoint != this.stmnEndPoint) {
        this.stmnScrollAmount = Math.ceil(Math.abs(this.stmnEndPoint - this.stmnStartPoint) / 15);
        div.style.top = parseInt(div.style.top) + ( ( this.stmnEndPoint < this.stmnStartPoint ) ? -this.stmnScrollAmount : this.stmnScrollAmount ) + "px";
    }
},
stop:function() {
    clearInterval(this.interId);
},
start:function() {
    this.interId = setInterval(this.scroll.bind(this), this.delay);
}};

var adMove = Class.create();
adMove.prototype = {initialize:function(div_id, left, top, delay) {
    this.div_id = div_id;
    this.adPosition = {left:left,top:top};
    this.delay = delay;
    this.step = 1;
    this.herizonFlag = true;
    this.verticleFlag = true;
    var div = $(this.div_id);
    div.style.position = "absolute";
    div.style.left = this.adPosition.left;
    div.style.top = this.adPosition.top;
    div.style.zIndex = 100;
    this.intervalId = setInterval(this.scroll.bind(this), this.delay);
    div.onmouseover = this.stop.bind(this);
    div.onmouseout = this.start.bind(this);
},
scroll:function() {
    var div = $(this.div_id);
    var L = T = 0;
    var B = document.documentElement.clientHeight - div.offsetHeight;
    var R = document.documentElement.clientWidth - div.offsetWidth;
    div.style.left = this.adPosition.left + document.documentElement.scrollLeft + "px";
    div.style.top = this.adPosition.top + document.documentElement.scrollTop + "px";
    this.adPosition.left = this.adPosition.left + this.step * (this.herizonFlag ? 1 : -1);
    if (this.adPosition.left < L) {
        this.herizonFlag = true;
        this.adPosition.left = L;
    }
    if (this.adPosition.left > R) {
        this.herizonFlag = false;
        this.adPosition.left = R;
    }
    this.adPosition.top = this.adPosition.top + this.step * (this.verticleFlag ? 1 : -1);
    if (this.adPosition.top <= T) {
        this.verticleFlag = true;
        this.adPosition.top = T;
    }
    if (this.adPosition.top >= B) {
        this.verticleFlag = false;
        this.adPosition.top = B;
    }
},
stop:function() {
    clearInterval(this.intervalId);
},
start:function() {
    this.intervalId = setInterval(this.scroll.bind(this), this.delay);
}};