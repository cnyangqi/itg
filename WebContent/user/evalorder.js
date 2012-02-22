function rate(obj,oEvent,_level){
var imgSrc = '/images/icon_star_1.gif';
var imgSrc_2 = '/images/icon_star_2.gif';
//if(obj.rateFlag) return;
var e = oEvent || window.event;
var target = e.target || e.srcElement; 
var imgArray = obj.getElementsByTagName("img");
for(var i=0;i<5;i++){
   imgArray[i]._num = i;
   imgArray[i].onclick=function(){

	
	
   };
}
if(target.tagName=="IMG"){
   for(var j=0;j<5;j++){
    if(j<=target._num){
     imgArray[j].src=imgSrc_2;
     document.getElementById(_level).value=(j+1);
    } else {
     imgArray[j].src=imgSrc;
    } 
   }
} else {
   for(var k=0;k<5;k++){
    imgArray[k].src=imgSrc;
   }
}
}
function   check(obj){ 
	if   (obj.value.length> 100){ 
		return   false; 
	} 
		return   true; 
	} 


$().ready(function() {  
    $("#evalfrm").validate({ 
        rules:{  
    		me_content:{  
                required: true,  
                CNminlength: 5,  
                CNmaxlength: 250  
            }
        },  
        messages:{  
        	me_content:{  
                required: "请填写详细信息",  
                CNminlength: "字符长度不能小于5",  
                CNmaxlength: "字符长度不能大于250"  
            }
        }  
    }); 
});
