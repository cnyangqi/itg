$(function() {
  $("#inputFrm").validate({
    /*自定义验证规则*/
    rules : {
      "fp_name" : {
      required : true
      },
 

      fp_code : {
        required : true,
        minlength : 6
      },
      fp_email : {
        required : true,
        email : true
      }
    },
    /*错误提示位置*/
    errorPlacement : function(error, element) {
			//error.appendTo
			
      error.appendTo(element.siblings("span"));
    }
  });
});

$(function() {
	$("#fp_name").change(function() {  
	  //$("#fp_name").validate().form()
	
	  $("#inputFrm").validate().element("#fp_code"); 



	});
}
);



function fill_check() {

  if (!CheckIsNull('document.inputFrm', 'fp_name')) {
    alert("请输入单位名称");
    return false;
  }

  if (!CheckIsEnCode('document.inputFrm', 'fp_code')) {
    alert("请输入正确的单位代码（只能包含英文和数字）");
    return false;
  }
  if (!CheckIsEmail('document.inputFrm', 'fp_email')) {
    alert("请输入正确的电子邮件");
    return false;
  }

  return true;
}

function save() {
	
//valid( ) Returns: Boolean 
//var frm = $("#inputFrm");
//var frm = document.inputFrm;
//validate().form()
//if($("#inputFrm").validate()){

	//$('inputFrm').form();
//debugger;
	//validate(frm);

//if($("#inputFrm").validate().form()){
	//alert("true");
//}else{
	//alert("false");
//}

  if (!fill_check())
    return;
  document.inputFrm.act.value = 0;
  //document.forms[0].submit();
  document.inputFrm.submit();
}