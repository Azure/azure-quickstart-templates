// Stubs for the namespace Microsoft.SqlServer.Management.Smo. Used for mocking in tests.

using System;
using System.Collections.Generic;

namespace Microsoft.SqlServer.Management.Smo
{
    #region Public Enums

    // TypeName: Microsoft.SqlServer.Management.Smo.LoginType
    // BaseType: Microsoft.SqlServer.Management.Smo.ScriptNameObjectBase
    // Used by: 
    //  MSFT_xSQLServerLogin
    public enum LoginType
    {
        AsymmetricKey = 4,
        Certificate = 3,
        ExternalGroup = 6,
        ExternalUser = 5,
        SqlLogin = 2,
        WindowsGroup = 1,
        WindowsUser = 0,
        Unknown = -1    // Added for verification (mock) purposes, to verify that a login type is passed  
    }

    // TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode
    // Used by: 
    //  MSFT_xSQLAOGroupEnsure.Tests
    public enum AvailabilityReplicaFailoverMode
    {
        Automatic,
        Manual,
        Unknown
    }

    // TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode
    // Used by: 
    //  MSFT_xSQLAOGroupEnsure.Tests
    public enum AvailabilityReplicaAvailabilityMode
    {
        AsynchronousCommit,
        SynchronousCommit,
        Unknown
    }

    #endregion Public Enums

    #region Public Classes

    public class Globals
    {
        // Static property that is switched on or off by tests if data should be mocked (true) or not (false).
        public static bool GenerateMockData = false;
    }

    // Typename: Microsoft.SqlServer.Management.Smo.ObjectPermissionSet
    // BaseType: Microsoft.SqlServer.Management.Smo.PermissionSetBase
    // Used by: 
    //  xSQLServerEndpointPermission.Tests.ps1
    public class ObjectPermissionSet 
    {
        public ObjectPermissionSet(){}

        public ObjectPermissionSet(
            bool connect )
        {
            this.Connect = connect; 
        } 
    
        public bool Connect = false;
    }
    
    // TypeName: Microsoft.SqlServer.Management.Smo.ServerPermissionSet
    // BaseType: Microsoft.SqlServer.Management.Smo.PermissionSetBase
    // Used by: 
    //  xSQLServerPermission.Tests.ps1
    public class ServerPermissionSet 
    {
        public ServerPermissionSet(){}

        public ServerPermissionSet(
            bool alterAnyAvailabilityGroup, 
            bool alterAnyEndPoint,
            bool connectSql,  
            bool viewServerState )
        {
            this.AlterAnyAvailabilityGroup = alterAnyAvailabilityGroup; 
            this.AlterAnyEndPoint = alterAnyEndPoint;
            this.ConnectSql = connectSql;
            this.ViewServerState = viewServerState;
        } 
    
        public bool AlterAnyAvailabilityGroup = false;
        public bool AlterAnyEndPoint = false;
        public bool ConnectSql = false;
        public bool ViewServerState = false;
    }

    // TypeName: Microsoft.SqlServer.Management.Smo.ServerPermissionInfo
    // BaseType: Microsoft.SqlServer.Management.Smo.PermissionInfo
    // Used by: 
    //  xSQLServerPermission.Tests.ps1
    public class ServerPermissionInfo 
    {
        public ServerPermissionInfo()
        {
            Microsoft.SqlServer.Management.Smo.ServerPermissionSet[] permissionSet = { new Microsoft.SqlServer.Management.Smo.ServerPermissionSet() };
            this.PermissionType = permissionSet;
        }

        public ServerPermissionInfo( 
            Microsoft.SqlServer.Management.Smo.ServerPermissionSet[] permissionSet )
        {
            this.PermissionType = permissionSet;
        }
        
        public Microsoft.SqlServer.Management.Smo.ServerPermissionSet[] PermissionType;
        public string PermissionState = "Grant";
    }

    // TypeName: Microsoft.SqlServer.Management.Smo.Server
    // BaseType: Microsoft.SqlServer.Management.Smo.SqlSmoObject
    // Used by: 
    //  xSQLServerPermission
    //  MSFT_xSQLServerLogin
    public class Server 
    { 
        public string MockGranteeName;

        public string Name;
        public string DisplayName;
        public string InstanceName;
        public bool IsHadrEnabled = false;

        public Server(){} 

        public Microsoft.SqlServer.Management.Smo.ServerPermissionInfo[] EnumServerPermissions( string principal, Microsoft.SqlServer.Management.Smo.ServerPermissionSet permissionSetQuery ) 
        { 
            List<Microsoft.SqlServer.Management.Smo.ServerPermissionInfo> listOfServerPermissionInfo = new List<Microsoft.SqlServer.Management.Smo.ServerPermissionInfo>();
            
            if( Globals.GenerateMockData ) {
                Microsoft.SqlServer.Management.Smo.ServerPermissionSet[] permissionSet = { 
                    new Microsoft.SqlServer.Management.Smo.ServerPermissionSet( true, false, false, false ),
                    new Microsoft.SqlServer.Management.Smo.ServerPermissionSet( false, true, false, false ),
                    new Microsoft.SqlServer.Management.Smo.ServerPermissionSet( false, false, true, false ),
                    new Microsoft.SqlServer.Management.Smo.ServerPermissionSet( false, false, false, true ) };

                listOfServerPermissionInfo.Add( new Microsoft.SqlServer.Management.Smo.ServerPermissionInfo( permissionSet ) );
            } else {
                listOfServerPermissionInfo.Add( new Microsoft.SqlServer.Management.Smo.ServerPermissionInfo() );
            }

            Microsoft.SqlServer.Management.Smo.ServerPermissionInfo[] permissionInfo = listOfServerPermissionInfo.ToArray();

            return permissionInfo;
        }

        public void Grant( Microsoft.SqlServer.Management.Smo.ServerPermissionSet permission, string granteeName )
        {
            if( granteeName != this.MockGranteeName ) 
            {
                string errorMessage = "Expected to get granteeName == '" + this.MockGranteeName + "'. But got '" + granteeName + "'";
                throw new System.ArgumentException(errorMessage, "granteeName");
            }
        }

        public void Revoke( Microsoft.SqlServer.Management.Smo.ServerPermissionSet permission, string granteeName )
        {
            if( granteeName != this.MockGranteeName ) 
            {
                string errorMessage = "Expected to get granteeName == '" + this.MockGranteeName + "'. But got '" + granteeName + "'";
                throw new System.ArgumentException(errorMessage, "granteeName");
            }
        }
    }

    // TypeName: Microsoft.SqlServer.Management.Smo.Login
    // BaseType: Microsoft.SqlServer.Management.Smo.ScriptNameObjectBase
    // Used by: 
    //  MSFT_xSQLServerLogin
    public class Login 
    {
        private bool _mockPasswordPassed = false;

        public Login( Server server, string name ) {
            this.Name = name;
        } 

        public Login( Object server, string name ) {
            this.Name = name;
        } 
            
        public string Name;
        public LoginType LoginType = LoginType.Unknown;

        public void Create()
        {
            if( this.LoginType == LoginType.Unknown ) {
                throw new System.Exception( "Called Create() method without a value for LoginType." );
            }

            if( this.LoginType == LoginType.SqlLogin && _mockPasswordPassed != true ) {
                throw new System.Exception( "Called Create() method for the LoginType 'SqlLogin' but called with the wrong overloaded method. Did not pass the password with the Create() method." );
            }
        }

        public void Create( String secureString )
        {
            _mockPasswordPassed = true;

            this.Create();
        }

        public void Drop()
        {
        }
    }
	
	// TypeName: Microsoft.SqlServer.Management.Smo.ServerRole
    // BaseType: Microsoft.SqlServer.Management.Smo.ScriptNameObjectBase
    // Used by: 
    //  MSFT_xSQLServerRole
    public class ServerRole 
    {
        public ServerRole( Server server, string name ) {
            this.Name = name;
        } 

        public ServerRole( Object server, string name ) {
            this.Name = name;
        } 
            
        public string Name;
    }


	// TypeName: Microsoft.SqlServer.Management.Smo.Database
    // BaseType: Microsoft.SqlServer.Management.Smo.ScriptNameObjectBase
    // Used by: 
    //  MSFT_xSQLServerDatabase
	public class Database
	{
        public Database( Server server, string name ) {
            this.Name = name;
        } 

        public Database( Object server, string name ) {
            this.Name = name;
        } 
            
        public string Name;
		
		public void Create()
        {
        }
		
		public void Drop()
        {
        }
		
	}
    #endregion Public Classes
}
