package tsel_tunai;

import com.telkomsel.itvas.database.MysqlFacade;
import java.io.PrintStream;
import java.math.BigInteger;
import java.security.Key;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.spec.AlgorithmParameterSpec;
import java.security.spec.KeySpec;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Random;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.PBEParameterSpec;
import org.apache.commons.httpclient.DefaultMethodRetryHandler;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.MethodRetryHandler;
import org.apache.commons.httpclient.StatusLine;
import org.apache.commons.httpclient.methods.GetMethod;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

public class Util {
    static byte[] salt = new byte[]{-87, -101, -56, 50, 86, 53, -29, 3};
    static int iterationCount = 3;
    static String passPhrase = "daniel_keren";
    static Random rand = new Random();

    public static String encMy(String str) throws Exception {
        Object ret = null;
        PBEKeySpec keySpec = new PBEKeySpec(passPhrase.toCharArray(), salt, iterationCount);
        SecretKey key = SecretKeyFactory.getInstance("PBEWithMD5AndDES").generateSecret(keySpec);
        Cipher ecipher = Cipher.getInstance(key.getAlgorithm());
        PBEParameterSpec paramSpec = new PBEParameterSpec(salt, iterationCount);
        ecipher.init(1, (Key)key, paramSpec);
        byte[] utf8 = str.getBytes("UTF8");
        byte[] enc = ecipher.doFinal(utf8);
        return new BASE64Encoder().encode(enc);
    }

    public static String decMy(String str) throws Exception {
        PBEKeySpec keySpec = new PBEKeySpec(passPhrase.toCharArray(), salt, iterationCount);
        SecretKey key = SecretKeyFactory.getInstance("PBEWithMD5AndDES").generateSecret(keySpec);
        Cipher dcipher = Cipher.getInstance(key.getAlgorithm());
        PBEParameterSpec paramSpec = new PBEParameterSpec(salt, iterationCount);
        dcipher.init(2, (Key)key, paramSpec);
        byte[] dec = new BASE64Decoder().decodeBuffer(str);
        byte[] utf8 = dcipher.doFinal(dec);
        return new String(utf8, "UTF8");
    }

    public static String[] getHttp(String surl, int ti) {
        String[] ret;
        block6 : {
            ret = new String[3];
            ret[0] = "NOK";
            ret[1] = "-1";
            HttpClient client = new HttpClient();
            client.setConnectionTimeout(ti);
            client.setTimeout(ti);
            GetMethod method = new GetMethod(surl);
            method.setHttp11(false);
            DefaultMethodRetryHandler retryhandler = new DefaultMethodRetryHandler();
            retryhandler.setRequestSentRetryEnabled(false);
            method.setMethodRetryHandler((MethodRetryHandler)retryhandler);
            try {
                try {
                    int statusCode = client.executeMethod((HttpMethod)method);
                    ret[2] = String.valueOf(statusCode);
                    if (statusCode == 200 || statusCode == 202) {
                        ret[0] = "OK";
                        ret[1] = method.getResponseBodyAsString();
                        break block6;
                    }
                    ret[0] = "NOK";
                    ret[1] = String.valueOf(method.getStatusLine().toString()) + " " + method.getResponseBodyAsString();
                }
                catch (Exception e) {
                    ret[1] = e.getMessage();
                    System.out.println("cek_ars fail " + surl + " " + e.getMessage());
                    method.releaseConnection();
                }
            }
            finally {
                method.releaseConnection();
            }
        }
        return ret;
    }

    public static int getMsisdnType(String msisdn) {
        String[] tmp;
        int ret = -1;
        if (msisdn.startsWith("62852")) {
            ret = 1;
            return ret;
        }
        String[] r = Util.getHttp("http://10.2.224.101:5001/?msisdn=" + msisdn, 5000);
        if (r[0].equals("OK") && (tmp = r[1].split("subscriberType=")).length >= 2 && tmp[1].length() == 2) {
            String ctipe = tmp[1].substring(0, 1);
            try {
                ret = Integer.parseInt(ctipe);
            }
            catch (Exception e) {
                e.printStackTrace(System.out);
            }
        }
        return ret;
    }

    public static int getCustServiceType(String msisdn) {
        int ret;
        ret = 0;
        Connection co = null;
        try {
            try {
                co = MysqlFacade.getConnection();
                String sql = "select service_type from customer where msisdn = ?";
                PreparedStatement ps = co.prepareStatement(sql);
                ps.setString(1, msisdn);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    ret = Integer.parseInt(rs.getString(1));
                }
                rs.close();
                ps.close();
            }
            catch (Exception e) {
                e.printStackTrace(System.out);
                try {
                    co.close();
                }
                catch (Exception var7_7) {}
            }
        }
        finally {
            try {
                co.close();
            }
            catch (Exception var7_9) {}
        }
        return ret;
    }

    public static boolean allowMsisdn(String msisdn) {
        boolean bo = false;
        String url = "http://10.2.224.101:7001/postpaid/msisdn_allow.jsp?msisdn=" + msisdn;
        String[] r = Util.getHttp(url, 5000);
        if (r[0].equals("OK")) {
            if (r[1] != null) {
                r[1] = r[1].replaceAll("\n", "");
            }
            if (r[1].equals("1")) {
                bo = true;
            }
        }
        System.out.println("ret:" + r[1] + "==end==");
        return bo;
    }

    public static void sendNotif(String msisdn, String msg, String source) {
        Connection co = null;
        try {
            try {
                co = MysqlFacade.getConnection();
                String sql = "insert into notif(msisdn, msg, source, s_time) values(?, ?, ?, sysdate)";
                PreparedStatement ps = co.prepareStatement(sql);
                ps.setString(1, msisdn);
                ps.setString(2, msg);
                ps.setString(3, source);
                ps.executeUpdate();
                ps.close();
            }
            catch (Exception e) {
                System.out.println("send_notif fail msisdn:" + msisdn + " msg:" + msg + " err:" + e.getMessage());
                try {
                    co.close();
                }
                catch (Exception var7_7) {}
            }
        }
        finally {
            try {
                co.close();
            }
            catch (Exception var7_9) {}
        }
    }

    public static String[] getPostpaidData(String msisdn) {
        String[] ret = new String[10];
        ret[0] = "-1";
        String url = "http://10.2.224.101:7001/postpaid/data.jsp?msisdn=" + msisdn;
        String[] r = Util.getHttp(url, 5000);
        if (r[0].equals("OK")) {
            if (r[1] != null) {
                r[1] = r[1].replaceAll("\n", " ");
            }
            String[] tmp = r[1].split("\\|");
            System.out.println(tmp.length);
            if (tmp.length >= 8) {
                ret[0] = "1";
                ret[1] = tmp[0];
                ret[2] = tmp[1];
                ret[3] = tmp[2];
                ret[4] = tmp[3];
                ret[5] = tmp[6];
                ret[6] = tmp[5];
                ret[7] = tmp[7];
                ret[8] = "";
                ret[9] = tmp[4];
            }
        }
        return ret;
    }

    public static String[] getPrepaidData(String msisdn) {
        String[] ret = new String[10];
        ret[0] = "-1";
        String url = "http://10.2.248.52:7777/pls/prereg/prepaid.getprofile?p_msisdn=" + msisdn;
        String[] r = Util.getHttp(url, 5000);
        if (r[0].equals("OK")) {
            if (r[1] != null) {
                r[1] = r[1].replaceAll("\n", " ");
            }
            String[] tmp = r[1].split("\\|");
            System.out.println(tmp.length);
            if (tmp.length >= 18 && tmp[11] != null && tmp[11].length() > 0 && tmp[15] != null && tmp[15].length() > 1) {
                ret[0] = "1";
                ret[1] = tmp[3];
                ret[2] = tmp[7];
                ret[3] = tmp[8];
                ret[4] = tmp[9];
                ret[5] = "";
                ret[6] = tmp[15];
                ret[7] = tmp[4];
                ret[8] = tmp[5];
                ret[9] = tmp[11];
            }
        }
        return ret;
    }

    public static String getMd5Digest(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(input.getBytes());
            BigInteger number = new BigInteger(1, messageDigest);
            return number.toString(16).toUpperCase();
        }
        catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    public static String generateRandomInt() {
        String ret = null;
        int i = rand.nextInt();
        int n = 999998;
        i = rand.nextInt(n + 1);
        ret = String.valueOf(i);
        int le = 6 - ret.length();
        for (int x = 0; x < le; ++x) {
            ret = String.valueOf(ret) + "0";
        }
        return ret;
    }

    public static void main(String[] args) {
        int i;
        String[] ret = Util.getPrepaidData("6285216097221");
        for (i = 0; i < ret.length; ++i) {
            System.out.println(String.valueOf(i) + " :" + ret[i]);
        }
        System.out.println(Util.allowMsisdn("62814444"));
        for (i = 0; i < 100000; ++i) {
            System.out.println(String.valueOf(i) + " " + Util.generateRandomInt());
        }
    }
}