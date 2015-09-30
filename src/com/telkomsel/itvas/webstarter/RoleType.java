package com.telkomsel.itvas.webstarter;

import com.telkomsel.itvas.database.MysqlFacade;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.log4j.Logger;

public class RoleType {
	private int id;
	private String label;
	private int userRoleId;
	private static List<RoleType> roles;

	static {
		QueryRunner qr = MysqlFacade.getQueryRunner();
		Connection conn = null;
		try {
			conn = MysqlFacade.getConnection();

			roles = (List) qr.query("SELECT id, role as label FROM tsel_webstarter_role WHERE 1",
					new BeanListHandler(RoleType.class));
		} catch (SQLException e) {
			roles = new ArrayList();
			roles.add(new RoleType(1, "Superuser"));
			roles.add(new RoleType(2, "Administrator"));
			roles.add(new RoleType(3, "Operator"));
			Logger.getLogger(RoleType.class).error("Err in getAllRoleTypes : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}

	public RoleType() {
	}

	public RoleType(int id, String label) {
		this.id = id;
		this.label = label;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public List<RoleType> getAllRoleTypes() {
		QueryRunner qr = MysqlFacade.getQueryRunner();
		Connection conn = null;
		List<RoleType> retval = new ArrayList();
		try {
			conn = MysqlFacade.getConnection();

			retval = (List) qr.query(
					"SELECT IF(allowed_creator_role_id LIKE '%" + userRoleId
							+ "%', 1, 0) as editable, id, role as label FROM tsel_webstarter_role WHERE 1",
					new BeanListHandler(RoleType.class));
		} catch (SQLException e) {
			retval = new ArrayList();
			retval.add(new RoleType(1, "Superuser"));
			retval.add(new RoleType(2, "Administrator"));
			retval.add(new RoleType(3, "Operator"));
			Logger.getLogger(RoleType.class).error("Err in getAllRoleTypes : " + e.getMessage(), e);
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return retval;
	}

	public int getUserRoleId() {
		return userRoleId;
	}

	public void setUserRoleId(int userRoleId) {
		this.userRoleId = userRoleId;
	}

	public static RoleType getRoleType(int id) {
		for (RoleType r : roles) {
			if (id == r.getId()) {
				return r;
			}
		}
		return null;
	}

	public String toString() {
		return label;
	}
}