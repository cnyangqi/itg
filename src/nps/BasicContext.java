package nps;

import nps.core.Site;
import nps.core.User;
import nps.core.Field;
import nps.core.NpsClassLoader;
import nps.core.Config;
import nps.exception.NpsException;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.Calendar;
import java.io.File;

/**
 * BasicContext - 基础上下文句柄
 *
 * Embedded lightweight workflow engine
 * Copyright: Copyright (c) 2011
 *
 * @author jialin, lanxi justa network co.,ltd.
 * @version 2.2
 */
public class BasicContext extends PublishableObject
{
    protected Connection conn = null;
    protected User user = null;
    protected HashMap environment_vars = null; //全局系统环境变量
    public Site  site = null;  //当前Site对象
    public BasicContext(Connection conn, User user) throws SQLException
    {
        this.conn = conn;
        this.user = user;
        if(conn.getAutoCommit()) conn.setAutoCommit(false);
    }

    public Connection GetConnection()
    {
        return conn;
    }

    public PreparedStatement PrepareStatement(String sql) throws SQLException
    {
        return conn.prepareStatement(sql);
    }

    public User GetUser()
    {
        return user;
    }

    public String GetUserId()
    {
        return user.GetId();
    }

    public String GetUserName()
    {
        return user.GetName();
    }

    public String GetDeptId()
    {
        return user.GetDeptId();
    }

    public String GetUnitId()
    {
        return user.GetUnitId();
    }

    public void SetUser(User user)
    {
        this.user = user;
    }
    
    public void Commit()
    {
        if(conn!=null) try{conn.commit();}catch(Exception e){}
    }

    public void Rollback()
    {
        if(conn!=null) try{conn.rollback();}catch(Exception e){}
    }

    public NpsClassLoader GetClassLoader()
    {
        return Config.GetClassLoader();
    }

    //IPublishable系列方法
    public File GetOutputFile()
    {
        return null;
    }

    public String GetURL()
    {
        return null;
    }

    public String GetRelativeURL()
    {
        return null;
    }

    public boolean HasField(String fieldName)
    {
        if(fieldName==null || fieldName.length()==0) return false;

        String key = fieldName.trim();
        if(key.length()==0) return false;

        key = key.toUpperCase();

        if(key.equalsIgnoreCase("env_now") || key.equalsIgnoreCase("now"))  return true;
        if(key.equalsIgnoreCase("env_today") || key.equalsIgnoreCase("today")) return true;
        if(key.equalsIgnoreCase("env_yesterday") || key.equalsIgnoreCase("yesterday")) return true;
        if(key.equalsIgnoreCase("env_tomorrow") || key.equalsIgnoreCase("tomorrow")) return true;
        if(key.equalsIgnoreCase("env_prevmonth") || key.equalsIgnoreCase("prevmonth")) return true;
        if(key.equalsIgnoreCase("env_nextmonth") || key.equalsIgnoreCase("nextmonth")) return true;
        if(key.equalsIgnoreCase("env_prevyear") || key.equalsIgnoreCase("prevyear")) return true;
        if(key.equalsIgnoreCase("env_nextyear") || key.equalsIgnoreCase("nextyear")) return true;

        if(environment_vars!=null && environment_vars.containsKey(key)) return true;
        return false;
    }

    public Field GetField(String fieldName) throws NpsException
    {
        if(fieldName==null || fieldName.length()==0) return Field.Null;

        String key = fieldName.trim();
        if(key.length()==0) return Field.Null;

        key = key.toUpperCase();

        if(   key.equalsIgnoreCase("env_now") || key.equalsIgnoreCase("now")
           || key.equalsIgnoreCase("env_today") || key.equalsIgnoreCase("today")
          )
        {
            return new Field(new java.util.Date());
        }

        if(key.equalsIgnoreCase("env_yesterday") || key.equalsIgnoreCase("yesterday"))
        {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DATE, -1);
            return new Field(cal.getTime());
        }

        if(key.equalsIgnoreCase("env_tomorrow") || key.equalsIgnoreCase("tomorrow"))
        {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DATE, 1);
            return new Field(cal.getTime());
        }

        if(key.equalsIgnoreCase("env_prevmonth") || key.equalsIgnoreCase("prevmonth"))
        {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MONTH, -1);
            return new Field(cal.getTime());
        }

        if(key.equalsIgnoreCase("env_nextmonth") || key.equalsIgnoreCase("nextmonth"))
        {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MONTH, 1);
            return new Field(cal.getTime());
        }

        if(key.equalsIgnoreCase("env_prevyear") || key.equalsIgnoreCase("prevyear"))
        {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.YEAR, -1);
            return new Field(cal.getTime());
        }

        if(key.equalsIgnoreCase("env_nextyear") || key.equalsIgnoreCase("nextyear"))
        {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.YEAR, 1);
            return new Field(cal.getTime());
        }

        if(environment_vars!=null && environment_vars.containsKey(key)) return new Field(GetEnvironmentValue(key));

        return Field.Null;
    }

    //自定义全局变量系列方法
    //增加全局自定义变量
    public void SetEnvironmentVar(String name,Object value)
    {
        name = name.toUpperCase();
        if(environment_vars==null) environment_vars = new HashMap();
        if(environment_vars.containsKey(name))  environment_vars.remove(name);

        environment_vars.put(name,value);
    }

    public void RemoveEnvironmentVar(String name)
    {
        if(environment_vars==null) return;

        name = name.toUpperCase();
        if(environment_vars.containsKey(name))  environment_vars.remove(name);
    }

    public String[] GetEnvironmentVarList()
    {
        if(environment_vars == null || environment_vars.size()==0) return null;

        return (String[])environment_vars.keySet().toArray();
    }

    public Object GetEnvironmentValue(String name)
    {
        if(environment_vars==null || environment_vars.size()==0) return null;

        name = name.toUpperCase();
        return environment_vars.get(name);
    }

    public String GetEnvironmentString(String name)
    {
        if(environment_vars==null || environment_vars.size()==0) return null;

        name = name.toUpperCase();
        return environment_vars.get(name).toString();
    }

    //关闭
    public void Clear()
    {
        if(conn!=null) 
        {
            try{conn.commit();}catch(Exception e){}
            try{conn.close();}catch(Exception e){}
        }
        conn = null;
    }

    public String toString()
    {
        return "uid="+user.GetUID();
    }
}
