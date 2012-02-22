package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_SUGGEST 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午10:09:23
 * @Comment
 * 
 */

public class ITG_SUGGEST extends Bean {

	private String sg_id;//ID号
	
	private String sg_userid;//用户ID号
	
	private String sg_title;//标题
	
	private String sg_content;//内容
	
	private Date sg_time;//提交时间
	
	private String sg_reply;//答复内容
	
	private Date sg_replytime;//答复时间
	
	private String sg_replierid;//答复人ID号
	
	private String sg_repliername;
	
	
	
	public String getSg_repliername() {
		return sg_repliername;
	}
	public void setSg_repliername(String sg_repliername) {
		this.sg_repliername = sg_repliername;
	}
	public String getSg_id() {
		return sg_id;
	}
	public void setSg_id(String sg_id) {
		this.sg_id = sg_id;
	}
	public String getSg_userid() {
		return sg_userid;
	}
	public void setSg_userid(String sg_userid) {
		this.sg_userid = sg_userid;
	}
	public String getSg_title() {
		return sg_title;
	}
	public void setSg_title(String sg_title) {
		this.sg_title = sg_title;
	}
	public String getSg_content() {
		return sg_content;
	}
	public void setSg_content(String sg_content) {
		this.sg_content = sg_content;
	}
	public Date getSg_time() {
		return sg_time;
	}
	public void setSg_time(Date sg_time) {
		this.sg_time = sg_time;
	}
	public String getSg_reply() {
		return sg_reply;
	}
	public void setSg_reply(String sg_reply) {
		this.sg_reply = sg_reply;
	}
	public Date getSg_replytime() {
		return sg_replytime;
	}
	public void setSg_replytime(Date sg_replytime) {
		this.sg_replytime = sg_replytime;
	}
	public String getSg_replierid() {
		return sg_replierid;
	}
	public void setSg_replierid(String sg_replierid) {
		this.sg_replierid = sg_replierid;
	}
	
}

