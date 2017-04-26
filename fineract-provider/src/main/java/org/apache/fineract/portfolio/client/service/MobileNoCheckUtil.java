/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.apache.fineract.portfolio.client.service;

import java.sql.*;

import org.apache.fineract.infrastructure.core.service.RoutingDataSource;

public class MobileNoCheckUtil {

		//Concatenate both user display name and id into single string and return it
	/**
	 * Usually its right to always throw the exception, but specifically in this 
	 * case, this is a case we are already dealing with an exception, hence it is
	 * sensible to prevent the exception being thrown from here
	 * @param externalId
	 * @param jdbcTemplate
	 * @return
	 */
	public static String fetchmobileNoOwner(String mobileNo, RoutingDataSource dataSource)   {
		
		String displayName="";
		int clientId=0;
		
		String sql;
		   sql = "SELECT display_name, id FROM m_client where mobile_no='" + mobileNo + "'";
		  Statement stmt = null;
		  
		  Connection con=null;
		  try{
		 
		  con= dataSource.getConnection();
		  stmt = con.createStatement(
                  ResultSet.TYPE_SCROLL_INSENSITIVE,
                  ResultSet.CONCUR_READ_ONLY);
		  
		   ResultSet rs = stmt.executeQuery(sql);

		   while (rs.next()) {
		   
		   clientId  = rs.getInt("id");
		   displayName = rs.getString("display_name");
		   }
		   
		return displayName+"("+clientId+")";
		
		  }
				  
		  catch (SQLException e) {
			return "Error talking to database, Contact system admin"+e.getMessage();
		}
		
		finally
		{
			   //finally block used to close resources
			   try{
			      if(stmt!=null)
			         stmt.close();
			   }catch(SQLException se2){
			   }// nothing we can do
			   try{
			      if(con!=null)
			         con.close();
			   }catch(SQLException se){
			      se.printStackTrace();
			   }//end finally try
			
		}

	
	}
}

	
