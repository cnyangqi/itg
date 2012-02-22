package com.nfwl.itg.common;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

import com.jado.JadoException;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_HZ_ZONE 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-25 下午10:40:25
 * @Comment
 * 
 */

public class ITG_HZ_ZONE {

	private String id;
	
	private String name;
	
	
	public String getId() {
		return id;
	}


	public void setId(String id) {
		this.id = id;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}


	public static List gets(Connection con) throws JadoException{
		//DbUtils_DAO dd = new DbUtils_DAO();
		//List ls = dd.MapListHandler_Search(con,"select * from itg_hz_zone");
		List ls = new ArrayList();
		ITG_HZ_ZONE hz1 = new ITG_HZ_ZONE();
		hz1.setId("1");
		hz1.setName("西湖区");
		ls.add(hz1);
		
		ITG_HZ_ZONE hz2 = new ITG_HZ_ZONE();
		hz2.setId("2");
		hz2.setName("上城区");
		ls.add(hz2);
		
		ITG_HZ_ZONE hz3 = new ITG_HZ_ZONE();
		hz3.setId("3");
		hz3.setName("下城区");
		ls.add(hz3);
		
		ITG_HZ_ZONE hz4 = new ITG_HZ_ZONE();
		hz4.setId("4");
		hz4.setName("拱墅区");
		ls.add(hz4);
		
		ITG_HZ_ZONE hz5 = new ITG_HZ_ZONE();
		hz5.setId("5");
		hz5.setName("江干区");
		ls.add(hz5);
		
		ITG_HZ_ZONE hz6 = new ITG_HZ_ZONE();
		hz6.setId("6");
		hz6.setName("滨江区");
		ls.add(hz6);
		
		ITG_HZ_ZONE hz7 = new ITG_HZ_ZONE();
		hz7.setId("7");
		hz7.setName("萧山区");
		ls.add(hz7);
		
		ITG_HZ_ZONE hz8 = new ITG_HZ_ZONE();
		hz8.setId("8");
		hz8.setName("余杭区");
		ls.add(hz8);
		
		return ls;
	}
}

