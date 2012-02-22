
//验证是否为空,如果为空返回 false,否则返回 true 
function CheckIsNull(Inform,Inputname){ 
    var Form=Inform+"." ;
 eval("Temp="+Form+Inputname+".value;"); 
 if(Temp==""){ 
  //alert("提醒您:不能为空"); 
  eval(Form+Inputname+".className='RedInput';"); 
  eval(Form+Inputname+".focus();"); 
  return false; 
 }else{ 
  eval(Form+Inputname+".className="+Form+Inputname+".className.replace('RedInput','');"); 
     return true; 
 } 
} 
//验证是否为数字 
function CheckIsNum(Inform,Inputname){ 
    if (!CheckIsNull(Inform,Inputname))return false; 
 else{ 
          var Form=Inform+"." ;
          eval("Temp="+Form+Inputname+".value;"); 
       if(isNaN(Temp)){ 
                     //alert("提醒您:不为数字"); 
                     eval(Form+Inputname+".className='RedInput';"); 
                     eval(Form+Inputname+".focus();"); 
                     return false; 
                      } 
    else{ 
         eval(Form+Inputname+".className="+Form+Inputname+".className.replace('RedInput','');"); 
            return true; 
           } 
     } 
}
//验证是否为英文CODE

function CheckIsEnCode(Inform,Inputname){
  if (!CheckIsNull(Inform,Inputname))return false; 
  else{ 
     var Form=Inform+"." ;
        eval("Temp="+Form+Inputname+".value;"); 
        for( var i=0; i < Temp.length; i++)
        {
           var ch = Temp.charAt(i);
           if( ( ch>='a'&& ch <= 'z') || (ch >='A' && ch <='Z' ) || (ch >='0' && ch <='9') || ch == '_' || ch == '-' )
           {

           }
           else
           {
             eval(Form+Inputname+".focus();"); 
             return false;
           }
        }
        return true;
  }
}

//验证是否为E-MAIL 
function CheckIsEmail(Inform,Inputname){
    if (!CheckIsNull(Inform,Inputname))return true; 
    else{ 
       var Form=Inform+"." ;
          eval("Temp="+Form+Inputname+".value;"); 
       if(Temp.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/)==-1) 
         {
           //{ alert("提醒您:不为EMAIL"); 
             eval(Form+Inputname+".className='RedInput';"); 
             eval(Form+Inputname+".focus();"); 
             return false; }
               
    else{         eval(Form+Inputname+".className="+Form+Inputname+".className.replace('RedInput','');"); 
             return true; 
        }
    }
} 
//验证是否为HTTP地址 
function CheckIsHttp(Inform,Inputname){ 
    if (!CheckIsNull(Inform,Inputname))return false; 
    else{  
         var Form=Inform+"." 
   eval("Temp="+Form+Inputname+".value;"); 
   if(Temp.search(/^http:\/\/([\w-]+\.)+[\w-]+(\/[\w- .\/?%&=]*)?/)==-1) 
         { //alert("提醒您:不为HTTP"); 
             eval(Form+Inputname+".className='RedInput';"); 
             eval(Form+Inputname+".focus();"); 
             return false; 
              } 
      else{ 
           eval(Form+Inputname+".className="+Form+Inputname+".className.replace('RedInput','');"); 
              return true; 
         } 
      } 
} 
//验证是否为手机号码 
function CheckIsMobile(Inform,Inputname){ 
    if (!CheckIsNull(Inform,Inputname))return false; 
    else{ 
   var Form=Inform+"." ;
   eval("Temp="+Form+Inputname+".value;"); 
   if(Temp.search(/^1[3|5]\d{9}$/)==-1) 
   {   //alert("提醒您:不为手机号码"); 
    eval(Form+Inputname+".className='RedInput';"); 
    eval(Form+Inputname+".focus();"); 
    return false; 
   } 
   else{ 
            eval(Form+Inputname+".className="+Form+Inputname+".className.replace('RedInput','');"); 
               return true; 
        } 
         } 
} 
