package com.nfwl.itg.em;

import java.util.ArrayList;
import java.util.List;


/**
 * 
 * @Project：cnbaibao   
 * @Type：   JXC_ORDERREC_STATUSENUM 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-10-27 下午09:54:45
 * @Comment
 * 
 */

public enum AlipayNotifyTypeEnum {

	PAYMENT(1,"支付宝付款"),//支付宝付款
	RECHARGE(2,"支付宝冲值");//支付宝冲值
	
	
	private Integer code;
	
	private String info;

   
	
	AlipayNotifyTypeEnum(Integer code,String info) {
        this.code = code;
        this.info = info;
    }
	
	
	public Integer getCode() {
		return code;
	}


	public void setCode(Integer code) {
		this.code = code;
	}


	public String getInfo() {
		return info;
	}


	public void setInfo(String info) {
		this.info = info;
	}


	public String toString(){
		return "CODE:("+ code +")  INFO:("+info+")";
	}
	
	public static AlipayNotifyTypeEnum getByInfo(String info){
		
		AlipayNotifyTypeEnum pe = null;
		System.out.println("==="+info);
		for (AlipayNotifyTypeEnum _pe : AlipayNotifyTypeEnum.values()){
			if (_pe.getInfo().equals(info)){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	
	public static AlipayNotifyTypeEnum getByCode(Integer code){
		AlipayNotifyTypeEnum pe = null;
		System.out.println("==="+code);
		for (AlipayNotifyTypeEnum _pe : AlipayNotifyTypeEnum.values()){
			if (_pe.getCode() == code){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	public static List<AlipayNotifyTypeEnum> gets(){
		List<AlipayNotifyTypeEnum> ls = new ArrayList<AlipayNotifyTypeEnum>();
		for (AlipayNotifyTypeEnum _pe : AlipayNotifyTypeEnum.values()){
			ls.add(_pe);
		}
		return ls;
	}
	
}

