<%@page import="java.net.URLEncoder"%>
<%@page import="com.lowagie.text.Document"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>杭州良渚组团管理委员会</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta content="text/html;charset=utf-8" http-equiv="Content-Type">
<meta content="no-store" http-equiv="Cache-Control">
<meta content="no-cache" http-equiv="Pragma">
<meta content="0" http-equiv="Expires">
<link type="text/css" rel="stylesheet" href="/styles/index.css">
<script type="text/javascript" src="/js/jquery.js"></script>
</head>
<body>
	<div class="top top_k">

		<div class="topo">
		
			<object height="250" width="996" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0">
			<param value="/flash/index.swf" name="movie">
			<param value="high" name="quality">
			<param value="transparent" name="wmode">
			<embed height="250" width="996" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" quality="high" src="/flash/index.swf">
			</object>
			
			<div class="top-menu">
			
			  <ul class="mu_2">
					<li id="m_1" class="m_li_a">
						<a href="/">首页</a>
					</li>
					<li id="m_2" class="m_li" onmouseover="mover(2);" onmouseout="mout(2);">
						<a href="/ztgk/ztjj/2012/02/25/1064.shtml?def=2">组团概况</a>
					</li>
					<li id="m_3" class="m_li" onmouseover="mover(3);" onmouseout="mout(3);">
						<a href="/xwzx/gzdt/?def=3">新闻中心</a>
					</li>
					<li id="m_4" class="m_li" onmouseover="mover(4);" onmouseout="mout(4);">
						<a href="/zwgk/ksjs/?def=4">政务公开</a>
					</li>
					<li id="m_5" class="m_li" onmouseover="mover(5);" onmouseout="mout(5);">
						<a href="/tzhj.shtml?def=5">投资指南</a>
					</li>
					<li id="m_6" class="m_li" onmouseover="mover(6);" onmouseout="mout(6);">
						<a href="/fzpt/yhxc/?def=6">发展平台</a>
					</li>
					<li id="m_7" class="m_li" onmouseover="mover(7);" onmouseout="mout(7);">
						<a href="/zcfg/flfg/?def=7">政策法规</a>
					</li>
					<li id="m_8" class="m_li" onmouseover="mover(8);" onmouseout="mout(8);">
						<a href="/bsdt/ggzyjy/?def=8">办事大厅</a>
					</li>
				</ul>
				
				<ul class="smenu t5">
					<li id="s_1" style="padding-left: px;" class='s_li_a'>
						<div class="f_1 c_1">							
							<table>							
							<tr>
								<td valign="top"><div class="p1" id="day"></div></td>
								<td valign="top"><!--<div class="p2">-->今日天气预报：</td>
								<td valign="top" style="margin-top:3px;"><iframe src="http://www.yuhang.gov.cn/inc/other/weather1.aspx" width=330 height=20 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no align=center id=url style="margin-top:3px; "></iframe><!--</div>--></td>
								<td>
									<div class="p3">
									<table width="240" border="0" cellspacing="0" cellpadding="0">
									<form id="mysubmit" name="mysubmit" action="/lzarea/search.jsp" method="post">
										<input type="hidden" id="page" name="page" value="<%=request.getParameter("page") %>"/>
										<tr>
											<td width="62"><b>站内搜索</b></td>
											<td width="" class="pt_1">
												<input id="key" name="key" value="<%=request.getParameter("key") %>" onfocus="keyValue(this);" >
											</td>
											<td width="50"><input name="" type="image" src="/images/menu_1.gif" /></td>
										</tr>
									</form>
									</table>
								</div>
								</td>
							</tr>							
							<!--
            					<iframe src="http://www.tianqi123.com/small_page/chengshi_2250.html?c0=000000&c1=000000&bg=f1f1f1&w=330&h=20&text=yes" width=330 height=20 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no align=center id=url ></iframe>
            						-->				
							</table>
						</div>
					</li>

					<li id="s_2" style="padding-left: 120px;" class='s_li' onmouseover="mover(2);" onmouseout="mout(2);">
						<div class="f_1 z_2" style="width: auto;">
							<a href="/ztgk/ztjj/2012/02/25/1064.shtml">组团简介</a> | 
							<a href="/ztgk/ztgh/">组团规划</a> | 
							<a href="/zzjg.shtml">组织机构</a> | 
							<a href="/ztgk/xcsp/">宣传视频</a>
						</div>
					</li>

					<li id="s_3" style="padding-left: 240px;" class='s_li' onmouseover="mover(3);" onmouseout="mout(3);">
						<div class="f_1 z_2" style="width: auto;">
							<a href="/xwzx/gzdt/">工作动态</a> | 
							<a href="/xwzx/tpxw/">图片新闻</a> | 
							<a href="/xwzx/gggs/">公告公示</a>
						</div>
					</li>

					<li id="s_4" style="padding-left: 350px;" class='s_li' onmouseover="mover(4);" onmouseout="mout(4);">
						<div class="f_1 z_2" style="width: auto;">
							<a href="/zwgk/ksjs/">科室介绍</a> | 
							<a href="/zwgk/pzdw/">派驻单位</a> | 
							<a href="/zwgk/rczp/">人才招聘</a> | 
						</div>
					</li>

					<li id="s_5" style="padding-left: 470px;" class='s_li' onmouseover="mover(5);" onmouseout="mout(5);">
						<div class="f_1 z_2" style="width: auto;">
							<a href="/tzhj.shtml">投资环境</a> | 
							<a href="/tzzn/tzzc/">投资政策</a> | 
							<a href="/tzzn/tzcx/">投资程序</a> | 
							<a href="/tzzn/tzcg/">投资成果</a> | 
							<a href="/tzzn/tzzx/">投资咨询</a> |
							<a href="/tzzn/zsdt/">招商动态</a>
						</div>
					</li>

					<li id="s_6" style="padding-left: 580px;" class='s_li' onmouseover="mover(6);" onmouseout="mout(6);">
						<div class="f_1 z_2" style="width: auto;">
							<a href="/fzpt/rhjd/">仁和基地</a> | 
							<a href="/fzpt/yhxc/">运河新城</a> | 
							<a href="/fzpt/lzxc/">良渚新城</a>
						</div>
					</li>

					<li id="s_7" style="padding-left: 690px;" class='s_li' onmouseover="mover(7);" onmouseout="mout(7);">
						<div class="f_1 z_2" style="width: auto;">
							<a href="/zcfg/flfg/">法律法规</a> | 
							<a href="/zcfg/cyzc/">产业政策</a>
						</div>
					</li>

					<li id="s_8" style="padding-left: 700px;" class='s_li' onmouseover="mover(8);" onmouseout="mout(8);">
						<div class="f_1 z_2" style="width: auto;">
							<a href="/bsdt/ggzyjy/">公共资源交易</a> | 
							<a href="/bsdt/xzspfw/">行政审批服务</a> | 
							<a href="/bsdt/xzzqwd/">下载专区</a>
						</div>
					</li>

				</ul>
			</div>
			
        </div>
	</div>
	
	<script>

	var url=window.location.href;
	var tmp=url.substr(url.indexOf('?')+5);

	/** 菜单导航 */
	var def;
	if(tmp.length>1){
		def = 1;
	}else{
		def = tmp;
		var id=$('.m_li_a').attr('id');
		var index=id.substr(id.indexOf('_')+1,1);
		var _old=$('#'+id);
		var _old_son=$('#s_'+index);	
		var _new=$('#m_'+tmp);
		var _new_son=$('#s_'+tmp);
		_old.removeClass().addClass('m_li');
		_old.mouseover(function(){mover(index)});
		_old.mouseout(function(){mout(index)});
		_old_son.removeClass().addClass('s_li');
		_old_son.mouseover(function(){mover(index)});
		_old_son.mouseout(function(){mout(index)});
		_new.removeClass().addClass('m_li_a');
		_new.attr('onmouseover','');
		_new.attr('mouseout','');
		_new_son.removeClass().addClass('s_li_a');
		_new_son.attr('onmouseover','');
		_new_son.attr('mouseout','');
	}

	function mover(object) {
		//主菜单
		var mm = document.getElementById("m_" + object);
		mm.className = "m_li_a";
		//初始主菜单先隐藏效果
		if (def != 0) {
			var mdef = document.getElementById("m_" + def);
			mdef.className = "m_li";
		}
		//子菜单
		var ss = document.getElementById("s_" + object);
		ss.style.display = "block";
		//初始子菜单先隐藏效果
		if (def != 0) {
			var sdef = document.getElementById("s_" + def);
			sdef.style.display = "none";
		}
	}

	function mout(object) {
		//主菜单
		var mm = document.getElementById("m_" + object);
		mm.className = "m_li";
		//初始主菜单还原效果
		if (def != 0) {
			var mdef = document.getElementById("m_" + def);
			mdef.className = "m_li_a";
		}
		//子菜单
		var ss = document.getElementById("s_" + object);
		ss.style.display = "none";
		//初始子菜单还原效果
		if (def != 0) {
			var sdef = document.getElementById("s_" + def);
			sdef.style.display = "block";
		}
	}

	function keyValue(k) {
		if (k.value == '请输入关键字') {
			k.value = '';
		}
	}

	/** 日期函数 */
	function setdate(){
		var d=new Date();
		var week=['日','一','二','三','四','五','六'];
		var month=(d.getMonth()+1)>9?(d.getMonth()+1):('0'+(d.getMonth()+1));
		var str='今天是：'+d.getFullYear()+'年'+month+'月'+d.getDate()+'日'+' 星期'+week[d.getDay()];
		$('#day').html(str);
	}

	setdate();
	</script>

	<%
		java.sql.Connection con;
		java.sql.PreparedStatement ps;
		java.sql.ResultSet rs;
		
// 		select * from
// 		(
// 		select t.*, rownum rn
// 		from (select * from article where siteid='lzarea' and title like '%良渚%') t
// 		where rownum <= 10 order by t.publishdate
// 		)
// 		where rn >= 1

		int mpage=request.getParameter("page")==null?1:Integer.valueOf(request.getParameter("page"));
		int begin=(mpage-1)*15+1;
		int end=(mpage-1)*15+15;
		
		System.out.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"+mpage);
		
		StringBuilder sql=new StringBuilder("select * from ");
		sql.append("( ");
		sql.append("select t.*, rownum rn ");
		sql.append("from (select * from article where siteid='lzarea' and title like '%").append(request.getParameter("key")).append("%') t ");
		sql.append("where rownum <= ").append(end).append(" order by t.publishdate desc ");
		sql.append(") ");
		sql.append("where rn >= ").append(begin);
		
		System.out.println(sql.toString());
		
		con = nps.core.Database.GetDatabase("nps").GetConnection();
		ps = con.prepareStatement(sql.toString());
		rs = ps.executeQuery();

	%>
	
	<div class="zw">
	<table align="center" width="996" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF" >
	<tr>
	<td style="height: 600px;">
		<div class="news" style="margin-top:-50px;">
		<ul class="zx-1 ls_n t6">
			<%
				while (rs.next()) {
			%>
			<li>
			<a a href="<% out.print(rs.getString("url_gen"));%>" title="<% out.print(rs.getString("title"));%>" target="_blank"><% out.print(rs.getString("title"));%></a><b><%SimpleDateFormat sft=new SimpleDateFormat("MM-dd"); out.print(sft.format(rs.getDate("createdate")));%></b>
			</li>
			<%
				}
			%>
		</ul>
		
		<div style="float: right;">
			<% 
			sql=new StringBuilder("select count(id) as s from article where siteid='lzarea' and title like '%").append(request.getParameter("key")).append("%' ");
		 
		 	System.out.println(sql.toString());	
		 
			ps = con.prepareStatement(sql.toString());
			rs = ps.executeQuery();
			rs.next();
			
			int total=rs.getInt("s");
			int sum=total/15+1;
			%>
		
		<%
			if(sum>2 && mpage!=1){
				out.print("<a href='javascript:document.getElementById(\"page\").value=document.getElementById(\"page\").value-1;document.mysubmit.submit();' >前一页 </a>");
			} 
		%>
		
		 
		 <%
		 	if(total>1){
		 		for(int i=1;i<=sum;i++){
		 			//out.print("<a href='?page=" + i + "&key=" + request.getParameter("key") + "'>" + i + "</a>");
		 			out.print("<a href='javascript:document.getElementById(\"page\").value=" + i + ";document.mysubmit.submit();' >" + i + "</a>");
		 		}
		 	}
		 %>
		 
		<%
			if(sum>1 && mpage<sum){
				out.print("<a href='javascript:document.getElementById(\"page\").value=parseInt(document.getElementById(\"page\").value)+1;document.mysubmit.submit();' >下一页 </a>");
			} 
		%>
		 
		共<%=total==0?0:sum %>页
		</div>
		 
		 <%
		 	rs.close();
			ps.close();
		 %>
		 
		</div>
	</td>
	</tr>
	
	<tr>
	<td>
	<div class="mm">
	<img src="/images/b1.jpg" alt="" align="left" />
	版权所有:杭州市余杭区良渚组团管理委员会<br />
	Copyright @ 2012 http://www.lzarea.com/ all rights reserved 浙ICP备12004728号<br />
	地址：浙江省杭州市农副物流产品交易中心打石漾路3号<br />
	电话：0571-88768960
	</div>
	<td>
	</tr>
	
	</table>
	</div>
	
</body>
</html>