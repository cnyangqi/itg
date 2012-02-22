 $().ready(function() {  
        $("#cartAddressfrm").validate({ 
            rules:{
        		adr_name:{  
                    required: true,  
                    CNminlength: 2,  
                    CNmaxlength: 20  
                },  
                adr_detail:{  
                    required: true,  
                    CNmaxlength: 50  
                },
                adr_postcode:{  
                    required: true,  
                    CNminlength:6,
                    CNmaxlength:6  
                },  
                adr_mobile:{  
                	required: true,  
                    isMobile: true  
                },
                adr_email: {  
                    required: true,
                    email:true   
                },
                adr_areacode: {  
                    required: true,
                    number:true,  
					CNmaxlength:4   
                },  
                adr_telephone:{  
                	required: true,
                    number:true,  
					CNmaxlength:10  
                },
                adr_subnum:{  
                	number:true, 
                	CNmaxlength:3   
                }
            },  
            messages:{  
            	adr_name:{  
                    required: "请填写收货人",  
                    CNminlength: "字符长度不能小于2",  
                    CNmaxlength: "字符长度不能大于20"  
                },  
                adr_detail:{  
                    required: "请填写详细地址",  
                    CNminlength: "字符长度不能大于50"  
                }, 
                adr_postcode:{  
                    required: "请填写邮编",  
                    CNminlength: "邮编填写不正确",
                    CNminlength: "邮编填写不正确"  
                }, 
                adr_mobile:{  
                    required: "请填写手机",  
                    date: "你填的手机不正确"  
                },  
                adr_email:{  
                	required: "请填写emial",
                	email: "emial格式不正确"                     
                },
                adr_areacode:{  
                    required: "请填写电话区号",
                    number: "电话区号必须为数字",
                    CNmaxlength: "电话区号不能大于4"     
                },  
                adr_telephone:{  
                	required: "请填写电话",
                    number: "电话必须为数字",
                    CNmaxlength: "电话不能大于10"
                }, 
                adr_subnum:{  
                	number: "电话分机号必须为数字",  
                	CNmaxlength: "电话分机号不能大于3"  
                }
            }  
        });  
    });  
function cartAddressfrmSubmit(){
	//var item = $('input[@name=items][@checked]').val();
	//alert($("#chk_adr_other:checked").val());
	//alert($("#chk_adr_other").attr("checked").val());
	var _flag=false;
	$("input[name='adr_id']").each(function(){
		if(this.checked){
			_flag=true;
			return;
		}
	});
	if(!_flag){
		alert("必须选择一个地址!");
		return;
	}
	
	if($("#fiexdpointRadio:checked").val()!=null){
		$("#adr_detail").rules("remove");
		$("#adr_postcode").rules("remove");
		$("#adr_name").rules("remove"); 
		$("#adr_mobile").rules("remove");
		$("#adr_email").rules("remove");
		$("#adr_areacode").rules("remove");
		$("#adr_telephone").rules("remove");
		$("#adr_subnum").rules("remove");
	}
	$("#cartAddressfrm").submit();
}
function chk_adr_click(obj,detail,postcode,name,mobile,email,areacode,telephone,subnum,zone ){
	var _id='ul_'+obj.value;
	$("ul[name='ul_adr']").each(function(){
		
		if(this.id==_id){
			//alert(this.id);
			$("#"+this.id).addClass("dz");
		}else{
			$("#"+this.id).removeClass("dz");
		}
	});
	$("#adr_detail").val(detail);
	$("#adr_postcode").val(postcode);
	$("#adr_name").val(name); 
	$("#adr_mobile").val(mobile);
	$("#adr_email").val(email);
	$("#adr_areacode").val(areacode);
	$("#adr_telephone").val(telephone);
	$("#adr_subnum").val(subnum);
	if(zone!='')chageZone(zone);
}
function chageZone(id){
	var count=$("select[name='adr_zone'] option").length;
	for(var i=0;i<count;i++)  
	{
		if($("select[name='adr_zone']").get(0).options[i].value == id){  
			$("select[name='adr_zone']").get(0).options[i].selected = true;  
			break;  
		}
	} 
}