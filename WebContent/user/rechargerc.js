$().ready(function() {  
    $("form[name=rechargercfrm]").validate({ 
        rules:{  
    		total_fee:{  
    			required: true,
    			number:true
            }
           
        },  
        messages:{  
        	total_fee:{  
        		required: "冲值的金额必须填写!",
        		number:"冲值的金额必须为整数!"
            }
        }  
    });
});