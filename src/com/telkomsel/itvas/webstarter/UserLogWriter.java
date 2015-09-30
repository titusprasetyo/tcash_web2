package com.telkomsel.itvas.webstarter;

import com.telkomsel.itvas.database.MysqlFacade;
import java.sql.SQLException;
import org.apache.log4j.Logger;

public class UserLogWriter {
	public static void writeLog(String username, String log) {
		try {
			String q = "INSERT INTO tsel_webstarter_userlog (username, log, ts) VALUES (?,?,sysdate)";
			MysqlFacade.update((String) q, (Object[]) new Object[] { username, log });
		} catch (SQLException e) {
			Logger.getLogger((Class) UserLogWriter.class).error((Object) "Error writing user log", (Throwable) e);
		}
	}
}