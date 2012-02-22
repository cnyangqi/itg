$(document).ready(function(){
	$("#checkedAll").click(function(){
		if(this.checked){
			$("input[name='cart_id']").each(function(){this.checked=true;}); 
			}else{
				$("input[name='cart_id']").each(function(){this.checked=false;});
		}
	 });
});
function changePoingAndPrice(){
	var point=0,price=0;
	var _size = $('#prdsize').val();
	for(var i=1;i<=_size;i++){
		var _amount = $('#amount_'+ i).val();
		var _point = $('#point_'+ i).html();
		var _price = $('#price_'+ i).html();
		point=point+_amount*_point;
		price=price+_amount*_price;
	}
	$('#sp_point').html(point);
	$('#sp_price').html(price);
	$('#point').val(point);
	$('#price').val(price);
	
}
function minus_amount(n){
	var _amount = $('#amount_'+ n).val();
	if((_amount-1)<=0) return;
	$('#amount_'+ n).val(_amount-1);
	changePoingAndPrice();
	
}
function add_amount(n){
	var _amount = $('#amount_'+n).val();
	
	$('#amount_'+n).val((_amount-1)+2);
	changePoingAndPrice()
}
//验证是否 数字
function isNumeric(obj) {
	var strNumber=obj.value;
    return (strNumber.search(/^(-|\+)?\d+(\.\d+)?$/) != -1);
}
function amountChange(obj){
	if(!isNumeric(obj)){
		obj.value=1;
	}
	changePoingAndPrice();
}
function batchdel(){
	var _flag=false;
	$("input[name='cart_id']").each(function(){
		if(this.checked){
			_flag=true;
			return;
			//alert(this.value);
		}

	});
	if(_flag){
		$("#cartfrm").submit();
	}
}
function cartSubmit(){
	if(!checkSize()){
		return;
	}
	$("#cmd").val("balance");
	$("#cartfrm").submit();
}
function callback(){
	if(!checkSize()){
		return;
	}
	$("#cmd").val("balance");
	$("#cartfrm").submit();
	//window.location="/order/address.do?cmd=fromCart";
}
function checkSize(){
	var _size = $('#prdsize').val();
	if(_size=="0"){
		alert("购物车里没有物品");
		return false;
	}else{
		return true;
	}
}
