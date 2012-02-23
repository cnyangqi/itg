$().ready( function() {
		$("#userForm").validate( {
			rules : {
				nickname : {
					CNminlength : 2,
					CNmaxlength : 20
				},
				name : {
					required : true,
					CNmaxlength : 10
				},
				detailadr : {
					required : true,
					CNmaxlength : 200
				},
				mobile : {
					required : true,
					isMobile : true
				},
				areacode : {
					number : true,
					CNmaxlength : 4
				},
				telephone : {
					number : true,
					CNmaxlength : 8
				},
				subnum : {
					number : true,
					CNmaxlength : 3
				},
				faxareacode : {
					number : true,
					CNmaxlength : 4
				},
				fax : {
					number : true,
					CNmaxlength : 8
				}
			},
			messages : {
				nickname : {
					required : "请填写呢称",
					CNminlength : "字符长度不能小于2",
					CNmaxlength : "字符长度不能大于10"
				},
				name : {
					required : "请填写真实姓名",
					CNminlength : "字符长度不能大于10"
				},
				detailadr : {
					required : "请填写详细地址",
					CNmaxlength : "不能大于200个汉字"
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
				},
				faxareacode : {
					required : "请填写传真区号",
					number : "传真区号必须为数字",
					CNmaxlength : "传真区号不能大于4"
				},
				fax : {
					required : "请填写传真",
					number : "传真必须为数字",
					CNmaxlength : "传真不能大于8"
				}
			}
		});
	});