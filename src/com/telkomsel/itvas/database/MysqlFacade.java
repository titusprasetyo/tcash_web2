package com.telkomsel.itvas.database;

import com.telkomsel.itvas.webstarter.WebStarterProperties;
import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import org.apache.commons.dbcp.ConnectionFactory;
import org.apache.commons.dbcp.DriverManagerConnectionFactory;
import org.apache.commons.dbcp.PoolableConnectionFactory;
import org.apache.commons.dbcp.PoolingDataSource;
import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.commons.pool.KeyedObjectPoolFactory;
import org.apache.commons.pool.ObjectPool;
import org.apache.commons.pool.PoolableObjectFactory;
import org.apache.commons.pool.impl.GenericObjectPool;
import org.apache.log4j.Logger;

public class MysqlFacade {
    private InitialContext ctx;
    private DataSource ds;
    private GenericObjectPool connectionPool;
    private ConnectionFactory connectionFactory;
    private static MysqlFacade instance = null;

    private MysqlFacade() {
    	System.out.println("State : Init MysqlFacade");
        try {
            this.ctx = new InitialContext();
            String dsName = WebStarterProperties.getInstance().getProperty("jndi.datasource");
            System.out.println("Data Source Name : " + dsName);
            this.ds = (DataSource)this.ctx.lookup(dsName);
        }
        catch (Exception e) {
            Logger.getLogger((Class)MysqlFacade.class).error((Object)"Cannot initalize Context, try to using standalone DBCP", (Throwable)e);
        }
    }

    private MysqlFacade(String url, String username, String password) {
        this.connectionPool = new GenericObjectPool(null);
        try {
            Class.forName("com.mysql.jdbc.Driver");
        }
        catch (ClassNotFoundException e1) {
            e1.printStackTrace();
        }
        this.connectionPool.setMinIdle(2);
        this.connectionPool.setMaxActive(10);
        this.connectionFactory = new DriverManagerConnectionFactory(url, username, password);
        PoolableConnectionFactory poolableConnectionFactory = new PoolableConnectionFactory(this.connectionFactory, (ObjectPool)this.connectionPool, null, null, false, true);
        this.ds = new PoolingDataSource((ObjectPool)this.connectionPool);
    }

    public static void initStandalone(String url, String username, String password) {
        if (instance == null) {
            instance = new MysqlFacade(url, username, password);
        }
    }

    public static Connection getConnection() throws SQLException {
        if (instance == null) {
            instance = new MysqlFacade();
        }
        if (MysqlFacade.instance.ds == null) {
            return null;
        }
        return MysqlFacade.instance.ds.getConnection();
    }

    public static void terminateFacade() {
        if (MysqlFacade.instance.connectionPool != null) {
            MysqlFacade.instance.connectionPool.clear();
        }
    }

    public static QueryRunner getQueryRunner() {
    	System.out.println("State : getQueryRunner");
        if (instance == null) {
        	System.out.println("State : getQueryRunner null");
            instance = new MysqlFacade();
        }
        System.out.println("Instance : " + instance.ds.toString());
        return new QueryRunner(MysqlFacade.instance.ds);
    }

    public static Object getScalar(String q, Object[] params, String columnName) throws SQLException {
        Object result;
        QueryRunner qr = MysqlFacade.getQueryRunner();
        Connection conn = null;
        result = null;
        try {
            conn = MysqlFacade.getConnection();
            result = qr.query(conn, q, params, (ResultSetHandler)new ScalarHandler(columnName));
        }
        finally {
            DbUtils.closeQuietly((Connection)conn);
        }
        return result;
    }

    public static Object getObject(String q, Object[] params, ResultSetHandler handler) throws SQLException {
        Object result;
        QueryRunner qr = MysqlFacade.getQueryRunner();
        Connection conn = null;
        result = null;
        try {
            conn = MysqlFacade.getConnection();
            result = qr.query(q, params, handler);
        }
        finally {
            DbUtils.closeQuietly((Connection)conn);
        }
        return result;
    }

    public static Object getScalar(String q, Object param, String columnName) throws SQLException {
        Object result;
        QueryRunner qr = MysqlFacade.getQueryRunner();
        Connection conn = null;
        result = null;
        try {
            conn = MysqlFacade.getConnection();
            result = qr.query(q, param, (ResultSetHandler)new ScalarHandler(columnName));
        }
        finally {
            DbUtils.closeQuietly((Connection)conn);
        }
        return result;
    }

    public static int update(String q, Object[] params) throws SQLException {
        QueryRunner qr = MysqlFacade.getQueryRunner();
        Connection conn = null;
        try {
            conn = MysqlFacade.getConnection();
            int n = qr.update(conn, q, params);
            return n;
        }
        catch (SQLException e) {
            throw e;
        }
        finally {
            DbUtils.closeQuietly((Connection)conn);
        }
    }

    public static int update(String q, Object param) throws SQLException {
        QueryRunner qr = MysqlFacade.getQueryRunner();
        Connection conn = null;
        try {
            conn = MysqlFacade.getConnection();
            int n = qr.update(conn, q, param);
            return n;
        }
        catch (SQLException e) {
            throw e;
        }
        finally {
            DbUtils.closeQuietly((Connection)conn);
        }
    }
}