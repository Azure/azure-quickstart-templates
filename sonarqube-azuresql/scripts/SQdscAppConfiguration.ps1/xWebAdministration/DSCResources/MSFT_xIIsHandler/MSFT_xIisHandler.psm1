# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        NoWebAdministrationModule = Please ensure that WebAdministration module is installed.
        AddingHandler             = Adding handler '{0}'
        RemovingHandler           = Removing handler '{0}'
        HandlerExists             = Handler with name '{0}' already exist
        HandlerNotPresent         = Handler with name '{0}' is not present as requested
        HandlerNotSupported       = The handler with name '{0}' is not supported.
        VerboseGetTargetPresent   = Handler is present
        VerboseGetTargetAbsent    = Handler is absent
'@
}

#region script variables
$script:handlers = @{
    'aspq-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'aspq-Integrated-4.0';
            Path = '*.aspq';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.HttpForbiddenHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'aspq-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'aspq-ISAPI-4.0_32bit';
            Path = '*.aspq';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'aspq-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'aspq-ISAPI-4.0_64bit';
            Path = '*.aspq';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'AssemblyResourceLoader-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'AssemblyResourceLoader-Integrated-4.0';
            Path = 'WebResource.axd';
            Verb = 'GET,DEBUG';
            Type = 'System.Web.Handlers.AssemblyResourceLoader';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'AssemblyResourceLoader-Integrated' = (New-Object PSObject -Property @{
            Name = 'AssemblyResourceLoader-Integrated';
            Path = 'WebResource.axd';
            Verb = 'GET,DEBUG';
            Type = 'System.Web.Handlers.AssemblyResourceLoader';
            PreCondition = 'integratedMode'
    });

    'AXD-ISAPI-2.0-64' = (New-Object PSObject -Property @{
            Name = 'AXD-ISAPI-2.0-64';
            Path = '*.axd';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'AXD-ISAPI-2.0' = (New-Object PSObject -Property @{
            Name = 'AXD-ISAPI-2.0';
            Path = '*.axd';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'AXD-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'AXD-ISAPI-4.0_32bit';
            Path = '*.axd';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'AXD-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'AXD-ISAPI-4.0_64bit';
            Path = '*.axd';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'CGI-exe' = (New-Object PSObject -Property @{
            Name = 'CGI-exe';
            Path = '*.exe';
            Verb = '*';
            Modules = 'CgiModule';
            ResourceType = 'File';
            RequireAccess = 'Execute';
            AllowPathInfo = 'true'
    });

    'ClientLoggingHandler' = (New-Object PSObject -Property @{
            Name = 'ClientLoggingHandler';
            Path = '*.log';
            Verb = 'POST';
            Modules = 'ClientLoggingHandler';
            ResourceType = 'Unspecified';
            RequireAccess = 'None'
    });

    'cshtm-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'cshtm-Integrated-4.0';
            Path = '*.cshtm';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.HttpForbiddenHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'cshtm-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'cshtm-ISAPI-4.0_32bit';
            Path = '*.cshtm';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'cshtm-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'cshtm-ISAPI-4.0_64bit';
            Path = '*.cshtm';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'cshtml-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'cshtml-Integrated-4.0';
            Path = '*.cshtml';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.HttpForbiddenHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'cshtml-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'cshtml-ISAPI-4.0_32bit';
            Path = '*.cshtml';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'cshtml-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'cshtml-ISAPI-4.0_64bit';
            Path = '*.cshtml';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'ExtensionlessUrlHandler-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'ExtensionlessUrlHandler-Integrated-4.0';
            Path = '*.';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.Handlers.TransferRequestHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0';
            ResponseBufferLimit = '0'
    });

    'ExtensionlessUrlHandler-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'ExtensionlessUrlHandler-ISAPI-4.0_32bit';
            Path = '*.';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'ExtensionlessUrlHandler-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'ExtensionlessUrlHandler-ISAPI-4.0_64bit';
            Path = '*.';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-rem-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-rem-Integrated-4.0';
            Path = '*.rem';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Runtime.Remoting.Channels.Http.HttpRemotingHandlerFactory,;System.Runtime.Remoting,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = b77a5c561934e089';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'HttpRemotingHandlerFactory-rem-Integrated' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-rem-Integrated';
            Path = '*.rem';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Runtime.Remoting.Channels.Http.HttpRemotingHandlerFactory,;System.Runtime.Remoting,;Version = 2.0.0.0,;Culture = neutral,;PublicKeyToken = b77a5c561934e089';
            PreCondition = 'integratedMode,runtimeVersionv2.0'
    });

    'HttpRemotingHandlerFactory-rem-ISAPI-2.0-64' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-rem-ISAPI-2.0-64';
            Path = '*.rem';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-rem-ISAPI-2.0' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-rem-ISAPI-2.0';
            Path = '*.rem';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-rem-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-rem-ISAPI-4.0_32bit';
            Path = '*.rem';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-rem-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-rem-ISAPI-4.0_64bit';
            Path = '*.rem';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-soap-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-soap-Integrated-4.0';
            Path = '*.soap';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Runtime.Remoting.Channels.Http.HttpRemotingHandlerFactory,;System.Runtime.Remoting,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = b77a5c561934e089';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'HttpRemotingHandlerFactory-soap-Integrated' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-soap-Integrated';
            Path = '*.soap';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Runtime.Remoting.Channels.Http.HttpRemotingHandlerFactory,;System.Runtime.Remoting,;Version = 2.0.0.0,;Culture = neutral,;PublicKeyToken = b77a5c561934e089';
            PreCondition = 'integratedMode,runtimeVersionv2.0'
    });

    'HttpRemotingHandlerFactory-soap-ISAPI-2.0-64' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-soap-ISAPI-2.0-64';
            Path = '*.soap';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-soap-ISAPI-2.0' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-soap-ISAPI-2.0';
            Path = '*.soap';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-soap-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-soap-ISAPI-4.0_32bit';
            Path = '*.soap';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'HttpRemotingHandlerFactory-soap-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'HttpRemotingHandlerFactory-soap-ISAPI-4.0_64bit';
            Path = '*.soap';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'ISAPI-dll' = (New-Object PSObject -Property @{
            Name = 'ISAPI-dll';
            Path = '*.dll';
            Verb = '*';
            Modules = 'IsapiModule';
            ResourceType = 'File';
            RequireAccess = 'Execute';
            AllowPathInfo = 'true'
    });

    'OPTIONSVerbHandler' = (New-Object PSObject -Property @{
            Name = 'OPTIONSVerbHandler';
            Path = '*';
            Verb = 'OPTIONS';
            Modules = 'ProtocolSupportModule';
            RequireAccess = 'None'
    });

    'PageHandlerFactory-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'PageHandlerFactory-Integrated-4.0';
            Path = '*.aspx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.UI.PageHandlerFactory';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'PageHandlerFactory-Integrated' = (New-Object PSObject -Property @{
            Name = 'PageHandlerFactory-Integrated';
            Path = '*.aspx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.UI.PageHandlerFactory';
            PreCondition = 'integratedMode'
    });

    'PageHandlerFactory-ISAPI-2.0-64' = (New-Object PSObject -Property @{
            Name = 'PageHandlerFactory-ISAPI-2.0-64';
            Path = '*.aspx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'PageHandlerFactory-ISAPI-2.0' = (New-Object PSObject -Property @{
            Name = 'PageHandlerFactory-ISAPI-2.0';
            Path = '*.aspx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'PageHandlerFactory-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'PageHandlerFactory-ISAPI-4.0_32bit';
            Path = '*.aspx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'PageHandlerFactory-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'PageHandlerFactory-ISAPI-4.0_64bit';
            Path = '*.aspx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'rules-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'rules-Integrated-4.0';
            Path = '*.rules';
            Verb = '*';
            Type = 'System.ServiceModel.Activation.ServiceHttpHandlerFactory,;System.ServiceModel.Activation,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = 31bf3856ad364e35';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'rules-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'rules-ISAPI-4.0_32bit';
            Path = '*.rules';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'rules-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'rules-ISAPI-4.0_64bit';
            Path = '*.rules';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'ScriptHandlerFactoryAppServices-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'ScriptHandlerFactoryAppServices-Integrated-4.0';
            Path = '*_AppService.axd';
            Verb = '*';
            Type = 'System.Web.Script.Services.ScriptHandlerFactory,;System.Web.Extensions,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = 31BF3856AD364E35';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'ScriptResourceIntegrated-4.0' = (New-Object PSObject -Property @{
            Name = 'ScriptResourceIntegrated-4.0';
            Path = '*ScriptResource.axd';
            Verb = 'GET,HEAD';
            Type = 'System.Web.Handlers.ScriptResourceHandler,;System.Web.Extensions,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = 31BF3856AD364E35';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'SecurityCertificate' = (New-Object PSObject -Property @{
            Name = 'SecurityCertificate';
            Path = '*.cer';
            Verb = 'GET,HEAD,POST';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\system32\inetsrv\asp.dll';
            ResourceType = 'File'
    });

    'SimpleHandlerFactory-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'SimpleHandlerFactory-Integrated-4.0';
            Path = '*.ashx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.UI.SimpleHandlerFactory';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'SimpleHandlerFactory-Integrated' = (New-Object PSObject -Property @{
            Name = 'SimpleHandlerFactory-Integrated';
            Path = '*.ashx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.UI.SimpleHandlerFactory';
            PreCondition = 'integratedMode'
    });

    'SimpleHandlerFactory-ISAPI-2.0-64' = (New-Object PSObject -Property @{
            Name = 'SimpleHandlerFactory-ISAPI-2.0-64';
            Path = '*.ashx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'SimpleHandlerFactory-ISAPI-2.0' = (New-Object PSObject -Property @{
            Name = 'SimpleHandlerFactory-ISAPI-2.0';
            Path = '*.ashx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'SimpleHandlerFactory-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'SimpleHandlerFactory-ISAPI-4.0_32bit';
            Path = '*.ashx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'SimpleHandlerFactory-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'SimpleHandlerFactory-ISAPI-4.0_64bit';
            Path = '*.ashx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'SSINC-shtm' = (New-Object PSObject -Property @{
            Name = 'SSINC-shtm';
            Path = '*.shtm';
            Verb = 'GET,HEAD,POST';
            Modules = 'ServerSideIncludeModule';
            ResourceType = 'File'
    });

    'SSINC-shtml' = (New-Object PSObject -Property @{
            Name = 'SSINC-shtml';
            Path = '*.shtml';
            Verb = 'GET,HEAD,POST';
            Modules = 'ServerSideIncludeModule';
            ResourceType = 'File'
    });

    'SSINC-stm' = (New-Object PSObject -Property @{
            Name = 'SSINC-stm';
            Path = '*.stm';
            Verb = 'GET,HEAD,POST';
            Modules = 'ServerSideIncludeModule';
            ResourceType = 'File'
    });

    'StaticFile' = (New-Object PSObject -Property @{
            Name = 'StaticFile';
            Path = '*';
            Verb = '*';
            Modules = 'StaticFileModule,DefaultDocumentModule,DirectoryListingModule';
            ResourceType = 'Either';
            RequireAccess = 'Read'
    });

    'svc-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'svc-Integrated-4.0';
            Path = '*.svc';
            Verb = '*';
            Type = 'System.ServiceModel.Activation.ServiceHttpHandlerFactory,;System.ServiceModel.Activation,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = 31bf3856ad364e35';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'svc-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'svc-ISAPI-4.0_32bit';
            Path = '*.svc';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'svc-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'svc-ISAPI-4.0_64bit';
            Path = '*.svc';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'TraceHandler-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'TraceHandler-Integrated-4.0';
            Path = 'trace.axd';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.Handlers.TraceHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'TraceHandler-Integrated' = (New-Object PSObject -Property @{
            Name = 'TraceHandler-Integrated';
            Path = 'trace.axd';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.Handlers.TraceHandler';
            PreCondition = 'integratedMode'
    });

    'TRACEVerbHandler' = (New-Object PSObject -Property @{
            Name = 'TRACEVerbHandler';
            Path = '*';
            Verb = 'TRACE';
            Modules = 'ProtocolSupportModule';
            RequireAccess = 'None'
    });

    'vbhtm-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'vbhtm-Integrated-4.0';
            Path = '*.vbhtm';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.HttpForbiddenHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'vbhtm-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'vbhtm-ISAPI-4.0_32bit';
            Path = '*.vbhtm';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'vbhtm-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'vbhtm-ISAPI-4.0_64bit';
            Path = '*.vbhtm';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'vbhtml-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'vbhtml-Integrated-4.0';
            Path = '*.vbhtml';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.HttpForbiddenHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'vbhtml-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'vbhtml-ISAPI-4.0_32bit';
            Path = '*.vbhtml';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'vbhtml-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'vbhtml-ISAPI-4.0_64bit';
            Path = '*.vbhtml';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'WebAdminHandler-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'WebAdminHandler-Integrated-4.0';
            Path = 'WebAdmin.axd';
            Verb = 'GET,DEBUG';
            Type = 'System.Web.Handlers.WebAdminHandler';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'WebAdminHandler-Integrated' = (New-Object PSObject -Property @{
            Name = 'WebAdminHandler-Integrated';
            Path = 'WebAdmin.axd';
            Verb = 'GET,DEBUG';
            Type = 'System.Web.Handlers.WebAdminHandler';
            PreCondition = 'integratedMode'
    });

    'WebDAV' = (New-Object PSObject -Property @{
            Name = 'WebDAV';
            Path = '*';
            Verb = 'PROPFIND,PROPPATCH,MKCOL,PUT,COPY,DELETE,MOVE,LOCK,UNLOCK';
            Modules = 'WebDAVModule';
            ResourceType = 'Unspecified';
            RequireAccess = 'None'
    });

    'WebServiceHandlerFactory-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'WebServiceHandlerFactory-Integrated-4.0';
            Path = '*.asmx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.Script.Services.ScriptHandlerFactory,;System.Web.Extensions,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = 31bf3856ad364e35';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'WebServiceHandlerFactory-Integrated' = (New-Object PSObject -Property @{
            Name = 'WebServiceHandlerFactory-Integrated';
            Path = '*.asmx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Web.Services.Protocols.WebServiceHandlerFactory,;System.Web.Services,;Version = 2.0.0.0,;Culture = neutral,;PublicKeyToken = b03f5f7f11d50a3a';
            PreCondition = 'integratedMode,runtimeVersionv2.0'
    });

    'WebServiceHandlerFactory-ISAPI-2.0-64' = (New-Object PSObject -Property @{
            Name = 'WebServiceHandlerFactory-ISAPI-2.0-64';
            Path = '*.asmx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'WebServiceHandlerFactory-ISAPI-2.0' = (New-Object PSObject -Property @{
            Name = 'WebServiceHandlerFactory-ISAPI-2.0';
            Path = '*.asmx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv2.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'WebServiceHandlerFactory-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'WebServiceHandlerFactory-ISAPI-4.0_32bit';
            Path = '*.asmx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'WebServiceHandlerFactory-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'WebServiceHandlerFactory-ISAPI-4.0_64bit';
            Path = '*.asmx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'xamlx-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'xamlx-Integrated-4.0';
            Path = '*.xamlx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Type = 'System.Xaml.Hosting.XamlHttpHandlerFactory,;System.Xaml.Hosting,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = 31bf3856ad364e35';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'xamlx-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'xamlx-ISAPI-4.0_32bit';
            Path = '*.xamlx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'xamlx-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'xamlx-ISAPI-4.0_64bit';
            Path = '*.xamlx';
            Verb = 'GET,HEAD,POST,DEBUG';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    });

    'xoml-Integrated-4.0' = (New-Object PSObject -Property @{
            Name = 'xoml-Integrated-4.0';
            Path = '*.xoml';
            Verb = '*';
            Type = 'System.ServiceModel.Activation.ServiceHttpHandlerFactory,;System.ServiceModel.Activation,;Version = 4.0.0.0,;Culture = neutral,;PublicKeyToken = 31bf3856ad364e35';
            PreCondition = 'integratedMode,runtimeVersionv4.0'
    });

    'xoml-ISAPI-4.0_32bit' = (New-Object PSObject -Property @{
            Name = 'xoml-ISAPI-4.0_32bit';
            Path = '*.xoml';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness32';
            ResponseBufferLimit = '0'
    });

    'xoml-ISAPI-4.0_64bit' = (New-Object PSObject -Property @{
            Name = 'xoml-ISAPI-4.0_64bit';
            Path = '*.xoml';
            Verb = '*';
            Modules = 'IsapiModule';
            ScriptProcessor = '%windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_isapi.dll';
            PreCondition = 'classicMode,runtimeVersionv4.0,bitness64';
            ResponseBufferLimit = '0'
    })
}

#endregion
function Get-TargetResource
{
    <#
    .SYNOPSIS
        This will return a hashtable of results 
    #>

    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [Parameter(Mandatory)]
        [ValidateSet('Present', 'Absent')]
        [String] $Ensure
    )

    # Check if WebAdministration module is present for IIS cmdlets
    Assert-Module

    $handler = Get-Handler -Name $Name

    if ($null -eq $handler)
    {
        Write-Verbose -Message $LocalizedData.VerboseGetTargetAbsent
        return @{
            Ensure = 'Absent'
            Name   = $Name
        }
    }
    else
    {
        Write-Verbose -Message $LocalizedData.VerboseGetTargetPresent
        return @{
            Ensure = 'Present'
            Name   = $Name
        }
    }
}
function Set-TargetResource
{
    <#
    .SYNOPSIS
        This will set the desired state

    .NOTES
        There are a few limitations with this resource:
        It only supports builtin handlers, that come with IIS, not third party ones.
        Removing handlers should be no problem, but all new handlers are added at the
        top of the list, meaning, they are tried first. There is no way of ordering the
        handler list except for removing all and then adding them in the correct order.
    #>
    
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [Parameter(Mandatory)]
        [ValidateSet('Present', 'Absent')]
        [String] $Ensure
    )

    Assert-Module

    [String] $psPathRoot  = 'MACHINE/WEBROOT/APPHOST'
    [String] $sectionNode = 'system.webServer/handlers'

    $handler = Get-Handler -Name $Name

    if ($null -eq $handler -and $Ensure -eq 'Present')
    {
        # add the handler
        Add-Handler -Name $Name
        Write-Verbose -Message ($LocalizedData.AddingHandler -f $Name)
    }
    elseif ($null -ne $handler -and $Ensure -eq 'Absent')
    {
        # remove the handler
        Remove-WebConfigurationProperty -PSPath $psPathRoot `
                                        -Filter $sectionNode `
                                        -Name '.' `
                                        -AtElement @{name="$Name"}
        Write-Verbose -Message ($LocalizedData.RemovingHandler -f $Name)
    }
}
function Test-TargetResource
{
    <#
    .SYNOPSIS
        This tests the desired state. If the state is not correct it will return $false.
        If the state is correct it will return $true
    #>
    
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [Parameter(Mandatory)]
        [ValidateSet('Present', 'Absent')]
        [String] $Ensure
    )

    Assert-Module

    $handler = Get-Handler -Name $Name

    if (($null -eq $handler -and $Ensure -eq 'Present') -or `
        ($null -ne $handler -and $Ensure -eq 'Absent'))
    {
        return $false
    }
    elseif ($null -ne $handler -and $Ensure -eq 'Present')
    {
        # Handler is present
        Write-Verbose -Message ($LocalizedData.HandlerExists -f $Name)
        return $true
    }
    else
    {
        # Handler not present and should not be there.
        Write-Verbose -Message ($LocalizedData.HandlerNotPresent -f $Name)
        return $true
    }
}

#region Helper Functions

function Get-Handler
{
    param
    (
        [String] $Name
    )

    [String] $filter = "system.webServer/handlers/Add[@Name='" + $Name + "']"
    return Get-WebConfigurationProperty  -PSPath 'MACHINE/WEBROOT/APPHOST' `
                                         -Filter $filter `
                                         -Name '.'
}

function Add-Handler
{
    param
    (
        [String] $Name
    )

    # check whether our dictionary has an item with the specified key
    if ($script:handlers.ContainsKey($Name))
    {
        # add the new handler
        Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
                                     -Filter 'system.webServer/handlers' `
                                     -Name '.' `
                                     -Value $script:handlers[$Name]
    }
    else
    {
        New-TerminatingError -ErrorId 'HandlerNotSupported' `
                             -ErrorMessage $($LocalizedData.HandlerNotSupported -f $Name) `
                             -ErrorCategory InvalidArgument
    }
}

#endregion

Export-ModuleMember -Function *-TargetResource
