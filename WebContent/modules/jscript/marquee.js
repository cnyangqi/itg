var Marquee = Class.create();
Marquee.prototype = {initialize:function(id) {
    this.id = id;
    this.div = $(id);
    this.Width = Element.getWidth(this.div);
    this.Height = Element.getHeight(this.div);
	this.Direction = 0;
    this.DelayTime = 0;
    this.WaitTime = 0;
    this.CTL = 0;
    this.stopped = 0;
    this.MouseOver = 0;
	this.Step = 1;
	this.Timer = 30;
	this.DirectionArray = {"top":0 , "up":0 , "bottom":1 , "down":1 , "left":2 , "right":3};
	this.div.style.overflow = this.div.style.overflowX = this.div.style.overflowY = "hidden";
	this.div.noWrap = true;
	this.IsNotOpera = (navigator.userAgent.toLowerCase().indexOf("opera") == -1);
},start:function() {
    this.div = $(this.id);
    if(this.div==null) return;
    if(this.WaitTime < 800) this.WaitTime = 800;
	if(this.Timer < 20) this.Timer = 20;
	if(typeof this.Direction == "string") this.Direction = this.DirectionArray[this.Direction.toString().toLowerCase()];
	this.HalfWidth = Math.round(this.Width / 2);
	this.HalfHeight = Math.round(this.Height / 2);
	this.BakStep = this.Step;
	this.div.style.width = this.Width + "px";
	this.div.style.height = this.Height + "px";
	if(typeof this.ScrollStep != "number") this.ScrollStep = this.Direction > 1 ? this.Width : this.Height;
	var templateLeft = "<table cellspacing='0' cellpadding='0' style='border-collapse:collapse;display:inline;'><tr><td noWrap=true style='white-space: nowrap;word-break:keep-all;'>MARQUEE_TEMP_HTML</td><td noWrap=true style='white-space: nowrap;word-break:keep-all;'>MARQUEE_TEMP_HTML</td></tr></table>";
	var templateTop = "<table cellspacing='0' cellpadding='0' style='border-collapse:collapse;'><tr><td>MARQUEE_TEMP_HTML</td></tr><tr><td>MARQUEE_TEMP_HTML</td></tr></table>";
	this.tempHTML = this.div.innerHTML;
	if(this.Direction <= 1) {
		this.div.innerHTML = templateTop.replace(/MARQUEE_TEMP_HTML/g,this.div.innerHTML);
	} else {
		if(this.ScrollStep == 0 && this.DelayTime == 0) {
			this.div.innerHTML += this.div.innerHTML;
		} else {
			this.div.innerHTML = templateLeft.replace(/MARQUEE_TEMP_HTML/g,this.div.innerHTML);
		}
	}
	setTimeout(this._begin.bind(this),this.WaitTime);
},scroll:function() {
    this.div = $(this.id);
    if(this.div==null) return;
    switch(this.Direction) {
		case 0:
			this.CTL += this.Step;
			if(this.CTL >= this.ScrollStep && this.DelayTime > 0) {
				this.div.scrollTop += this.ScrollStep + this.Step - this.CTL;
				this._pause();
				return;
			} else {
				if(this.div.scrollTop >= this.ClientScroll)  this.div.scrollTop -= this.ClientScroll;
				this.div.scrollTop += this.Step;
			}
		break;

		case 1:
			this.CTL += this.Step;
			if(this.CTL >= this.ScrollStep && this.DelayTime > 0) {
				this.div.scrollTop -= this.ScrollStep + this.Step - this.CTL;
				this._pause();
				return;
			} else {
				if(this.div.scrollTop <= 0) {
					this.div.scrollTop += this.ClientScroll;
				}
				this.div.scrollTop -= this.Step;
			}
		break;

		case 2:
			this.CTL += this.Step;
			if(this.CTL >= this.ScrollStep && this.DelayTime > 0) {
				this.div.scrollLeft += this.ScrollStep + this.Step - this.CTL;
				this._pause();
				return;
			} else {
				if(this.div.scrollLeft >= this.ClientScroll) this.div.scrollLeft -= this.ClientScroll;

				this.div.scrollLeft += this.Step;
			}
		break;

		case 3:
			this.CTL += this.Step;
			if(this.CTL >= this.ScrollStep && this.DelayTime > 0) {
				this.div.scrollLeft -= this.ScrollStep + this.Step - this.CTL;
				this._pause();
				return;
			} else {
				if(this.div.scrollLeft <= 0) this.div.scrollLeft += this.ClientScroll;
				this.div.scrollLeft -= this.Step;
			}
		break;
	}
},_continue:function() {
    if(this.MouseOver == 1)
    {
        setTimeout(this._continue.bind(this),this.DelayTime);
    }
    else
    {	clearInterval(this.TimerID);
        this.CTL = this.stopped = 0;
        this.TimerID = setInterval(this.scroll.bind(this),this.Timer);
    }
},_pause:function() {
    this.stopped = 1;
    clearInterval(this.TimerID);
    setTimeout(this._continue.bind(this),this.DelayTime);
},stop:function() {
    this.stopped = 1;
    clearInterval(this.TimerID);
},_begin:function() {
    this.div = $(this.id);
    if(this.div==null) return;    
    this.ClientScroll = this.Direction > 1 ? this.div.scrollWidth / 2 : this.div.scrollHeight / 2;
    if((this.Direction <= 1 && this.ClientScroll <= this.Height + this.Step) || (this.Direction > 1 && this.ClientScroll <= this.Width + this.Step))
    {
        this.div.innerHTML = this.tempHTML;
        delete(this.tempHTML);
        return;
    }
    delete(this.tempHTML);
    this.TimerID = setInterval(this.scroll.bind(this),this.Timer);
    if(this.ScrollStep < 0) return;
    this.div.onmousemove = function(event) {
        if(this.ScrollStep == 0 && this.Direction > 1)
        {
            var event = event || window.event;
            if(window.event) {
                if(this.IsNotOpera) {
                    this.EventLeft = event.srcElement.id == this.div.id ? event.offsetX - this.div.scrollLeft : event.srcElement.offsetLeft - this.div.scrollLeft + event.offsetX;
                } else {
                    this.ScrollStep = null;
                    return;
                }
            } else {
                this.EventLeft = event.layerX - this.div.scrollLeft;
            }
            this.Direction = this.EventLeft > this.HalfWidth ? 3 : 2;
            this.AbsCenter = Math.abs(this.HalfWidth - this.EventLeft);
            this.Step = Math.round(this.AbsCenter * (this.BakStep*2) / this.HalfWidth);
        }
    }
    this.div.onmouseover = function() {
        if(this.ScrollStep == 0)return;
        this.MouseOver = 1;
        clearInterval(this.TimerID);
    }
    this.div.onmouseout = function() {
        if(this.ScrollStep == 0) {
            if(this.Step == 0)this.Step = 1;
            return;
        }
        this.MouseOver = 0;
        if(this.stopped == 0) {
            clearInterval(this.TimerID);
            this.TimerID = setInterval(this.scroll.bind(this),this.Timer);
        }
    }
}};