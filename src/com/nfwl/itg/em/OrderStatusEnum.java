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

public enum OrderStatusEnum {

	NEW(0,"新订单"),
	CONFIRM(1,"已确认订单"),
	//UNPAID(1,"未付款"),
	PAID(2,"已付款"),
	SHIPPING(3,"正在配送 "),
	FINISH(4,"完成 "),
	DELETE(99,"删除 "),
	CANCEL(100,"取消"),;
	
	private Integer code;
	
	private String info;
	
	OrderStatusEnum(Integer code,String info) {
        this.code = code;
        this.info = info;
    }

	public Integer getCode() {
		return code;
	}

	public String getInfo() {
		return info;
	}
	
	public String toString(){
		return "CODE:("+ code +")  INFO:("+info+")";
	}
	
	public static OrderStatusEnum getByCode(Integer code){
		OrderStatusEnum pe = null;
		System.out.println("==="+code);
		for (OrderStatusEnum _pe : OrderStatusEnum.values()){
			if (_pe.getCode() == code){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	public static List<OrderStatusEnum> gets(){
		List<OrderStatusEnum> ls = new ArrayList<OrderStatusEnum>();
		for (OrderStatusEnum _pe : OrderStatusEnum.values()){
			ls.add(_pe);
		}
		return ls;
	}
}

