<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>

<%@ page import="nps.core.Database" %>
<%@ page import="nps.core.Resource" %>
<%@ page import="java.sql.*" %>
<%@ page import="oracle.sql.CLOB" %>
<%@ page import="oracle.jdbc.driver.OracleResultSet" %>
<%@ page import="oracle.sql.BLOB" %>
<%@ page import="java.io.*" %>

<%@ include file="/include/header.jsp" %>

<%
    //从经纬信息发布系统中迁移数据
    request.setCharacterEncoding("UTF-8");

    out.println("正在从经纬信息发布系统中迁移数据，确保配置名为publish数据源，同时将OA下的T_UNIT,T_USER表导入该数据源...<br>");
    
    Connection conn_nps = null;
    Connection conn_publish = null;

    PreparedStatement pstmt_nps = null;
    PreparedStatement pstmt_publish = null;
    PreparedStatement pstmt_clob = null;
    ResultSet rs_publish = null;
    String sql_publish = null;
    String sql_nps = null;
    String sql_clob = null;
    int rows = 0;

    try
    {
        conn_publish= Database.GetDatabase("publish").GetConnection();
        conn_nps = Database.GetDatabase("nps").GetConnection();
        conn_nps.setAutoCommit(false);

        //更改表构
        Statement stmt = null;
        try
        {
            //UNIT记录老ID
            String sql = "alter table unit add oldid varchar2(50)";
            stmt = conn_nps.createStatement();
            stmt.execute(sql);
            try{stmt.close();}catch(Exception e){}
            stmt = null;

            //DEPT记录老ID
            sql = "alter table dept add oldid varchar2(50)";
            stmt = conn_nps.createStatement();
            stmt.execute(sql);
            try{stmt.close();}catch(Exception e){}
            stmt = null;

            //USERS记录老ID
            sql = "alter table users add oldid varchar2(50)";
            stmt = conn_nps.createStatement();
            stmt.execute(sql);
            try{stmt.close();}catch(Exception e){}
            stmt = null;

            //TEMPLATE记录模版老ID
            sql = "alter table template add oldid varchar2(50)";
            stmt = conn_nps.createStatement();
            stmt.execute(sql);
            try{stmt.close();}catch(Exception e){}
            stmt = null;

            //TOPIC记录模版老ID
            sql = "alter table topic add oldid varchar2(50)";
            stmt = conn_nps.createStatement();
            stmt.execute(sql);
            try{stmt.close();}catch(Exception e){}
            stmt = null;

            //ARTICLE记录模版老ID
            sql = "alter table article add oldid varchar2(50)";
            stmt = conn_nps.createStatement();
            stmt.execute(sql);
            try{stmt.close();}catch(Exception e){}
            stmt = null;

            //RESOURCES记录老ID
            sql = "alter table resources add oldid varchar2(50)";
            stmt = conn_nps.createStatement();
            stmt.execute(sql);
            try{stmt.close();}catch(Exception e){}
            stmt = null;
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            if(stmt!=null) try{stmt.close();}catch(Exception e){}
        }

        
        //迁移组织机构
        out.println("<font color=red>Unit ...</font><br>");
        sql_publish = "select * from t_unit where unit_parentid Is Null And unit_id<>'-1'";
        pstmt_publish = conn_publish.prepareStatement(sql_publish);
        rs_publish = pstmt_publish.executeQuery();
        sql_nps = "Insert Into unit(Id,Name,oldid,createdate) values(seq_unit.Nextval,?,?,sysdate)";
        pstmt_nps = conn_nps.prepareStatement(sql_nps);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("unit_name"));
            pstmt_nps.setString(2,rs_publish.getString("unit_id"));
            pstmt_nps.executeUpdate();
            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //迁移部门
        out.println("<font color=red>Dept...</font><br>");
        sql_publish = "Select * From t_unit Where unit_parentid Is Not Null order by unit_index";
        pstmt_publish = conn_publish.prepareStatement(sql_publish);
        rs_publish = pstmt_publish.executeQuery();
        sql_nps = "insert into dept(id,name,cx,parentid,unit,oldid,createdate) values(seq_dept.nextval,?,?,?,?,?,sysdate)";
        pstmt_nps = conn_nps.prepareStatement(sql_nps);
        rows=0;
        //查找上级部门是否是UNIT
        while(rs_publish.next())
        {
            String sql = "select * from unit where oldid=?";
            PreparedStatement pstmt = conn_nps.prepareStatement(sql);
            pstmt.setString(1,rs_publish.getString("unit_parentid"));
            ResultSet rs = pstmt.executeQuery();
            if(rs.next())
            {
                pstmt_nps.setString(1,rs_publish.getString("unit_name"));
                pstmt_nps.setInt(2,rs_publish.getInt("unit_index"));
                pstmt_nps.setNull(3,java.sql.Types.VARCHAR);
                pstmt_nps.setString(4,rs.getString("id"));
                pstmt_nps.setString(5,rs_publish.getString("unit_id"));
                pstmt_nps.executeUpdate();
                rows++;
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}
                continue;
            }

            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}

            //是部门
            sql = "select * from dept where oldid=?";
            pstmt = conn_nps.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                pstmt_nps.setString(1,rs_publish.getString("unit_name"));
                pstmt_nps.setInt(2,rs_publish.getInt("unit_index"));
                pstmt_nps.setString(3,rs.getString("id"));
                pstmt_nps.setString(4,rs.getString("unit"));
                pstmt_nps.setString(5,rs_publish.getString("unit_id"));
                pstmt_nps.executeUpdate();

                rows++;
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}
                continue;
            }

            out.println("Skip Dept:"+rs_publish.getString("unit_name")+"("+rs.getString("unit_id")+")<br>");
            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //迁移用户
        out.println("<font color=red>User,默认密码＝88888888...</font><br>");
        sql_publish="Select * From t_user Where user_id<>'-1' And user_isuseful=1";
        pstmt_publish = conn_publish.prepareStatement(sql_publish);
        rs_publish = pstmt_publish.executeQuery();
        sql_nps="insert into users(id,name,account,password,oldid,cx,dept,utype) values(seq_user.nextval,?,?,'88888888',?,?,?,?)";
        pstmt_nps = conn_nps.prepareStatement(sql_nps);
        String sql = "select * from dept where oldid=?";
        PreparedStatement pstmt = conn_nps.prepareStatement(sql);
        rows=0;
        while(rs_publish.next())
        {
            pstmt.setString(1,rs_publish.getString("user_unit_id"));
            ResultSet rs = pstmt.executeQuery();
            if(!rs.next())
            {
                out.println("Warning: Skip User: "+rs_publish.getString("user_name")+"<br>");
                try{rs.close();}catch(Exception e){}
                continue;
            }

            pstmt_nps.setString(1,rs_publish.getString("user_name"));
            pstmt_nps.setString(2,rs_publish.getString("user_account"));
            pstmt_nps.setString(3,rs_publish.getString("user_id"));
            pstmt_nps.setString(4,rs_publish.getString("user_index"));
            pstmt_nps.setString(5,rs.getString("id"));
            switch(rs_publish.getInt("user_type"))
            {
                case 9:
                    pstmt_nps.setInt(6,9);
                    break;
                default:
                    pstmt_nps.setInt(6,0);
                    break;
            }
            pstmt_nps.executeUpdate();
            rows++;

            try{rs.close();}catch(Exception e){}
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //迁移站点主信息
        out.println("<font color=red>Sites...1.默认挂在SYSTEM Default下，请调整；2.Attach和Image目录不同的，以Image目录为准，请调整文件系统</font><br>");
        sql_publish="select * from sites";
        pstmt_publish = conn_publish.prepareStatement(sql_publish);
        rs_publish = pstmt_publish.executeQuery();
        sql_nps="Insert Into site(Id,Name,suffix,rooturl,artpubdir,img_rooturl,img_publish_dir,state,unit,fulltext) Values(?,?,?,?,?,?,?,?,'0',0)";
        pstmt_nps = conn_nps.prepareStatement(sql_nps);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("id"));
            pstmt_nps.setString(2,rs_publish.getString("name"));
            pstmt_nps.setString(3,rs_publish.getString("defaultext"));
            pstmt_nps.setString(4,rs_publish.getString("rooturl"));
            pstmt_nps.setString(5,rs_publish.getString("publishdir"));
            pstmt_nps.setString(6,rs_publish.getString("imgrooturl"));
            pstmt_nps.setString(7,rs_publish.getString("imgpublishdir"));
            switch(rs_publish.getInt("state"))
            {
                case 2://禁用
                    pstmt_nps.setInt(8,0);
                    break;
                default:
                    pstmt_nps.setInt(8,1);
                    break;
            }

            pstmt_nps.executeUpdate();
            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}
        
        //迁移站点主机信息
        out.println("<font color=red>Site Hosts...</font><br>");
        sql_publish = "select * from site_hosts";
        pstmt_publish = conn_publish.prepareStatement(sql_publish);
        rs_publish = pstmt_publish.executeQuery();
        sql_nps="insert into site_host(siteid,type,host,remotedir,port,uname,upasswd) values(?,?,?,?,?,?,?)";
        pstmt_nps = conn_nps.prepareStatement(sql_nps);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("site_id"));
            pstmt_nps.setString(2,rs_publish.getString("host_type"));
            pstmt_nps.setString(3,rs_publish.getString("host"));
            pstmt_nps.setString(4,rs_publish.getString("remotedir"));
            pstmt_nps.setString(5,rs_publish.getString("port"));
            pstmt_nps.setString(6,rs_publish.getString("username"));
            pstmt_nps.setString(7,rs_publish.getString("userpw"));
            pstmt_nps.executeUpdate();
            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //迁移模版
        out.println("<font color=red>Templates...</font><br>");
        sql_publish="select * from template";
        pstmt_publish = conn_publish.prepareStatement(sql_publish);
        rs_publish = pstmt_publish.executeQuery();
        sql_nps="insert into template(id,name,type,scope,currenttemplate,template0,template1,template2,fname,oldid,creator,createdate) values(seq_template.nextval,?,?,0,0,empty_clob(),empty_clob(),empty_clob(),?,?,0,sysdate)";
        pstmt_nps = conn_nps.prepareStatement(sql_nps);
        sql_clob="select template0 from template where oldid=? for update";
        pstmt_clob = conn_nps.prepareStatement(sql_clob);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("tmp_name"));
            switch(rs_publish.getInt("tmp_type"))
            {
                case 0: //文章模版
                    pstmt_nps.setInt(2,0);
                    break;
                default: //页面模版
                    pstmt_nps.setInt(2,2);
                    break;
            }
            pstmt_nps.setString(3,rs_publish.getString("tmp_outfilename"));
            pstmt_nps.setString(4,rs_publish.getString("tmp_id"));
            pstmt_nps.executeUpdate();

            //设置内容
            CLOB clob = ((OracleResultSet)rs_publish).getCLOB("tmp_data");
            if(clob!=null)
            {
                 Reader is = null;
                 Writer writer = null;
                 ResultSet rs = null;
                 try
                 {
                    pstmt_clob.setString(1,rs_publish.getString("tmp_id"));
                    rs = pstmt_clob.executeQuery();
                    rs.next();
                    CLOB clob_nps = ( oracle.sql.CLOB) rs.getClob(1);

                    is = clob.getCharacterStream();
                    writer = clob_nps.getCharacterOutputStream();
                    int b;
                    while( (b=is.read())!=-1)
                    {
                        writer.write(b);
                    }
                    writer.flush();
                }
                finally
                {
                    try{is.close();}catch(Exception e1){}
                    try{writer.close();}catch(Exception e1){}
                    try{rs.close();}catch(Exception e1){}
                }
            }

            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_clob.close();}catch(Exception e){}
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //迁移栏目
        out.println("<font color=red>Topic...</font><br>");
        sql_publish="select * from topics order by top_layer,top_index";
        pstmt_publish = conn_publish.prepareStatement(sql_publish);
        rs_publish = pstmt_publish.executeQuery();
        sql_nps = "Insert Into topic(Id,oldid,Name,siteid,alias,code,parentid,idx,tname,art_template,default_article_state,default_article_score,layer,createdate) Values(seq_topic.Nextval,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        pstmt_nps = conn_nps.prepareStatement(sql_nps);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("top_id"));
            pstmt_nps.setString(2,rs_publish.getString("top_name"));
            pstmt_nps.setString(3,rs_publish.getString("top_site_id"));
            pstmt_nps.setString(4,rs_publish.getString("top_alias"));
            pstmt_nps.setString(5,rs_publish.getString("top_code"));
            if(rs_publish.getInt("top_layer")==1)
            {
                pstmt_nps.setNull(6,java.sql.Types.VARCHAR);
            }
            else
            {
                String top_code = rs_publish.getString("top_code");
                int pos_dot = top_code.lastIndexOf('.');
                if(pos_dot==-1)
                {
                    pstmt_nps.setNull(6,java.sql.Types.VARCHAR);
                }
                else
                {
                    String top_parentcode = top_code.substring(0,pos_dot);
                    sql = "select * from topic where code=?";
                    pstmt = conn_nps.prepareStatement(sql);
                    pstmt.setString(1,top_parentcode);
                    ResultSet rs = pstmt.executeQuery();
                    if(rs.next())
                    {
                        pstmt_nps.setString(6,rs.getString("id"));
                    }
                    else
                    {
                        out.println("Warning: Topic code="+top_parentcode+" not found, set to null...<br>");
                        out.flush();
                        pstmt_nps.setNull(6,java.sql.Types.VARCHAR);
                    }

                    try{rs.close();}catch(Exception e){}
                    try{pstmt.close();}catch(Exception e){}
                }
            }
            pstmt_nps.setInt(7,rs_publish.getInt("top_index"));
            pstmt_nps.setString(8,rs_publish.getString("top_art_table"));
            if(rs_publish.getString("top_art_tmp_id")==null)
            {
                pstmt_nps.setNull(9,java.sql.Types.VARCHAR);
            }
            else
            {
                sql="select id from template where oldid=?";
                pstmt = conn_nps.prepareStatement(sql);
                pstmt.setString(1,rs_publish.getString("top_art_tmp_id"));
                ResultSet rs = pstmt.executeQuery();
                if(rs.next())
                {
                    pstmt_nps.setString(9,rs.getString("id"));
                }
                else
                {
                    out.println("Warning: Topic:"+rs_publish.getString("top_name")+"("+rs_publish.getString("top_id")+") article template = null("+rs_publish.getString("top_art_tmp_id")+")<br>");
                    out.flush();
                    pstmt_nps.setNull(9,java.sql.Types.VARCHAR);
                }

                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}
            }
            pstmt_nps.setString(10,rs_publish.getString("art_def_state"));
            pstmt_nps.setString(11,rs_publish.getString("top_value"));
            pstmt_nps.setInt(12,rs_publish.getInt("top_layer")-1);
            pstmt_nps.setTimestamp(13,rs_publish.getTimestamp("top_modifydate"));

            pstmt_nps.executeUpdate();
            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //设置栏目模版和页面模版
        out.println("<font color=red>Adding Page Templates for Topics...</font><br>");
        sql_publish="select * from relatetemplate";
        pstmt_publish=conn_publish.prepareStatement(sql_publish);
        rs_publish=pstmt_publish.executeQuery();
        sql_nps="insert into topic_pts(topid,templateid) select a.id,b.id from topic a,template b where a.oldid=? and b.oldid=?";
        pstmt_nps=conn_nps.prepareStatement(sql_nps);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("rt_top_id"));
            pstmt_nps.setString(2,rs_publish.getString("rt_tmp_id"));
            pstmt_nps.executeUpdate();
            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //将栏目模版都设置为页面模版
        out.println("<font color=red>Adding Topic Templates for Topics...</font><br>");
        sql_publish="select * from topics where top_tmp_id is not null";
        pstmt_publish=conn_publish.prepareStatement(sql_publish);
        rs_publish=pstmt_publish.executeQuery();
        sql_nps="insert into topic_pts(topid,templateid) select a.id,b.id from topic a,template b where a.oldid=? and b.oldid=?";
        pstmt_nps=conn_nps.prepareStatement(sql_nps);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("top_id"));
            pstmt_nps.setString(2,rs_publish.getString("top_tmp_id"));
            pstmt_nps.executeUpdate();
            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //文章信息表
        out.println("<font color=red>Articles...</font><br>");
        sql_publish="Select a.*,b.top_site_id From articles a,topics b Where a.art_top_id=b.top_id";
        pstmt_publish=conn_publish.prepareStatement(sql_publish);
        rs_publish=pstmt_publish.executeQuery();
        sql_nps="insert into article(Id,oldid,title,subtitle,siteid,topic,keyword,author,important,Source,validdays,content,createdate,publishdate,creator,state,score) Values(seq_art.Nextval,?,?,?,?,?,?,?,?,?,?,empty_clob(),?,?,?,?,?)";
        pstmt_nps=conn_nps.prepareStatement(sql_nps);
        sql_clob = "select content from article where oldid=? for update";
        pstmt_clob=conn_nps.prepareStatement(sql_clob);
        rows=0;
        int warnings=0;
        while(rs_publish.next())
        {
            sql="select * from topic where oldid=?";
            pstmt=conn_nps.prepareStatement(sql);
            pstmt.setString(1,rs_publish.getString("art_top_id"));
            ResultSet rs=pstmt.executeQuery();
            if(!rs.next())
            {
                warnings++;
                out.println("Warning: No topic found, Skip "+rs_publish.getString("art_title")+"("+rs_publish.getString("art_id")+")<br>");
                out.flush();
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}
                continue;
            }

            String top_id = rs.getString("id");
            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}

/*
            out.println(rs_publish.getString("art_creater")+"<br>");
            sql = "select * from users";
            pstmt=conn_nps.prepareStatement(sql);
            rs=pstmt.executeQuery();
            while(rs.next())
            {
                out.println(rs.getString("oldid")+"<br>");
            }
            try{rs.close();}catch(Exception e){}
            try{pstmt.close();}catch(Exception e){}
*/            

            String author_id = "0";
            String creator_publish = rs_publish.getString("art_creater");
            if(creator_publish!=null && !"0".equals(creator_publish))
            {
                sql="select * from users where oldid=?";
                pstmt=conn_nps.prepareStatement(sql);
                pstmt.setString(1,creator_publish);
                rs=pstmt.executeQuery();
                if(!rs.next())
                {
                    warnings++;
                    out.println("Warning: No Author found, Set to System:"+rs_publish.getString("art_title")+"("+rs_publish.getString("art_id")+")<br>");
                    out.flush();
                    author_id = "0";
                }
                else
                {
                    author_id = rs.getString("id");
                }
                try{rs.close();}catch(Exception e){}
                try{pstmt.close();}catch(Exception e){}
            }
            
            pstmt_nps.setString(1,rs_publish.getString("art_id"));
            pstmt_nps.setString(2,rs_publish.getString("art_title"));
            pstmt_nps.setString(3,rs_publish.getString("art_subtitle"));
            pstmt_nps.setString(4,rs_publish.getString("top_site_id"));
            pstmt_nps.setString(5,top_id);
            pstmt_nps.setString(6,rs_publish.getString("art_keywords"));
            pstmt_nps.setString(7,rs_publish.getString("art_author"));
            pstmt_nps.setString(8,rs_publish.getString("art_importance"));
            pstmt_nps.setString(9,rs_publish.getString("art_source"));
            pstmt_nps.setString(10,rs_publish.getString("ART_VALIDDAYS"));
            pstmt_nps.setTimestamp(11,rs_publish.getTimestamp("ART_CREATED"));
            pstmt_nps.setTimestamp(12,rs_publish.getTimestamp("ART_PUBLISHDATE"));
            pstmt_nps.setString(13,author_id);
            switch(rs_publish.getInt("art_state"))
            {
                case 0://草稿
                    pstmt_nps.setInt(14,0);
                    break;
                case 3: //已发布
                    pstmt_nps.setInt(14,3);
                    break;
                default://待审核
                    pstmt_nps.setInt(14,1);
                    break;                
            }
            pstmt_nps.setString(15,rs_publish.getString("art_value"));

            pstmt_nps.executeUpdate();

            //更新Content
            CLOB clob = ((OracleResultSet)rs_publish).getCLOB("art_content");
            if(clob!=null)
            {
                 Reader is = null;
                 Writer writer = null;
                 try
                 {
                    pstmt_clob.setString(1,rs_publish.getString("art_id"));
                    rs = pstmt_clob.executeQuery();
                    rs.next();
                    CLOB clob_nps = ( oracle.sql.CLOB) rs.getClob(1);

                    is = clob.getCharacterStream();
                    writer = clob_nps.getCharacterOutputStream();
                    int b;
                    while( (b=is.read())!=-1)
                    {
                        writer.write(b);
                    }
                    writer.flush();
                }
                finally
                {
                    try{is.close();}catch(Exception e1){}
                    try{writer.close();}catch(Exception e1){}
                    try{rs.close();}catch(Exception e1){}
                }
            }

            rows++;
        }
        out.println("Total "+rows+", Warnings "+warnings+"<br><br><br>");
        out.flush();
        try{pstmt_clob.close();}catch(Exception e){}
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        //附件
        out.println("<font color=red>Attachments...</font><br>");
        sql_publish="select a.*,c.top_site_id from resources a,articles b,topics c Where a.rs_art_id=b.art_id And b.art_top_id=c.top_id";
        pstmt_publish=conn_publish.prepareStatement(sql_publish);
        rs_publish=pstmt_publish.executeQuery();
        sql_nps="insert into resources(id,oldid,caption,suffix,type,siteid,scope,remark,creator,createdate) select seq_attach.nextval,?,?,?,?,?,1,empty_clob(),creator,createdate from article where oldid=?";
        pstmt_nps=conn_nps.prepareStatement(sql_nps);
        String sql_attach="insert into attach(artid,resid,idx) select a.id,b.id,1 from article a,resources b where a.oldid=? and b.oldid=?";
        PreparedStatement pstmt_attach=conn_nps.prepareStatement(sql_attach);
        sql_clob = "select a.img_publish_dir||to_char(b.createdate,'/yyyy/MM/dd/')||b.Id||b.suffix From site a,resources b Where b.siteid=a.Id And b.oldid=?";
        pstmt_clob=conn_nps.prepareStatement(sql_clob);
        rows=0;
        while(rs_publish.next())
        {
            pstmt_nps.setString(1,rs_publish.getString("rs_id"));
            pstmt_nps.setString(2,rs_publish.getString("rs_caption"));
            String rs_name = rs_publish.getString("rs_name");
            int pos_dot = rs_name.lastIndexOf('.');
            if(pos_dot==-1)
            {
                pstmt_nps.setNull(3,java.sql.Types.VARCHAR);
                pstmt_nps.setInt(4,Resource.OTHER);
            }
            else
            {
                String suffix = rs_name.substring(pos_dot);
                suffix = suffix.trim().toLowerCase();
                if(suffix.length()>0 && !suffix.startsWith("."))
                     suffix = "."+suffix;

                pstmt_nps.setString(3,suffix);
                pstmt_nps.setInt(4, Resource.GuessType(suffix));
            }

            pstmt_nps.setString(5,rs_publish.getString("top_site_id"));
            pstmt_nps.setString(6,rs_publish.getString("rs_art_id"));
            pstmt_nps.executeUpdate();

            //添加attach
            pstmt_attach.setString(1,rs_publish.getString("rs_art_id"));
            pstmt_attach.setString(2,rs_publish.getString("rs_id"));
            pstmt_attach.executeUpdate();

            //附件保存到物理文件中
            BLOB blob = ((OracleResultSet)rs_publish).getBLOB("rs_data");
            if(blob!=null)
            {
                InputStream is = null;
                OutputStream writer = null;
                ResultSet rs = null;

                try
                {
                   pstmt_clob.setString(1,rs_publish.getString("rs_id"));
                   rs = pstmt_clob.executeQuery();
                   if(!rs.next())
                   {
                       out.println("Warning: No article found, Skip attachment:"+rs_name+"("+rs_publish.getString("rs_id")+")<br>");
                   }
                   else
                   {
                       File f = new File(rs.getString(1));
                       f.getParentFile().mkdirs();

                       is = blob.getBinaryStream();
                       writer = new FileOutputStream(f);
                       int b;
                       while( (b=is.read())!=-1)
                       {
                           writer.write(b);
                       }
                       writer.flush();
                   }
                }
                finally
                {
                   try{is.close();}catch(Exception e1){}
                   try{writer.close();}catch(Exception e1){}
                   try{rs.close();}catch(Exception e1){}
                }
            }

            rows++;
        }
        out.println("Total "+rows+"<br><br><br>");
        out.flush();
        try{pstmt_clob.close();}catch(Exception e){}
        try{pstmt_attach.close();}catch(Exception e){}
        try{pstmt_nps.close();}catch(Exception e){}
        try{rs_publish.close();}catch(Exception e){}
        try{pstmt_publish.close();}catch(Exception e){}

        conn_nps.commit();
        out.println("<font color=red>Done!</font>");
        out.flush();
    }
    catch(Exception e)
    {
        conn_nps.rollback();
        throw e;
    }
    finally
    {
        try{conn_nps.close();}catch(Exception e){}
        try{conn_publish.close();}catch(Exception e){}
    }    
%>