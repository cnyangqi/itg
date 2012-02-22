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

public enum RechargeTypeEnum {

	
	CARDRECHARGE(1,"营销卡冲值"),
	ALIPAYRECHARGE(2,"支付宝冲值");
	
	private Integer code;
	private String info;
	
	RechargeTypeEnum(Integer code,String info) {
        this.code = code;
        this.info=info;
    }

	public Integer getCode() {
		return code;
	}
	

	public String getInfo() {
		return info;
	}

	

	public String toString(){
		return "CODE:("+ code +")  INFO("+info+")";
	}
	
	public static RechargeTypeEnum getByCode(Integer code){
		RechargeTypeEnum pe = null;
		System.out.println("==="+code);
		for (RechargeTypeEnum _pe : RechargeTypeEnum.values()){
			if (_pe.getCode().equals(code)){
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	public static List<RechargeTypeEnum> gets(){
		List<RechargeTypeEnum> ls = new ArrayList<RechargeTypeEnum>();
		for (RechargeTypeEnum _pe : RechargeTypeEnum.values()){
			ls.add(_pe);
		}
		return ls;
	}
}

