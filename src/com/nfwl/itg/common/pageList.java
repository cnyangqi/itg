package com.nfwl.itg.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 * @Project：cnbaibao   
 * @Type：   pageList 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-10-26 下午09:06:18
 * @Comment
 * 
 */

public class pageList {

	private Integer pageCur;  //当前页

	private Integer pageSize;//一页多少数据
	
	private Integer size;//总数据条数
	
	private List list;
	
	private  HashMap<String,Object> parameter = new HashMap<String, Object>();
	
	//得到总页数
	public Integer getPageCount(){
		if(size==null||size==0) return 0;
		Integer pc=size/pageSize;
		if (size%pageSize!=0){
			pc=pc+1;
		}
		return pc;
	}
	//得到开始数据
	public Integer getStart(){
		return (pageCur-1)*pageSize;
	}
	
	
	public Integer getPageCur() {
		return pageCur;
	}

	public void setPageCur(Integer pageCur) {
		this.pageCur = pageCur;
	}

	public Integer getPageSize() {
		return pageSize;
	}

	public void setPageSize(Integer pageSize) {
		this.pageSize = pageSize;
	}

	public Integer getSize() {
		return size;
	}

	public void setSize(Integer size) {
		this.size = size;
	}

	public List getList() {
		return list;
	}

	public void setList(List list) {
		this.list = list;
	}
	public void addParameter(String name,Object value){
		parameter.put(name, value);
	}
	public HashMap<String,Object> getParameter(){
		return parameter;
	}
	
}

