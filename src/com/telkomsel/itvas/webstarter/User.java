package com.telkomsel.itvas.webstarter;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.webstarter.Menu;
import com.telkomsel.itvas.webstarter.MenuManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import org.apache.log4j.Logger;
import tsel_tunai.Util;

/*
 * This class specifies class file version 49.0 but uses Java 6 signatures.  Assumed Java 6.
 */
public class User {
    private long id;
    private String username;
    private String fullName;
    private String email;
    private String password;
    private int role;
    private String roleDescription;
    private ArrayList<Menu> eligibleMenus;
    private boolean isPasswordExpired = false;
    private int loginAttempt;
    private String accountExpiry;
    private boolean isAccountExpired = false;

    public User(int id, String username, String password, String fullname, String email, int role, String roleDescription, boolean passwordExpired, int loginAttempt, Date accountExpiry) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullname;
        this.role = role;
        this.roleDescription = roleDescription;
        this.eligibleMenus = MenuManager.getEligibleMenus((int)role, (boolean)passwordExpired);
        this.isPasswordExpired = passwordExpired;
        this.loginAttempt = loginAttempt;
    }

    public User() {
    }

    public void init() {
        this.eligibleMenus = MenuManager.getEligibleMenus((int)this.role, (boolean)this.isPasswordExpired);
    }

    public String getUsername() {
        return this.username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return this.email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return this.password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean equals(Object obj) {
        if (obj instanceof User && this.username.equals(((User)obj).username)) {
            return true;
        }
        return false;
    }

    public String getFullName() {
        return this.fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public int getRole() {
        return this.role;
    }

    public void setRole(int role) {
        this.role = role;
    }

    public String getRoleDescription() {
        return this.roleDescription;
    }

    public ArrayList<Menu> getEligibleMenus() {
        return this.eligibleMenus;
    }

    public void setEligibleMenus(ArrayList<Menu> eligibleMenus) {
        this.eligibleMenus = eligibleMenus;
    }

    public void setRoleDescription(String roleDescription) {
        this.roleDescription = roleDescription;
    }

    public void updatePassword(String newPassword) {
        try {
            MysqlFacade.update((String)"UPDATE tsel_webstarter_user SET password=?, password_expiry=ADDDATE(sysdate, INTERVAL 90 DAY) WHERE username=?", (Object[])new Object[]{Util.getMd5Digest((String)newPassword), this.username});
            MysqlFacade.update((String)"INSERT INTO tsel_webstarter_password_history (username, password, dt) VALUES (?,?,sysdate)", (Object[])new Object[]{this.username, Util.getMd5Digest((String)newPassword)});
            this.isPasswordExpired = false;
        }
        catch (Exception e) {
            Logger.getLogger((Class)User.class).error((Object)"Cannot update password", (Throwable)e);
        }
    }

    public boolean testPassword(String oldPassword) {
        String query = "SELECT username FROM tsel_webstarter_user WHERE username=? AND password=md5(?)";
        try {
            Object result = MysqlFacade.getScalar((String)query, (Object[])new String[]{this.username, oldPassword}, (String)"username");
            if (result != null) {
                return true;
            }
            return false;
        }
        catch (Exception e1) {
            return false;
        }
    }

    public boolean isPasswordExpired() {
        return this.isPasswordExpired;
    }

    public void setPasswordExpired(boolean isPasswordExpired) {
        this.isPasswordExpired = isPasswordExpired;
    }

    public boolean isInPasswordHistory(String newPassword) {
        String query = "SELECT username FROM tsel_webstarter_password_history WHERE username=? AND password=? AND DATEDIFF(sysdate, dt) < 365";
        try {
            Object result = MysqlFacade.getScalar((String)query, (Object[])new String[]{this.username, Util.getMd5Digest((String)newPassword)}, (String)"username");
            if (result != null) {
                return true;
            }
            return false;
        }
        catch (Exception e1) {
            return false;
        }
    }

    public long getId() {
        return this.id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public boolean update() {
        this.username = this.username.toLowerCase();
        if (this.id != 0) {
            String q = "UPDATE tsel_webstarter_user SET fullname=?, email=?, id_role=?, account_expiry=? WHERE id=?";
            Object[] params = new Object[]{this.fullName, this.email, this.role, this.accountExpiry, this.id};
            try {
                MysqlFacade.update((String)q, (Object[])params);
            }
            catch (Exception e) {
                Logger.getLogger((Class)User.class).error((Object)"Cannot update user", (Throwable)e);
                return false;
            }
        }
        String q = "INSERT INTO tsel_webstarter_user (username, password, fullname, email, id_role, password_expiry,login_attempt,account_expiry) VALUES (?,md5('Tsel#1234'), ?,?,?,'0000-00-00','0',?)";
        Object[] params = new Object[]{this.username, this.fullName, this.email, this.role, this.accountExpiry};
        try {
            MysqlFacade.update((String)q, (Object[])params);
        }
        catch (SQLException e) {
            Logger.getLogger((Class)User.class).error((Object)"Cannot insert user", (Throwable)e);
            return false;
        }
        return true;
    }

    public void updateLoginAttempt() {
        String q = "UPDATE tsel_webstarter_user SET login_attempt=0 WHERE id=?";
        Object[] params = new Object[]{this.id};
        try {
            MysqlFacade.update((String)q, (Object[])params);
        }
        catch (SQLException e) {
            Logger.getLogger((Class)User.class).error((Object)"Cannot update login attempt", (Throwable)e);
        }
    }

    public int getLoginAttempt() {
        return this.loginAttempt;
    }

    public void setLoginAttempt(int loginAttempt) {
        this.loginAttempt = loginAttempt;
    }

    public String getAccountExpiry() {
        return this.accountExpiry;
    }

    public void setAccountExpiry(String accountExpiry) {
        this.accountExpiry = accountExpiry;
    }

    public boolean isAccountExpired() {
        return this.isAccountExpired;
    }

    public void setAccountExpired(boolean isAccountExpired) {
        this.isAccountExpired = isAccountExpired;
    }

    public long getNbSession() {
        Object res;
        String q = "SELECT count(*) as jumlah FROM tsel_webstarter_session WHERE username=? AND (UNIX_TIMESTAMP(sysdate) - UNIX_TIMESTAMP(alive_time) < 600)";
        try {
            res = MysqlFacade.getScalar((String)q, (Object[])new Object[]{this.username}, (String)"jumlah");
        }
        catch (SQLException e) {
            Logger.getLogger((Class)User.class).error((Object)("Query failed : " + q));
            return 0;
        }
        Long nbSession = (Long)res;
        return nbSession == null ? 0 : nbSession;
    }

    public void updateSession(String ip) {
        String q = "SELECT username FROM tsel_webstarter_session WHERE username=? AND ip=?";
        try {
            Object res = MysqlFacade.getScalar((String)q, (Object[])new Object[]{this.username, ip}, (String)"username");
            if (res == null) {
                q = "INSERT INTO tsel_webstarter_session (username, ip, alive_time) VALUES (?,?,sysdate)";
                MysqlFacade.update((String)q, (Object[])new Object[]{this.username, ip});
            } else {
                q = "UPDATE tsel_webstarter_session SET alive_time=sysdate WHERE username=? AND ip=?";
                MysqlFacade.update((String)q, (Object[])new Object[]{this.username, ip});
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            Logger.getLogger((Class)User.class).error((Object)("Query failed : " + q));
        }
    }

    public void killSession(String ip) {
        String q = "DELETE FROM tsel_webstarter_session WHERE username=? AND ip=?";
        try {
            MysqlFacade.update((String)q, (Object[])new Object[]{this.username, ip});
        }
        catch (SQLException e) {
            Logger.getLogger((Class)User.class).error((Object)("Query failed : " + q));
        }
    }
}