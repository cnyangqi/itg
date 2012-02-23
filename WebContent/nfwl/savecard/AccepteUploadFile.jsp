<%@page import="java.sql.Connection"%>
<%@page import="controllers.SaveCardController"%>
<%@page import="models.SaveCard"%>
<%@ page contentType="text/html;charset=gb2312"%>
<%@ page import="java.io.*,com.jspsmart.upload.*"%>
<%@ include file="/include/header.jsp"%>
<%
	SmartUpload su = new SmartUpload();
	su.initialize(pageContext);
	//su.setMaxFileSize(50000);
	//su.setAllowedFilesList("doc,txt");
	su.upload();
	int count = su.save("/temp/");
%>
<%
	for (int i = 0; i < su.getFiles().getCount(); i++) {
		com.jspsmart.upload.File file = su.getFiles().getFile(i);
		if (file.isMissing())
			continue;

		InputStreamReader fr = null;
		BufferedReader br = null;
		Connection con = null;
		SaveCardController scc = new SaveCardController();
		int rows = 0;
		try {
			con = nps.core.Database.GetDatabase("nps").GetConnection();
			con.setAutoCommit(false);
			fr = new InputStreamReader(new FileInputStream(request.getSession()
																	.getServletContext()
																	.getRealPath("/")
															+ "temp/"
															+ file.getFileName()));
			br = new BufferedReader(fr);
			String rec = null;
			String[] argsArr = null;
			SaveCard sc = null;
			while ((rec = br.readLine()) != null) {
				if (rec == null || rec.trim().isEmpty())
					continue;
				sc = SaveCardController.parse(rec, user);
				if (sc == null) {
					out.println("该行数据有误，请检查");
					out.println(rec);
					con.rollback();
					return;
				}
				if (SaveCardController.exist(con, sc.getCardno())) {
					out.println("该卡号已存在或者文件本身存在重复记录，请检查");
					out.println(rec);
					con.rollback();
					return;
				}
				// System.out.println(rec);
				scc.insert(con, sc);
				rows++;
			}
			out.println("成功上传" + count + "个文件<br/>");
			out.println("成功创建" + rows + "条数据");
			con.commit();
		}
		catch (IOException e) {
			con.rollback();
			e.printStackTrace();
		}
		finally {
			try {
				if (fr != null)
					fr.close();
				if (br != null)
					br.close();
			}
			catch (IOException ex) {}
			if (con != null)
				try {
					con.close();
				}
				catch (Exception ex) {}
		}
%>
<%
	//=file.getFieldName()
%>
<%
	//=file.getSize()
%>
<%
	//=file.getFileName()
%>
<%
	//=file.getFileExt()
%>
<%
	}
%>
