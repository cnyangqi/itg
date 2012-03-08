// 身份证号码验证
function checkidcard(num) {
	var len = num.length, re;

	if (len == 15)
		re = new RegExp(/^(\d{6})()?(\d{2})(\d{2})(\d{2})(\d{3})$/);
	else if (len == 18)
		re = new RegExp(/^(\d{6})()?(\d{4})(\d{2})(\d{2})(\d{3})(\d)$/);
	else {
		return false;
	}

	var a = num.match(re);
	var b;
	var d;
	if (a != null) {
		if (len == 15) {
			d = new Date("19" + a[3] + "/" + a[4] + "/" + a[5]);
			b = d.getYear() == a[3] && (d.getMonth() + 1) == a[4]
					&& d.getDate() == a[5];
		} else {
			d = new Date(a[3] + "/" + a[4] + "/" + a[5]);
			b = d.getFullYear() == a[3] && (d.getMonth() + 1) == a[4]
					&& d.getDate() == a[5];
		}
		if (!b) {
			return false;
		}
	}

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

// 添加验证方法
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
