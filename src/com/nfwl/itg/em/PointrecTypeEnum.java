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

public enum PointrecTypeEnum {

	BUY(1,"购买商品");
	private Integer code;
	
	private String info;

   
	
	PointrecTypeEnum(Integer code,String info) {
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
	
	public static PointrecTypeEnum getByInfo(String info){
		
		PointrecTypeEnum pe = null;
		System.out.println("==="+info);
		for (PointrecTypeEnum _pe : PointrecTypeEnum.values()){
			if (_pe.getInfo().equals(info)){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	
	public static PointrecTypeEnum getByCode(Integer code){
		PointrecTypeEnum pe = null;
		System.out.println("==="+code);
		for (PointrecTypeEnum _pe : PointrecTypeEnum.values()){
			if (_pe.getCode() == code){
				System.out.println("==="+_pe.getInfo());
				pe = _pe;
				break;
			}
		}
		return pe;
	}
	public static List<PointrecTypeEnum> gets(){
		List<PointrecTypeEnum> ls = new ArrayList<PointrecTypeEnum>();
		for (PointrecTypeEnum _pe : PointrecTypeEnum.values()){
			ls.add(_pe);
		}
		return ls;
	}
	
}

