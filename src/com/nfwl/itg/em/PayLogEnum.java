package com.nfwl.itg.em;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   PatEnum 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 上午09:35:30
 * @Comment
 * 
 */

public enum PayLogEnum {

	alipay("支付宝支付","/order/alipayto.jsp"),
	defaultpay("储值卡支付","com.nfwl.itg.order.PayAction"),
	alipayreturn("支付宝返回","/order/return_url.jsp"),
	alipaynotify("支付宝通知","/order/notify_url.jsp");
	
	private String code;
	
	private String source;
	
	PayLogEnum(String code,String source) {
        this.code = code;
        this.source = source;
    }

	public String getCode() {
		return code;
	}

	
	
	public String getSource() {
		return source;
	}

	public String toString(){
		return "CODE:("+ code +")  INFO:("+source+")";
	}
	
	public static PayLogEnum getByCode(String code){
		PayLogEnum pe = null;
		System.out.println("==="+code);
		for (PayLogEnum _pe : PayLogEnum.values()){
			if (_pe.getCode().equals(code)){
				System.out.println("==="+_pe.getSource());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	public static List<PayLogEnum> gets(){
		List<PayLogEnum> ls = new ArrayList<PayLogEnum>();
		for (PayLogEnum _pe : PayLogEnum.values()){
			ls.add(_pe);
		}
		return ls;
	}
}

