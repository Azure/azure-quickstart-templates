package com.cvz.azure;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class DbAccess {
	
	public ArrayList<Product> getProducts() throws Exception {
        Connection conn = getConnection();

		initDbIfNeed(conn);
		
        // Perform some SQL queries over the connection.
        try
        {
        	Statement stmt = conn.createStatement(); 

            String sql = "SELECT * FROM products";
            ResultSet rs = stmt.executeQuery(sql);

    		ArrayList<Product> products= new ArrayList<Product>();
            while (rs.next()) {
            	Product p = new Product();
                p.Id = rs.getInt(1);
                p.Title = rs.getString(2);
                p.Category = rs.getString(3);
                p.Description = rs.getString(4);
                    
                products.add(p);
            }

            rs.close();
            stmt.close();
            conn.close();
            
            return products;
        }
        catch (SQLException e)
        {
            throw new SQLException("Encountered an error when executing given sql statement.", e);
        }
	}

	public void initDbIfNeed(Connection conn) throws Exception {
		// check table existence
		ResultSet rs = conn.getMetaData().getTables(null, null, "products", null);
		if (rs.next())  {
			// skip as table already exists
			return;
		}
		
		try
		{
			Statement stmt = conn.createStatement();
			
			// create table
	        String sqlSchema = "CREATE TABLE products (" + 
	        		"  Id int(11) NOT NULL," + 
	        		"  Title varchar(45) NOT NULL," + 
	        		"  Category varchar(45) DEFAULT NULL," +
	        		"  Description varchar(500) DEFAULT NULL," + 
	        		"  PRIMARY KEY (Id)" + 
	        		");";
	        stmt.executeUpdate(sqlSchema);
	        
	        // initialize data
	        String sqlData = "INSERT INTO products VALUES(1, 'Lorem ipsum dolor sit amet', 'Nullam', 'Donec id nulla molestie tortor gravida venenatis eu non leo. Suspendisse eget ante non arcu elementum dictum.');";
	        stmt.executeUpdate(sqlData);

	        sqlData = "INSERT INTO products VALUES(2, 'Donec id nulla molestie tortor', 'Pellentesque', 'Suspendisse eget ante non arcu elementum dictum. Praesent sit amet est non tortor consequat imperdiet sed in risus.');";
	        stmt.executeUpdate(sqlData);

	        sqlData = "INSERT INTO products VALUES(3, 'Fusce aliquam orci id vehicula malesuada', 'Phasellus', 'Mauris id nisl diam. Pellentesque ut leo massa. Vivamus et enim eu enim facilisis tempor. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae');";
	        stmt.executeUpdate(sqlData);

	        stmt.close();
		}
		catch (SQLException e)
		{
			throw new SQLException("Encountered an error when initialize the database.", e);
		}
	}
	
	private Connection getConnection() throws Exception {
		Map<String, String> connData = getConnectionData();
		
		// Initialize connection variables
        String host = connData.get("Data Source");
        String database = connData.get("Database");
        String user = connData.get("User Id");
        String password = connData.get("Password");
        
        // check that the driver is installed
        try
        {
            Class.forName("com.mysql.cj.jdbc.Driver");
        }
        catch (ClassNotFoundException e)
        {
            throw new ClassNotFoundException("MySQL JDBC driver NOT detected in library path.", e);
        }

        // Initialize connection object
        try
        {
            String url = String.format("jdbc:mysql://%s/%s", host, database);
           
            // Set connection properties.
            Properties properties = new Properties();
            properties.setProperty("user", user);
            properties.setProperty("password", password);
            properties.setProperty("useSSL", "true");
            properties.setProperty("verifyServerCertificate", "true");
            properties.setProperty("requireSSL", "false");
            properties.setProperty("serverTimezone", "UTC");

            // get connection
            return DriverManager.getConnection(url, properties);
        }
        catch (SQLException e)
        {
            throw new SQLException("Failed to create connection to database.", e);
        }
	}
	
	// Get the connection string settings from Azure Web App, following this format.
	// Database=[host];Data Source=[server];User Id=[username];Password=[password]
	private Map<String, String> getConnectionData() throws Exception {
		String connStr = System.getenv("MYSQLCONNSTR_defaultConnection");
		if (connStr == null) {
			throw new Exception("Couldn't find the connection string.");
		}
		
		String[] segments = connStr.split(";");
		Map<String, String> dict = new HashMap<String, String>();
		for (int i = 0; i < segments.length; i++) {
			String[] pair = segments[i].split("=");
			
			dict.put(pair[0], pair[1]);
		}
		
		return dict;
	}
}
