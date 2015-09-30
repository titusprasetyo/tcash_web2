package com.telkomsel.itvas.webstarter;

import com.telkomsel.itvas.webstarter.Menu;
import com.telkomsel.itvas.webstarter.User;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Hashtable;
import java.util.TreeMap;
import org.apache.log4j.Logger;

/*
 * This class specifies class file version 49.0 but uses Java 6 signatures.  Assumed Java 6.
 */
public class MenuManager {
    private static ArrayList<Menu> menus;
    private static Hashtable<String, String> roleHash;
    private static Logger log;

    static {
        roleHash = new Hashtable();
        log = Logger.getLogger((Class)MenuManager.class);
        BufferedReader reader = new BufferedReader(new InputStreamReader(MenuManager.class.getResourceAsStream("/ACL.properties")));
        String line = null;
        TreeMap<String, Menu> hashMenu = new TreeMap<String, Menu>();
        try {
            while ((line = reader.readLine()) != null) {
                Menu menu;
                String[] p = line.split(";");
                if (p.length != 5) continue;
                if (p[0].equals("root")) {
                    menu = new Menu();
                    menu.setId(Integer.parseInt(p[1]));
                    menu.setLink(p[2]);
                    menu.setTitle(p[3]);
                    menu.setEligibleRole(p[4]);
                    hashMenu.put(p[1], menu);
                    continue;
                }
                if (p[0].equals("none")) {
                    roleHash.put(p[2], p[4]);
                    continue;
                }
                menu = (Menu)hashMenu.get(p[0]);
                if (menu == null) continue;
                Menu child = new Menu();
                child.setId(Integer.parseInt(p[1]));
                child.setLink(p[2]);
                child.setTitle(p[3]);
                child.setEligibleRole(p[4]);
                roleHash.put(p[2], p[4]);
                menu.addChild(child);
                hashMenu.put(p[0], menu);
            }
            reader.close();
            menus = new ArrayList();
            Collection<Menu> enumeration = hashMenu.values();
            for (Menu m : enumeration) {
                menus.add(m);
            }
        }
        catch (IOException e) {
            log.fatal((Object)"Cannot read ACL properties", (Throwable)e);
        }
    }

    public static ArrayList<Menu> getEligibleMenus(int roleId, boolean isPasswordExpired) {
        ArrayList<Menu> eligibleMenus = new ArrayList<Menu>();
        for (Menu m : menus) {
            if (!m.isEligible(roleId) || isPasswordExpired) continue;
            eligibleMenus.add(m);
        }
        Menu menu = new Menu();
        menu.setId(3);
        menu.setLink("/Logout.action");
        menu.setEligibleRole("1|2|3|4|");
        menu.setTitle("Logout");
        eligibleMenus.add(menu);
        return eligibleMenus;
    }

    public static Hashtable<String, String> getRoleHash() {
        return roleHash;
    }

    public static void setRoleHash(Hashtable<String, String> roleHash) {
        MenuManager.roleHash = roleHash;
    }

    public static boolean isEligible(String url, User user) {
        String strRole = roleHash.get(url);
        if (strRole == null) {
            return true;
        }
        if (strRole.indexOf(String.valueOf(String.valueOf(user.getRole())) + "|") != -1) {
            return true;
        }
        return false;
    }
}