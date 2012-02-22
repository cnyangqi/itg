package nps.apps.poll;

import nps.exception.NpsException;
import nps.exception.ErrorHelper;
import nps.util.DefaultLog;
import nps.core.Site;
import nps.core.User;
import nps.core.NpsContext;

import java.util.Date;
import java.util.ArrayList;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * 网上投票模块
 * NPS - a new publishing system
 * Copyright (c) 2011
 *
 * @author jialin, lanxi justa network co.,ltd.
 * @version 2.1
 */
public class Poll
{
    public final static int TYPE_SINGLE_ANSWER = 0;
    public final static int TYPE_MULTIPLE_CHOICE = 1;

    public final static int VIEW_HORIZONTAL_BAR = 0;
    public final static int VIEW_VERTICAL_BAR = 1;
    public final static int VIEW_PIE = 2;

    public final static int STATUS_NEW = 0;
    public final static int STATUS_RUNNING = 1;
    public final static int STATUS_STOPPED = 2;
    public final static int STATUS_ABORTED = 3;

    public final static int ALLOW_NONE_SAME_IP = 0;
    public final static int ALLOW_SAME_IP = 1;
    public final static int ALLOW_SAME_IP_CONDITIONAL = 2;

    private String id = null;
    private String question = null;
    private String site_id = null;
    private int type = TYPE_SINGLE_ANSWER;
    private int view_type = VIEW_HORIZONTAL_BAR;

    private int status = STATUS_NEW;
    private int allow_same_ip = ALLOW_NONE_SAME_IP;

    private int same_ip_internal = 0;//Seconds
    private boolean member_only = false; //必须登录

    private String creator = null;
    private String creator_name = null;
    private Date create_date = null;

    private ArrayList<Option> options = null;
    private boolean bNew = true;
    
    public Poll(Site site, String question, int type, int view_type)
    {
        this.site_id = site.GetId();
        this.question = question;
        this.type = type;
        this.view_type = view_type;
    }

    public Poll(NpsContext ctxt, String id) throws NpsException
    {
        this(ctxt.GetConnection(),id);
    }

    public Poll(Connection conn, String id) throws NpsException
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            String sql = "select * from APP_POLL where id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            rs = pstmt.executeQuery();
            if(!rs.next()) throw new NpsException(ErrorHelper.SYS_UNKOWN, "Poll #" + id + " not exist");

            this.id = rs.getString("id");
            this.question = rs.getString("question");
            this.site_id = rs.getString("siteid");
            this.type = rs.getInt("type");
            this.view_type = rs.getInt("view_type");
            this.status = rs.getInt("status");
            this.allow_same_ip = rs.getInt("same_ip");
            this.same_ip_internal = rs.getInt("same_ip_time");
            this.member_only = rs.getInt("member_only")==1;
            this.creator = rs.getString("creator");
            this.creator_name = rs.getString("creator_name");
            this.create_date = rs.getTimestamp("create_date");
            this.bNew = false;
            
            try{rs.close();}catch(Exception e){}
            sql = "select * from APP_POLL_OPTIONS where poll_id=? order by idx";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            rs = pstmt.executeQuery();
            while(rs.next())
            {
                if(options==null) options = new ArrayList();
                Option option = new Option(rs.getString("option_id"),rs.getString("txt"), rs.getInt("idx"));
                option.SetNumber(rs.getLong("total"));
                options.add(option);
            }
        }
        catch(SQLException sql_e)
        {
            DefaultLog.error(sql_e);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
    }

    public void Save(NpsContext ctxt) throws NpsException
    {
        Save(ctxt.GetConnection());
    }

    public void Save(Connection conn) throws NpsException
    {
        try
        {
            if(bNew)
            {
                Insert(conn);
            }
            else
            {
                Update(conn);
            }
        }
        catch(SQLException sql_e)
        {
            try{conn.rollback();}catch(Exception e){}
            DefaultLog.error(sql_e);
        }
    }

    private String GenerateId(Connection conn) throws SQLException
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try
        {
            String sql = "select seq_poll.nextval from dual";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if(rs.next()) return rs.getString(1);
        }
        finally
        {
            if(rs!=null) try{rs.close();}catch(Exception e){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }

        return null;
    }

    private void Insert(Connection conn) throws SQLException
    {
        PreparedStatement pstmt = null;
        try
        {
            this.id = GenerateId(conn);
            this.bNew = false;
            
            String sql = "insert into APP_POLL(id,question,siteid,type,view_type,status," +
                    "same_ip,same_ip_time,member_only,creator,creator_name,create_date) " +
                    "values(?,?,?,?,?,?,?,?,?,?,?,sysdate)";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.setString(2,question);
            pstmt.setString(3,site_id);
            pstmt.setInt(4,type);
            pstmt.setInt(5,view_type);
            pstmt.setInt(6,status);
            pstmt.setInt(7,allow_same_ip);
            pstmt.setInt(8,same_ip_internal);
            pstmt.setInt(9,member_only?1:0);
            pstmt.setString(10,creator);
            pstmt.setString(11,creator_name);
            pstmt.executeUpdate();

            if(options!=null && options.size()>0)
            {
                try{pstmt.close();}catch(Exception e){}
                sql = "insert into APP_POLL_OPTIONS(option_id,poll_id,txt,idx) values(?,?,?,?)";
                pstmt = conn.prepareStatement(sql);
                int index = 1;
                for(Option option:options)
                {
                    option.SetId(GenerateId(conn));
                    pstmt.setString(1,option.GetId());
                    pstmt.setString(2,id);
                    pstmt.setString(3,option.GetOption());
                    pstmt.setInt(4,index++);
                    pstmt.executeUpdate();
                    option.SetNewflag(false);
                }
            }
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
    }

    //Update操作将清空所有投票数据
    private void Update(Connection conn) throws SQLException
    {
        PreparedStatement pstmt = null;
        try
        {
            ClearVotes(conn);

            String sql = "update APP_POLL set question=?,siteid=?,type=?,view_type=?," +
                    "same_ip=?,same_ip_time=?,member_only=? where id=?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,question);
            pstmt.setString(2,site_id);
            pstmt.setInt(3,type);
            pstmt.setInt(4,view_type);
            pstmt.setInt(5,allow_same_ip);
            pstmt.setInt(6,same_ip_internal);
            pstmt.setInt(7,member_only?1:0);
            pstmt.setString(8,id);
            pstmt.executeUpdate();

            try{pstmt.close();}catch(Exception e){}
            sql = "delete from APP_POLL_OPTIONS where poll_id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();

            if(options!=null && options.size()>0)
            {
                try{pstmt.close();}catch(Exception e){}
                sql = "insert into APP_POLL_OPTIONS(option_id,poll_id,txt,idx) values(?,?,?,?)";
                pstmt = conn.prepareStatement(sql);
                int index = 1;
                for(Option option:options)
                {
                    if(option.isNew())
                    {
                        option.SetId(GenerateId(conn));
                        option.SetNewflag(false);
                    }
                    pstmt.setString(1,option.GetId());
                    pstmt.setString(2,id);
                    pstmt.setString(3,option.GetOption());
                    pstmt.setInt(4,index++);
                    pstmt.executeUpdate();
                }
            }
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
    }

    public void Delete(Connection conn) throws SQLException
    {
        PreparedStatement pstmt = null;
        try
        {
            ClearVotes(conn);

            String sql = "delete from APP_POLL_OPTIONS where poll_id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();

            try{pstmt.close();}catch(Exception e){}
            sql = "delete from APP_POLL where id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
    }

    private void ClearVotes(Connection conn) throws SQLException
    {
        PreparedStatement pstmt = null;
        try
        {
            String sql = "delete from APP_POLL_ANSWER where vote_id in (select vote_id from APP_POLL_VOTE where poll_id=?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();
            try{pstmt.close();}catch(Exception e){}

            sql = "delete from APP_POLL_VOTE where poll_id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1,id);
            pstmt.executeUpdate();            
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
    }

    public void Start(NpsContext ctxt) throws NpsException
    {
        Start(ctxt.GetConnection());
    }

    public void Start(Connection conn) throws NpsException
    {
        UpdateStatus(conn, STATUS_RUNNING);
    }

    public void Stop(NpsContext ctxt) throws NpsException
    {
        Stop(ctxt.GetConnection());
    }

    public void Stop(Connection conn) throws NpsException
    {
        UpdateStatus(conn, STATUS_STOPPED);
    }

    public void Abort(NpsContext ctxt) throws NpsException
    {
        Abort(ctxt.GetConnection());
    }

    public void Abort(Connection conn) throws NpsException
    {
        UpdateStatus(conn, STATUS_ABORTED);
    }

    private void UpdateStatus(Connection conn, int status) throws NpsException
    {
        PreparedStatement pstmt = null;
        try
        {
            if(bNew)
            {
                this.status = status;
                Insert(conn);
                return;
            }

            String sql = "update APP_POLL set status=? where id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1,status);
            pstmt.setString(2,id);
            pstmt.executeUpdate();

            this.status = status;
        }
        catch(SQLException sql_e)
        {
            try{conn.rollback();}catch(Exception e1){}
            DefaultLog.error(sql_e);
        }
        finally
        {
            if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        }
    }


    public String GetId()
    {
        return id;
    }

    public String GetQuestion()
    {
        return question;
    }

    public void SetQuestion(String s)
    {
        this.question = s;
    }

    public int GetStatus()
    {
        return status;
    }

    public boolean isNew()
    {
        return status == STATUS_NEW;
    }
    
    public boolean isRunning()
    {
        return status == STATUS_RUNNING;
    }

    public boolean isStopped()
    {
        return status == STATUS_STOPPED;
    }

    public boolean isAborted()
    {
        return status == STATUS_ABORTED;
    }

    public void SetStatus(int i)
    {
        this.status = i;
    }

    public String GetSiteId()
    {
        return site_id;
    }

    public void SetSite(String s)
    {
        this.site_id = s;
    }

    public void SetSite(Site site)
    {
        this.site_id = site.GetId();
    }

    public int GetType()
    {
        return type;
    }

    public boolean isSingleAnswer()
    {
        return type == TYPE_SINGLE_ANSWER;
    }

    public boolean isMultipleChoice()
    {
        return type == TYPE_MULTIPLE_CHOICE;
    }

    public void SetType(int i)
    {
        type = i;
    }

    public int GetViewType()
    {
        return view_type;
    }

    public void SetViewType(int i)
    {
        this.view_type = i;
    }

    public int GetAllowSameIP()
    {
        return allow_same_ip;
    }

    public boolean notAllowSameIP()
    {
        return allow_same_ip == ALLOW_NONE_SAME_IP;
    }

    public boolean allowAllIP()
    {
        return allow_same_ip == ALLOW_SAME_IP;
    }

    public boolean allowConditional()
    {
        return allow_same_ip == ALLOW_SAME_IP_CONDITIONAL;
    }

    public void SetAllowSameIP(int i)
    {
        allow_same_ip = i;
    }

    public int GetSameIPInternal()
    {
        return same_ip_internal;
    }

    public void SetSameIPInternal(int i)
    {
        same_ip_internal = i;
    }

    public boolean MemberOnly()
    {
        return member_only;
    }

    public void SetMemberOnly(boolean b)
    {
        member_only = b;
    }

    public String GetCreator()
    {
        return creator;
    }

    public String GetCreatorName()
    {
        return creator_name;
    }

    public Date GetCreateDate()
    {
        return create_date;
    }

    public void SetCreator(User user)
    {
        this.creator = user.GetUID();
        this.creator_name = user.GetName();
    }

    public ArrayList<Option> GetOptions()
    {
        return options;
    }

    public void ClearOptions()
    {
        options = null;
    }

    public void AddOption(String option)
    {
        if(options==null) options = new ArrayList();
        Option op = new Option(option);
        options.add(op);
    }

    public void AddOption(String option, int index)
    {
        if(options==null) options = new ArrayList();
        Option op = new Option(option, index);
        options.add(index,op);
    }

    public void AddOption(String id,String option)
    {
        if(options==null) options = new ArrayList();
        Option op = new Option(id,option,options.size()+1);
        options.add(op);
    }

    public void AddOption(String id,String option,int index)
    {
        if(options==null) options = new ArrayList();
        Option op = new Option(id,option,index);
        options.add(index,op);
    }
}
