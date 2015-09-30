package com.telkomsel.itvas.webstarter;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class WebStarterProperties
extends Properties {
    private static final String propertiesPath = "/WebStarter.properties";
    private static WebStarterProperties instance;

    public static WebStarterProperties getInstance() {
        if (instance == null) {
            instance = new WebStarterProperties();
            try {
                InputStream input = WebStarterProperties.class.getResourceAsStream("/WebStarter.properties");
                instance.load(input);
                input.close();
            }
            catch (IOException e) {
                e.printStackTrace();
            }
        }
        return instance;
    }

    public int getIntProperty(String key) {
        int retval = -1;
        try {
            retval = Integer.parseInt(this.getProperty(key));
        }
        catch (NumberFormatException e) {
            e.printStackTrace();
        }
        return retval;
    }
}