$().ready(function() {  
    $("#loginrm").validate({ 
        rules:{  
    		user:{  
                required: true
            },  
            password:{  
                required: true
            },  
            logincode:{  
            	required: true
            }
        },  
        messages:{  
        	user:{  
                required: "请填写用户名"  
            },  
            password:{  
                required: "请填写密码"  
            },  
            logincode:{  
            	required: "请填写验证码"
            }
        }  
    });  
});

function loadimage_login(){ 
	document.getElementById("randImage_login").src = "/nfwl/tools/image.jsp?"+Math.random(); 
	} 