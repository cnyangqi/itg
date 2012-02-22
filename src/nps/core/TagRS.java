package nps.core;

import java.sql.Date;
import java.util.*;
import java.io.*;
import java.sql.*;
import java.io.Reader;
import oracle.sql.CLOB;
import oracle.jdbc.driver.OracleResultSet;

import nps.util.*;
import nps.exception.NpsException;
import nps.BasicContext;
import nps.PublishableObject;

/**
 * 管理结果集对象
 * NPS - a new publishing system
 * Copyright (c) 2007
 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
 */

public class TagRS extends PublishableObject
{
    private BasicContext   ctxt = null;
    private int       rowno = 0;

    private Hashtable fields = new Hashtable();

    //缺省构造函数
    public TagRS()
    {

    }

    //Constructor
    //位于except中的数据将不被加载,except中字段名必须以大写字母出现
    public TagRS(NpsContext  ctxt,ResultSet rs,TagFieldExcept except) throws java.sql.SQLException
    {
        this.ctxt = ctxt;
        rowno = rs.getRow();

        LoadDataFromResultSet(rs,except);
    }

    //Constructor
    //加载RS中的所有数据
    public TagRS(NpsContext ctxt,ResultSet rs) throws java.sql.SQLException
    {
        this.ctxt = ctxt;
        rowno = rs.getRow();

        LoadDataFromResultSet(rs,null);
    }
    public TagRS(BasicContext ctxt,ResultSet rs) throws java.sql.SQLException
    {
        this.ctxt = ctxt;
        rowno = rs.getRow();

        LoadDataFromResultSet(rs,null);
    }
    private void LoadDataFromResultSet(ResultSet rs,TagFieldExcept except) throws java.sql.SQLException
    {
        java.sql.ResultSetMetaData rsmd = rs.getMetaData();
        for(int i=1 ;i<=rsmd.getColumnCount();i++)
        {
            String col_name = rsmd.getColumnName(i);
            col_name = col_name.toUpperCase();

            //如果数据出现在except清单中就跳过
            if(except!=null && except.containsKey(col_name)) continue;

            int col_type = rsmd.getColumnType(i);

            //有些数据无法支持，就跳过
            if(col_type==java.sql.Types.BLOB || col_type==java.sql.Types.JAVA_OBJECT
              || col_type==java.sql.Types.LONGVARBINARY || col_type==java.sql.Types.VARBINARY
              || col_type==java.sql.Types.STRUCT || col_type==java.sql.Types.REF
              || col_type==java.sql.Types.OTHER || col_type==java.sql.Types.DATALINK
              || col_type==java.sql.Types.DISTINCT || col_type==java.sql.Types.LONGVARCHAR)
            {
                DefaultLog.info(col_name+" not supported,skipped...");
                continue;
            }

            Object col_obj = null;

            //clob字段不加载数据
            if(col_type==java.sql.Types.CLOB)
            {
                CLOB clob = ((OracleResultSet)rs).getCLOB(i);
                if(clob!=null)
                {
                    Reader is = null;
                    OutputStreamWriter so = null;
                    try
                    {
                        is = clob.getCharacterStream();
                        //BufferedReader br = new BufferedReader(is);
                        //String s = br.readLine();
                        File clob_file = new File(GetClobFileName(col_name));
                        clob_file.mkdirs();
                        if (clob_file.exists())  try{clob_file.delete();}catch(Exception e1){}
                        clob_file.createNewFile();
                        clob_file.deleteOnExit(); //自动清理

                        FileOutputStream fo = new FileOutputStream(clob_file);
                        //PrintStream so = new PrintStream(fo);
                        so = new OutputStreamWriter(fo,"UTF-8");
                        int b;
                        while( (b=is.read())!=-1)
                        {
                            so.write(b);
                        }
                        col_obj = clob_file;
                    }
                    catch(Exception e)
                    {
                        DefaultLog.error_noexception(e);
                    }
                    finally
                    {
                        try{so.close();}catch(Exception e){}
                        try{is.close();}catch(Exception e){}
                    }
                }
            }
            else if(col_type==java.sql.Types.DATE  || col_type==java.sql.Types.TIME || col_type==java.sql.Types.TIMESTAMP)
            {
                //bugfix: 2010-06-05 jialin
                //   Java默认通过rs.getObject()读取到的日期没有时分秒
                col_obj = rs.getTimestamp(col_name);
            }
            else
            {
                col_obj = rs.getObject(col_name);
            }

            TagSQLField field = new TagSQLField(col_name,col_type,col_obj);
            fields.put(col_name,field);
        }
    }

    //清理临时文件
    public void Clear()
    {
        if(fields==null) return;
        java.util.Enumeration elements_fld = fields.elements();
        while(elements_fld.hasMoreElements())
        {
            TagSQLField f = (TagSQLField)elements_fld.nextElement();
            if((f.type == java.sql.Types.CLOB) && (f.value!=null))
            {
                File temp_clob_file = (File)f.value;
                try{temp_clob_file.delete();}catch(Exception e){}

                f.value = null;
            }
        }

    }

    //增加一个Field到列表中，每次仅缓存一条记录
    public void PushField(String name,int type,Object value)
    {
        if(name==null || name.length()==0) return;

        String key = name.trim();
        if(key.length()==0) return;
        key = key.toUpperCase();

        TagSQLField field = null;
        if(fields.isEmpty() || !fields.containsKey(key))
        {
            field = new TagSQLField(key,type,value);
            fields.put(key,field);
            return;
        }

        //reset value
        field = (TagSQLField)fields.get(name);
        field.type = type;
        field.value = value;
    }

    //返回field名称列表
    public Enumeration GetFieldNames()
    {
        if(fields.isEmpty()) return null;
        return fields.keys();
    }

    //根据特定格式format格式化字段
    public String GetURL()
    {
        return null;
    }

    public String GetRelativeURL()
    {
        return null;
    }

    public File   GetOutputFile()
    {
        return null;
    }

    //CLOB字段保存到临时文件中
    private String GetClobFileName(String name)
    {
        return Config.ARTICLE_TEMP + File.separator + "tagrs" + "$" + Integer.toHexString(hashCode()) +"$"+ name +".rs";
    }

    public boolean HasField(String fieldName)
    {
        if(fieldName==null || fieldName.length()==0) return false;

        String key = fieldName.trim();
        if(key.length()==0) return false;

        key = key.toUpperCase();
        if(fields.containsKey(key)) return true;
        return false;
    }

    //获取Field值
    public Field GetField(String name) throws NpsException
    {
       if(name==null) return Field.Null;

       String key = name.trim();
       if(key.length()==0) return Field.Null;
       key = key.toUpperCase();

       if(key.equalsIgnoreCase("rowno")) return new Field(new Integer(rowno));

       if(fields.isEmpty() || !fields.containsKey(key))  return Field.Null;

       TagSQLField field = (TagSQLField)fields.get(key);
/*     if(field.value instanceof File)
       {
           try
           {
                return new Field(new InputStreamReader(new FileInputStream((File)field.value),"UTF-8"));
           }
           catch(Exception e)
           {
                nps.util.DefaultLog.error(e);
           }
       }
*/
       //2010.03.14 减少instanceof判断
       switch(field.type)
       {
           case java.sql.Types.CLOB:
               try
               {
                    File  f = (File)field.value;
                    if(f == null) return Field.Null;
                   
                    return new Field(new InputStreamReader(new FileInputStream(f),"UTF-8"));
               }
               catch(Exception e)
               {
                    nps.util.DefaultLog.error(e);
               }
               break;

           case Types.CHAR:
           case Types.VARCHAR:   
               return new Field((String)field.value);

           case Types.DECIMAL:
           case Types.NUMERIC:
           case Types.DOUBLE:
           case Types.REAL:
           case Types.FLOAT:
           case Types.BIGINT:
           case Types.INTEGER:
           case Types.SMALLINT:
           case Types.TINYINT:    
               return new Field((Number)field.value);
           
           case Types.TIMESTAMP:
           case Types.TIME:
           case Types.DATE:
               java.sql.Timestamp t = (Timestamp)field.value;
               return t!=null?new Field(new java.util.Date(t.getTime())):new Field((Date)null);
       }

       return new Field(field.value);
    }

    //sql field
    //CLOB字段value为空，需要手工加载
    class TagSQLField
    {
        public String name = null;
        public int    type = -1;
        public Object value = null;

        public TagSQLField(String n,int t,Object v)
        {
            this.name = n;
            this.type = t;
            this.value = v;
        }
    }

    //Except清单
    public class TagFieldExcept
    {
        private Hashtable except = new Hashtable();

        public TagFieldExcept()
        {
        }

        public void put(String name)
        {
            if(name==null) return;

            String key = name.trim().toUpperCase();
            if(key.length()==0) return;

            if(except.containsKey(key)) return;
            except.put(name,name);
        }

        public boolean containsKey(String name)
        {
            if(name==null) return false;

            String key = name.trim().toUpperCase();
            if(key.length()==0) return false;

            if(except.containsKey(key)) return true;
            return false;
        }
    }
}
