import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.Writer;
import tsel_tunai.Util;

public class FlashWebUserEeek {
    public static void main(String[] args) {
        BufferedReader r = null;
        PrintWriter pw = null;
        try {
            try {
                r = new BufferedReader(new InputStreamReader(new FileInputStream("d:\\input.csv")));
                pw = new PrintWriter(new FileWriter("d:\\output.csv"));
                String line = null;
                while ((line = r.readLine()) != null) {
                    String[] p = line.split(";");
                    if (p.length < 5) continue;
                    String out = ";" + p[2] + ";" + Util.getMd5Digest((String)p[2]) + ";" + "1" + ";" + "PR" + ";" + "0000-00-00" + ";" + "0" + ";" + p[2] + ";" + p[1] + ";" + ";" + ";" + p[3] + ";" + p[4] + ";" + "0000-00-00";
                    pw.println(out);
                }
            }
            catch (FileNotFoundException e) {
                e.printStackTrace();
                if (r != null) {
                    try {
                        r.close();
                    }
                    catch (IOException e1) {
                        e1.printStackTrace();
                    }
                }
                if (pw != null) {
                    try {
                        pw.close();
                    }
                    catch (Exception e2) {
                        e2.printStackTrace();
                    }
                }
            }
            catch (IOException e) {
                block32 : {
                    e.printStackTrace();
                    if (r == null) break block32;
                    try {
                        r.close();
                    }
                    catch (IOException e1) {
                        e1.printStackTrace();
                    }
                }
                if (pw != null) {
                    try {
                        pw.close();
                    }
                    catch (Exception e2) {
                        e2.printStackTrace();
                    }
                }
            }
        }
        finally {
            if (r != null) {
                try {
                    r.close();
                }
                catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (pw != null) {
                try {
                    pw.close();
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}