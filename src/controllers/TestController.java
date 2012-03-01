package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import nps.core.Database;

import com.et.mvc.JsonView;

/**
 * 代码测试管理
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-2-28
 */
public class TestController extends ApplicationController {

	/** 良渚组团企业访谈摘要 */
	public JsonView summary() throws Exception {
		Connection con;
		PreparedStatement ps;
		ResultSet rs;
		String sql = "select * from(select t.*, rownum rn from (select * from article) t where rownum <= 1 and t.siteid='lzarea' and t.topic=402 order by t.publishdate desc) where rn >= 1 ";

		con = Database.GetDatabase("nps").GetConnection();
		ps = con.prepareStatement(sql);
		rs = ps.executeQuery();

		if (rs.next()) {
			// <a href="" target="_blank"></a>

			String tmp = rs.getString("abstract");
			if (tmp.length() > 50) {
				tmp = tmp.substring(0, 50);
			}

			StringBuilder sb = new StringBuilder("<a href=\"");
			sb.append(rs.getString("url_gen"));
			sb.append("\" target=\"_blank\" > ");
			sb.append(tmp);
			sb.append(" </a>......");

			System.out.println(sb.toString());

			// out.print(rs.getString("abstract").substring(0, 50));
			// out.flush();
			// out.close();
		}

		rs.close();
		ps.close();
		con.close();

		return null;
	}

	/** 良渚组团自动更新图片新闻栏目中的图片导航 */
	public JsonView picNav() throws Exception {
		// <img.*?> 正则匹配 img标签
		// src=".*?" 正则匹配src属性
		// http://.*?/ 正则匹配过滤属性

		Connection con;
		PreparedStatement ps;
		ResultSet rs;
		String sql = "select * from(select t.*, rownum rn from (select * from article) t where rownum <= 5 and t.siteid='lzarea' and t.topic=321 order by t.publishdate desc) where rn >= 1 ";

		con = Database.GetDatabase("nps").GetConnection();
		ps = con.prepareStatement(sql);
		rs = ps.executeQuery();

		StringBuilder sb = new StringBuilder(" <div id=\"slider\" class=\"slider\"> ");
		LinkedList<String> list = new LinkedList<String>();

		int j = 0;
		String index0Str = null;// 记录第一条图片新闻的标题

		while (rs.next()) {

			String tmp = rs.getString("content");

			String regex = "<img.*?>";
			Pattern p = Pattern.compile(regex);
			Matcher m = p.matcher(tmp);

			if (m.find()) {
				tmp = m.group(0);
				regex = "src=\".*?\"";
				p = Pattern.compile(regex);
				m = p.matcher(tmp);

				if (m.find()) {
					// <a href="/xwzx/tpxw/2012/02/25/1063.shtml"
					// target="blank"><img src="images/new_1.png" /></a>

					sb.append(" <a href=\" ");
					sb.append(rs.getString("url_gen")).append("\" ");
					sb.append(" target=\"_blank\" ");
					sb.append(" title=\"");
					sb.append(rs.getString("title"));

					if (rs.getString("title").length() > 26) {
						list.add("\"" + rs.getString("title").substring(0, 18) + "...\"");

						if (j == 0) {
							index0Str = rs.getString("title").substring(0, 18) + "...";
							j++;
						}
					} else {
						list.add("\"" + rs.getString("title") + "\"");

						if (j == 0) {
							index0Str = rs.getString("title");
							j++;
						}
					}

					sb.append("\" >");
					sb.append(" <img ");
					// sb.append(m.group(0));

					tmp = m.group(0);
					regex = "http://.*?/";
					p = Pattern.compile(regex);
					m = p.matcher(tmp);
					tmp = m.replaceAll("");
					sb.append(tmp);

					sb.append(" width=\"391\" height=\"220\" /></a> ");

				}
			}

			// out.print(rs.getString("abstract").substring(0, 50));
			// out.flush();
			// out.close();
		}
		sb.append(" </div>");

		sb.append("<div id=\"title_view\" style=\"text-align: center;margin-left: 30px;\" >"
					+ index0Str
					+ "</div>");

		sb.append("<script type=\"text/javascript\">");

		sb.append("var ary=[");
		for (int i = 0; i < list.size(); i++) {
			if (i != 0) {
				sb.append(",");
			}
			sb.append(list.get(i));
		}
		sb.append("];");

		sb.append("$(function(){");
		sb.append("$('#slider').omSlider({");
		sb.append("animSpeed : 100,");
		sb.append("effect : 'slide-v',");
		sb.append("onBeforeSlide : function(index) {");
		sb.append("$(\"#title_view\").html(ary[index])");
		sb.append("}");
		sb.append("});");
		sb.append("});");
		sb.append("</script>");

		System.out.println(sb.toString());

		rs.close();
		ps.close();
		con.close();

		return null;
	}
}
