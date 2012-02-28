<!-- 企业访谈摘要 -->
<%@page import="nps.core.Database"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	Connection con;
	PreparedStatement ps;
	ResultSet rs;
	String sql = "select * from(select t.*, rownum rn from (select * from article) t where rownum <= 1 and t.siteid='lzarea' and t.topic=402 order by t.publishdate desc) where rn >= 1 ";

	con = Database.GetDatabase("nps").GetConnection();
	ps = con.prepareStatement(sql);
	rs = ps.executeQuery();

	if (rs.next()) {
		// <a href=""></a>
		
		String tmp=rs.getString("abstract");
		if(tmp.length()>50){
			tmp=tmp.substring(0, 50);
		}

		StringBuilder sb=new StringBuilder("<a href=\"");
		sb.append(rs.getString("url_gen"));
		sb.append("\"");
		
		sb.append("</a>");
		
		out.print(rs.getString("abstract").substring(0, 50));
		out.flush();
		//out.close();
	}
	
	rs.close();
	ps.close();
	con.close();
%>