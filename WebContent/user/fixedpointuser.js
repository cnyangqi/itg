$().ready(function() {
	$("#userForm").validate({
		rules : {
			account : {
				required : true,
				CNminlength : 2,
				CNmaxlength : 20
			},
			password : {
				required : true,
				CNminlength : 2,
				CNmaxlength : 30
			},
			password2 : {
				required : true,
				CNminlength : 2,
				CNmaxlength : 30
			},
			name : {
				required : true,
				CNmaxlength : 10
			},
			mobile : {
				required : true,
				isMobile : true
			},
			areacode : {
				required : true,
				number : true,
				CNmaxlength : 4
			},
			telephone : {
				required : true,
				number : true,
				CNmaxlength : 8
			},
			subnum : {
				number : true,
				CNmaxlength : 3
			}
		},
		messages : {
			account : {
				required : "请填写账户",
				CNminlength : "字符长度不能小于2",
				CNmaxlength : "字符长度不能大于10"
			},
			password : {
				required : "请填写密码",
				CNminlength : "字符长度不能小于2",
				CNmaxlength : "字符长度不能大于30"
			},
			password2 : {
				required : "请填写确认密码",
				CNminlength : "字符长度不能小于2",
				CNmaxlength : "字符长度不能大于30"
			},
			name : {
				required : "请填写真实姓名",
				CNminlength : "字符长度不能大于10"
			},
			mobile : {
				required : "请填写手机",
				isMobile : "你填的手机不正确"
			},
			areacode : {
				required : "请填写电话区号",
				number : "电话区号必须为数字",
				CNmaxlength : "电话区号不能大于4"
			},
			telephone : {
				required : "请填写电话",
				number : "电话必须为数字",
				CNmaxlength : "电话不能大于8"
			},
			subnum : {
				number : "电话分机号必须为数字",
				CNmaxlength : "电话分机号不能大于3"
			}
		}
	});
});