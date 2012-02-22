$().ready(function() {  
    $("form[name=chargercfrm]").validate({ 
        rules:{  
    		cardno:{  
    			required: true
            },  
            cardpwd:{  
                required: true
            }
           
        },  
        messages:{  
        	cardno:{  
        		required: "请填写卡号"
            },  
            cardpwd:{  
                required: "请填写卡密码"
            }
        }  
    });
});