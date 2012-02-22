package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITH_COLLECTREC 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午08:49:33
 * @Comment 收藏夹记录
 * 
 */

public class ITG_COLLECTREC extends Bean {
	private String col_id;//ID号
	
	private String col_userid;//用户ID号
	
	private String col_artid;//日期
	
	private Date col_time;//相应的商品id
	
	
	public String getCol_id() {
		return col_id;
	}
	public void setCol_id(String col_id) {
		this.col_id = col_id;
	}
	public String getCol_userid() {
		return col_userid;
	}
	public void setCol_userid(String col_userid) {
		this.col_userid = col_userid;
	}
	public String getCol_artid() {
		return col_artid;
	}
	public void setCol_artid(String col_artid) {
		this.col_artid = col_artid;
	}
	public Date getCol_time() {
		return col_time;
	}
	public void setCol_time(Date col_time) {
		this.col_time = col_time;
	}
	
}

