 $().ready(function() {  
        $("#confirmorder").validate({ 
            rules:{
        		or_invoicetitle:{  
                    CNminlength: 5,  
                    CNmaxlength: 50  
                },  
                or_memo:{  
                    CNmaxlength: 200  
                }
            },  
            messages:{  
            	or_invoicetitle:{  
                    CNminlength: "发票抬头不能少于5个字符",  
                    CNmaxlength: "发票抬头不能大于50个字符"  
                },  
                or_memo:{  
                    CNminlength: "订单备注不能大于200个字符"  
                }
            }  
        });  
    });
function confirmordersubmit(){
	
	$("#confirmorder").submit();
}
