package tsel_tunai;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import tsel_tunai.DbCon;

public class DailySettlement {
    private String id = "";
    private String thresholdIn = "";
    private String thresholdOut = "";
    private String fineIn = "";
    private String fineOut = "";
    private String cycle = "";
    private String receiver = "";
    private String year = "";
    private String holidate = "";
    private String note = "";
    private Connection conn;
    private String query;
    private PreparedStatement pstmt;
    private ResultSet rs;

    public void createDbConn() {
        try {
            if (this.conn == null || this.conn.isClosed()) {
                this.conn = DbCon.getConnection();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void closeDbConn() {
        try {
            if (this.conn != null) {
                this.conn.close();
                this.conn = null;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String validateInput() {
        String s = "";
        if (this.id == null || this.id.equals("") || this.id.equals(" ")) {
            s = String.valueOf(s) + "; Merchant cannot null";
        }
        if (!(this.thresholdIn != null && this.thresholdOut != null && Pattern.compile("\\d+").matcher((CharSequence)this.thresholdIn).matches() && Pattern.compile("\\d+").matcher((CharSequence)this.thresholdOut).matches())) {
            s = String.valueOf(s) + "; Threshold amount must be decimal";
        }
        if (this.cycle == null || this.cycle.equals("")) {
            s = String.valueOf(s) + "; Settlement cycle cannot null";
        }
        if (!s.equals("")) {
            s = s.substring(2);
        }
        return s;
    }

    public String[] getConf() {
        String[] _s;
        _s = new String[]{"", "", "", "", "", ""};
        try {
            try {
                this.createDbConn();
                this.query = "SELECT threshold_in, threshold_out, fine_in, fine_out, cycle, alert_receiver FROM settlement_conf WHERE merchant_id = ?";
                this.pstmt = this.conn.prepareStatement(this.query);
                this.pstmt.clearParameters();
                this.pstmt.setString(1, this.id);
                this.rs = this.pstmt.executeQuery();
                if (this.rs.next()) {
                    _s[0] = this.rs.getString(1);
                    _s[1] = this.rs.getString(2);
                    _s[2] = this.rs.getString(3);
                    _s[3] = this.rs.getString(4);
                    _s[4] = this.rs.getString(5);
                    _s[5] = this.rs.getString(6);
                }
                this.pstmt.close();
                this.rs.close();
            }
            catch (Exception e) {
                e.printStackTrace();
                _s[5] = "";
                _s[4] = "";
                _s[3] = "";
                _s[2] = "";
                _s[1] = "";
                _s[0] = "";
                this.closeDbConn();
            }
        }
        finally {
            this.closeDbConn();
        }
        return _s;
    }

    public void insertConf() {
        try {
            try {
                this.createDbConn();
                this.query = "INSERT INTO settlement_conf VALUES(?, ?, ?, ?, ?, ?, ?)";
                this.pstmt = this.conn.prepareStatement(this.query);
                this.pstmt.clearParameters();
                this.pstmt.setString(1, this.id);
                this.pstmt.setString(2, this.thresholdIn);
                this.pstmt.setString(3, this.thresholdOut);
                this.pstmt.setString(4, this.fineIn);
                this.pstmt.setString(5, this.fineOut);
                this.pstmt.setString(6, this.cycle);
                this.pstmt.setString(7, this.receiver);
                this.pstmt.executeUpdate();
                this.pstmt.close();
            }
            catch (Exception e) {
                e.printStackTrace();
                this.closeDbConn();
            }
        }
        finally {
            this.closeDbConn();
        }
    }

    public void insertHoliday() {
        try {
            try {
                this.createDbConn();
                this.query = "INSERT INTO holiday VALUES(?, TO_DATE(?, 'DD-MM-YYYY'), ?)";
                this.pstmt = this.conn.prepareStatement(this.query);
                this.pstmt.clearParameters();
                this.pstmt.setString(1, this.year);
                this.pstmt.setString(2, this.holidate);
                this.pstmt.setString(3, this.note);
                this.pstmt.executeUpdate();
                this.pstmt.close();
            }
            catch (Exception e) {
                e.printStackTrace();
                this.closeDbConn();
            }
        }
        finally {
            this.closeDbConn();
        }
    }

    public void updateType(String type) {
        try {
            try {
                this.createDbConn();
                this.query = "UPDATE tsel_merchant_account SET type = ? WHERE acc_no = (SELECT acc_no FROM merchant WHERE merchant_id = ?)";
                this.pstmt = this.conn.prepareStatement(this.query);
                this.pstmt.clearParameters();
                this.pstmt.setString(1, type);
                this.pstmt.setString(2, this.id);
                this.pstmt.executeUpdate();
                this.pstmt.close();
            }
            catch (Exception e) {
                e.printStackTrace();
                this.closeDbConn();
            }
        }
        finally {
            this.closeDbConn();
        }
    }

    public void resetConf() {
        try {
            try {
                this.createDbConn();
                this.query = "DELETE FROM settlement_conf WHERE merchant_id = ?";
                this.pstmt = this.conn.prepareStatement(this.query);
                this.pstmt.clearParameters();
                this.pstmt.setString(1, this.id);
                this.pstmt.executeUpdate();
                this.pstmt.close();
            }
            catch (Exception e) {
                e.printStackTrace();
                this.closeDbConn();
            }
        }
        finally {
            this.closeDbConn();
        }
    }

    public void resetHoliday() {
        try {
            try {
                this.createDbConn();
                this.query = "DELETE FROM holiday WHERE holidate = TO_DATE(?, 'DD-MM-YYYY')";
                this.pstmt = this.conn.prepareStatement(this.query);
                this.pstmt.clearParameters();
                this.pstmt.setString(1, this.holidate);
                this.pstmt.executeUpdate();
                this.pstmt.close();
            }
            catch (Exception e) {
                e.printStackTrace();
                this.closeDbConn();
            }
        }
        finally {
            this.closeDbConn();
        }
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setThresholdIn(String thresholdIn) {
        this.thresholdIn = thresholdIn;
    }

    public void setThresholdOut(String thresholdOut) {
        this.thresholdOut = thresholdOut;
    }

    public void setFineIn(String fineIn) {
        if (fineIn != null) {
            this.fineIn = fineIn;
        }
    }

    public void setFineOut(String fineOut) {
        if (fineOut != null) {
            this.fineOut = fineOut;
        }
    }

    public void setCycle(String[] _cycle) {
        if (_cycle != null) {
            for (int i = 0; i < _cycle.length; ++i) {
                this.cycle = String.valueOf(this.cycle) + ";" + _cycle[i];
            }
            this.cycle = this.cycle.substring(1);
        }
    }

    public void setReceiver(String[] _receiver) {
        if (_receiver != null) {
            for (int i = 0; i < _receiver.length; ++i) {
                this.receiver = String.valueOf(this.receiver) + ";" + _receiver[i];
            }
            this.receiver = this.receiver.substring(1);
        }
    }

    public void setYear(String year) {
        this.year = year;
    }

    public void setHolidate(String holidate) {
        this.holidate = holidate;
    }

    public void setNote(String note) {
        if (note != null) {
            this.note = note;
        }
    }
}