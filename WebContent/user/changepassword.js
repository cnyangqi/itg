$().ready(function() {  
    $("form[name=userForm]").validate({ 
        rules:{  
    		oldpassword:{  
                required: true
            },  
            password:{  
                required: true, 
                minlength: 6                  
            },  
            password1:{  
            	equalTo: "#password"
            }
        },  
        messages:{  
        	oldpassword:{  
                required: "请填写旧密码",  
            },  
            password:{  
                required: "请填写新密码",  
                minlength: "字符长度不能小于6"  
            },  
            password1:{  
            	equalTo: "两次密码不一样"
            }
        }  
    });  
});