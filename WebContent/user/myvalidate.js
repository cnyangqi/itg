function checkidcard(num) {
	var len = num.length, re;
	if (len == 15)
		re = new RegExp(/^(\d{6})()?(\d{2})(\d{2})(\d{2})(\d{3})$/);
	else if (len == 18)
		re = new RegExp(/^(\d{6})()?(\d{4})(\d{2})(\d{2})(\d{3})(\d)$/);
	else {
		// alert("请输入15或18位身份证号,您输入的是 "+len+ "位");
		return false;
	}
	var a = num.match(re);
	if (a != null) {
		if (len == 15) {
			var D = new Date("19" + a[3] + "/" + a[4] + "/" + a[5]);
			var B = D.getYear() == a[3] && (D.getMonth() + 1) == a[4]
					&& D.getDate() == a[5];
		} else {
			var D = new Date(a[3] + "/" + a[4] + "/" + a[5]);
			var B = D.getFullYear() == a[3] && (D.getMonth() + 1) == a[4]
					&& D.getDate() == a[5];
		}
		if (!B) {
			// alert("输入的身份证号 "+ a[0] +" 里出生日期不对！");
			return false;
		}
	}

	return true;
}

// 获取字符串的长度
function strlength(str) {
	var iLen = 0;
	if (str.length > 0) {
		for ( var i = 0; i < str.length; i++) {
			if (str.charAt(i) >= "\u0080")
				iLen += 2;
			else
				iLen += 1;
		}
	}
	return iLen;
}

// 手机号码验证
jQuery.validator
		.addMethod(
				"isMobile",
				function(value, element) {
					var length = value.length;
					return this.optional(element)
							|| (length == 11 && /^(((13[0-9]{1})|(15[0-9]{1})|(18[0-9]{1}))+\d{8})$/
									.test(value));
				}, "请正确填写您的手机号码");

// 添加验证方法 (身份证号码验证)
jQuery.validator.addMethod("isIdCardNo", function(value, element) {
	return this.optional(element) || checkidcard(value);
}, "请正确输入您的身份证号码");

jQuery.validator.addMethod("CNmaxlength", function(value, element, len) {
	var _length = strlength(value);
	return this.optional(element) || _length <= len;
}, "你输入的字符过长");

jQuery.validator.addMethod("CNminlength", function(value, element, len) {
	var _length = strlength(value);
	return this.optional(element) || _length >= len;
}, "你输入的字符过短");
