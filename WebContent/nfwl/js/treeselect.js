
document.onclick=hiddenDiv; 
var treeDivHeight = new Array();
  
function getL(e){
 var l=e.offsetLeft;
 while(e=e.offsetParent){
  l+=e.offsetLeft;
 }
 return l;
}
function getT(e){
 var t=e.offsetTop;
 while(e=e.offsetParent){
 t+=e.offsetTop;
 }
 return t
}
var currDivNum=0;
function toBig(num){
   var tDiv=document.all["TreeDiv_"+num];
 if(  tDiv.style.display=='none' ){
    hiddenAllDiv();
    return;
  }
 tDiv.style.pixelWidth= tDiv.style.pixelWidth+250;
}
      
function dropDown( num){ 

 var tDiv=document.all["TreeDiv_"+num];
hiddenAllDiv(num);

 
 if(tDiv.style.display=='none'){  
  tDiv.style.display='';  
  getPosition(num);  
  currDivNum=num;
 } else {  
  tDiv.style.display='none';

 }
}

function getPosition(idStr){ 
 var tDiv=document.all["TreeDiv_"+idStr];
 var vField=document.all["TextField_"+idStr];
 var fieldSpan=document.all["ValueFieldSpan_"+idStr];


 tDiv.style.pixelWidth=fieldSpan.offsetWidth;//这个数是数值的DIV的宽度数。。。
// da.style.pixelWidth=sv.offsetWidth;
 tDiv.style.pixelLeft=getL(fieldSpan);//这个数是数值的DIV的TOP位置数中X轴的数。。。
 tDiv.style.pixelTop=getT(fieldSpan)+vField.offsetHeight+2;//这个数是这个数是数值的DIV的TOP位置数中Y轴的数。。。

tDiv.style.pixelHeight=treeDivHeight[idStr];
tDiv.style.overflowY='auto';
tDiv.style.overflowX='auto';

}
var TreeSelectCount=0;
function add(v,ID){
TreeSelectCount++;


}
function hiddenAllDiv(num){


  for (j=0;j<getDivCount();j++) {
if(j!=num){
  var currDiv=document.getElementById('TreeDiv_'+j);
  if(currDiv.style.display!='none'){   
  currDiv.style.display='none';  
}
  } 
  }
  

}
function hiddenDiv(){
 var o=window.event.srcElement.id;
if(o.indexOf("TextField_")==0||o.indexOf("TreeDiv_")==0||o.indexOf("BigButton")==0||o.indexOf("webfx-tree-object")==0||o.indexOf("SelectButton")==0){return;}else{

  for (j=0;j<getDivCount();j++) {
  var currDiv=document.getElementById('TreeDiv_'+j);   
  if(currDiv.style.display!='none'){   
  currDiv.style.display='none';  
}  
 }

 }

}//隐藏模拟层
function getDivCount() {
  for(var i=0;;i++){
    var currDiv=eval("document.all.TreeDiv_"+i);
    if(currDiv==null||currDiv=='undefine'){

      return i;
    }
  }

}
//增加inpnubox的接口,在页面中产生一个inputbox控件,下拉列表为空
function clearTreeSelect(idStr){
             var textNode=document.all["TextField_"+idStr]; 
           var textNode=document.all["ValueField_"+idStr];
}
function hiddenTreeSelect(idStr){
   var textNode=document.all["ValueFieldSpan_"+idStr];
   textNode.style.display='none'; 
}
function displayTreeSelect(idStr){
  
     var textNode=document.all["ValueFieldSpan_"+idStr];
   textNode.style.display=''; 
}
function disableTreeSelect(idStr,isEnable){

     var spanNode=document.all["ValueFieldSpan_"+idStr];
     var selectButtonNode=document.all["SelectButton_"+idStr];  
         var bigButtonNode=document.all["BigButton_"+idStr];    
               var textNode=document.all["TextField_"+idStr]; 

spanNode.disabled=isEnable;
   selectButtonNode.disabled=isEnable;  
   bigButtonNode.disabled=isEnable; 
   textNode.disabled=isEnable;  
}
function setTreeSelectValue(idStr,value,name){
  
       var textNode=document.all["TextField_"+idStr]; 
           var valueNode=document.all["ValueField_"+idStr]; 
       textNode.value=name;
       valueNode.value=value;
}


function CreateTreeSelect(name,tree,DefText,DefValue,tdHeight) {
  

var i=getDivCount();
if(tdHeight!=null){
treeDivHeight[i]=tdHeight;
}else{
  treeDivHeight[i]=180;
}

var textName=name+"_Text";
var floorName=name+"_Floor";
 document.write("<input id='FloorField_"+i+"' type='hidden' name='"+floorName+"' value='-1'>");
 document.write("<input id='ValueField_"+i+"' type='hidden' name='"+name+"' value='"+DefValue+"'>");
 document.write('<span  id="ValueFieldSpan_'+i+'" style="border:1 solid #9CA0CB;">');
 document.write('<input type="text"   readonly onclick="this.hideFocus=true;dropDown('+i+');" value="'+DefText+'" name="'+textName+'" id="TextField_'+i+'" class="ValueFieldClass" ><input type=hidden id="BigButton_'+i+'" value="◢" onclick="this.hideFocus=true;toBig('+i+');" class="SelectTreeButtonMouseOut"  onmouseout="this.style.backgroundColor=\'\'"  onmouseup="this.style.backgroundColor=\'\'" ></span>');
   //document.write('<input type="text" value="'+DefText+'" name="'+textName+'" id="TextField_'+i+'" class="ValueFieldClass" ><input type=button id="SelectButton" value="a" class="SelectButtonClass" onclick="this.hideFocus=true;dropDown('+i+');" onmouseup="this.style.backgroundColor=\'\'" onmouseout="this.style.backgroundColor=\'\'"></span>');
 document.write("<div id='TreeDiv_"+i+"' class='seldiv'  style='display:none;background-color:#D0DFF7;'>");
document.write(tree);
document.write('</div>');
}
