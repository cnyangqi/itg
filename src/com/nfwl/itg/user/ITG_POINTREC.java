package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_POINTREC 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-28 下午10:46:04
 * @Comment
 * 
 */

public class ITG_POINTREC extends Bean {
	
	private String pr_id;
	
	private String pr_userid;
	
	private Integer pr_point;
	
	private Integer pr_type;
	
	private String pr_resourceid;
	
	private Date pr_time;

	public String getPr_id() {
		return pr_id;
	}

	public void setPr_id(String pr_id) {
		this.pr_id = pr_id;
	}

	public String getPr_userid() {
		return pr_userid;
	}

	public void setPr_userid(String pr_userid) {
		this.pr_userid = pr_userid;
	}

	public Integer getPr_point() {
		return pr_point;
	}

	public void setPr_point(Integer pr_point) {
		this.pr_point = pr_point;
	}

	public Integer getPr_type() {
		return pr_type;
	}

	public void setPr_type(Integer pr_type) {
		this.pr_type = pr_type;
	}

	public String getPr_resourceid() {
		return pr_resourceid;
	}

	public void setPr_resourceid(String pr_resourceid) {
		this.pr_resourceid = pr_resourceid;
	}

	public Date getPr_time() {
		return pr_time;
	}

	public void setPr_time(Date pr_time) {
		this.pr_time = pr_time;
	}
	
	
}

