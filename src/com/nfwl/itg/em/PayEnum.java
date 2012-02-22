package com.nfwl.itg.em;


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

public enum PayEnum {

	
	BALANCE(1,"账户余额"),
	VALUECARD(2,"储值卡"),
	ALIPAY(3,"支付宝"),
	ABC(4,"农行");
	
	private int code;
	
	private String info;
	
	PayEnum(int code,String info) {
        this.code = code;
        this.info = info;
    }

	public int getCode() {
		return code;
	}

	public String getInfo() {
		return info;
	}
	
	public String toString(){
		return "CODE:("+ code +")  INFO:("+info+")";
	}
	
	public static PayEnum getByCode(int code){
		PayEnum pe = null;
		for (PayEnum _pe : PayEnum.values()){
			if (_pe.getCode() == code){
				pe = _pe;
				break;
			}
		}
		return pe;
	}
}

