package com.telkomsel.itvas.webstarter;

import java.util.ArrayList;

/*
 * This class specifies class file version 49.0 but uses Java 6 signatures.  Assumed Java 6.
 */
public class Menu {
    private String title;
    private String link;
    private String eligibleRole;
    private boolean isVisible;
    private ArrayList<Menu> childs = new ArrayList();
    private int id;

    public int getId() {
        return this.id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public boolean isVisible() {
        return this.isVisible;
    }

    public void setVisible(boolean isVisible) {
        this.isVisible = isVisible;
    }

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getEligibleRole() {
        return this.eligibleRole;
    }

    public void setEligibleRole(String eligibleRole) {
        this.eligibleRole = eligibleRole;
    }

    public boolean isEligible(int roleID) {
        if (this.eligibleRole.indexOf(String.valueOf(String.valueOf(roleID)) + "|") != -1) {
            return true;
        }
        return false;
    }

    public String getLink() {
        return this.link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    public void addChild(Menu m) {
        this.childs.add(m);
    }

    public int getChildCount() {
        return this.childs.size();
    }

    public ArrayList<Menu> getChilds() {
        return this.childs;
    }

    public void setChilds(ArrayList<Menu> childs) {
        this.childs = childs;
    }
}