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

public enum AlipayNotifyStatusEnum {


	
	SUCCESS(1,"成功"),
	EXCEPTION(2,"异常"),
	ADDMONYERROR(3,"增加用户的钱时出错"),
	REPEAY(4,"重复的返回"),
	NOTFINDORDER(5,"找不到相应的订单");
	
	private Integer code;
	
	private String info;

   
	
	AlipayNotifyStatusEnum(Integer code,String info) {
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
	
	public static AlipayNotifyStatusEnum getByInfo(String info){
		
		AlipayNotifyStatusEnum pe = null;
		System.out.println("==="+info);
		for (AlipayNotifyStatusEnum _pe : AlipayNotifyStatusEnum.values()){
			if (_pe.getInfo().equals(info)){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	
	public static AlipayNotifyStatusEnum getByCode(Integer code){
		AlipayNotifyStatusEnum pe = null;
		System.out.println("==="+code);
		for (AlipayNotifyStatusEnum _pe : AlipayNotifyStatusEnum.values()){
			if (_pe.getCode() == code){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	public static List<AlipayNotifyStatusEnum> gets(){
		List<AlipayNotifyStatusEnum> ls = new ArrayList<AlipayNotifyStatusEnum>();
		for (AlipayNotifyStatusEnum _pe : AlipayNotifyStatusEnum.values()){
			ls.add(_pe);
		}
		return ls;
	}
	
}

