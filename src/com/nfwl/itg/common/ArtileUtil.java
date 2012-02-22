package com.nfwl.itg.common;

import java.sql.Connection;
import java.util.Map;



import com.jado.DbUtils_DAO;
import com.jado.JadoException;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ArtileUtil 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-2 下午11:31:24
 * @Comment
 * 
 */

public class ArtileUtil {

	public static Map getByCart(Connection con,String id) throws JadoException{
		String sql="select art.url_gen prd_url,art.pic_url prd_picurl,art.id prd_id,art.prd_name prd_name,art.prd_point prd_point,art.prd_localprice prd_price from  article art where art.id=?";
		DbUtils_DAO dd = new DbUtils_DAO();
		return dd.MapHandler_Search(con, sql,new Object[]{id});
	}
}

