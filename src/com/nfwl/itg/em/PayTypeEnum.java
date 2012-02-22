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

public enum PayTypeEnum {

	DEFAULT("default","卡余额"),
	DIRECTPAY("directPay","支付宝余额"),
	BANKPAY("bankPay","网银"),
	CASH("cash","网点支付"),
	CARTOON("cartoon","卡通"),;
	
	private String code;
	
	private String info;
	
	PayTypeEnum(String code,String info) {
        this.code = code;
        this.info = info;
    }

	public String getCode() {
		return code;
	}

	public String getInfo() {
		return info;
	}
	
	public String toString(){
		return "CODE:("+ code +")  INFO:("+info+")";
	}
	
	public static PayTypeEnum getByCode(String code){
		PayTypeEnum pe = null;
		System.out.println("==="+code);
		for (PayTypeEnum _pe : PayTypeEnum.values()){
			if (_pe.getCode().equals(code)){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	public static List<PayTypeEnum> gets(){
		List<PayTypeEnum> ls = new ArrayList<PayTypeEnum>();
		for (PayTypeEnum _pe : PayTypeEnum.values()){
			ls.add(_pe);
		}
		return ls;
	}
}

