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
function callBackAddress(addressHtml){
	$("#addressSpan").html(addressHtml);
}
function callBackPay(payHtml){
	$("#paySpan").html(payHtml);
}
function confirmordersubmit(){	
	$("#confirmorder").submit();
}
function cancheordersubmit(){
	$("#ordercmd").val("canche");
	$("#orderfrm").submit();
}
function receivingordersubmit(){
	$("#ordercmd").val("receiving");
	$("#orderfrm").submit();
}
function payordersubmit(){
	$("#ordercmd").val("pay");
	$("#orderfrm").attr("action","/order/pay.do");
	$("#orderfrm").submit();
}

