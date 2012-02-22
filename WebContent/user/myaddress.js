$().ready(function() {  
        $("#addressForm").validate({ 
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
                },
                adr_email: {  
                    required: true,
                    email:4   
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
                },
                adr_email:{  
                	required: "请填写emial",
                	email: "emial格式不正确"                     
                }
            }  
        });  
    });
function view(id){
	var _tempform = $("#tempform");
	_tempform.find('[name=cmd]').val("view"); 
	_tempform.find('[name=id]').val(id);
	_tempform.submit();
}
function del(id){
	var _tempform = $("#tempform");
	_tempform.find('[name=cmd]').val("delete"); 
	_tempform.find('[name=id]').val(id); 
	_tempform.submit();
}
function setdefault(id){
	var _tempform = $("#tempform");
	_tempform.find('[name=cmd]').val("setdefault"); 
	_tempform.find('[name=id]').val(id);
	_tempform.submit();
}