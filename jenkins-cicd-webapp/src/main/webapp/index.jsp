<%@page import="com.cvz.azure.DbAccess"%>
<%@page import="com.cvz.azure.Product"%>
<%@page import="java.util.ArrayList"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Hello World</title>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<body>
<%
	DbAccess da = new DbAccess();
	ArrayList<Product> products = da.getProducts();
%>
	 <table class="table table-hover">
	 	<thead>
	        <tr>
    	        <th>Id</th>
        	    <th>Title</th>
	            <th>Category</th>
            	<th>Description</th>
    	    </tr>
	 	</thead>
	 	<tbody>
        <%
			for (int i = 0; i< products.size(); i++) {
        		Product p = products.get(i);
        %>
	        <tr>
    		    <td><%= p.Id %></td>
		        <td><%= p.Title %></td>
		        <td><%= p.Category %></td>
		        <td><%= p.Description %></td>
		    </tr>
        <%
        	}
		%>
	 	</tbody>
	</table>
</body>
</html>