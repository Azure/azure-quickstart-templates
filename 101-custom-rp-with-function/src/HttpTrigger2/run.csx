#r "Newtonsoft.Json"

using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Configuration;
using System.Text;
using System.Threading;
using System.Globalization;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


public static HttpResponseMessage Run(HttpRequestMessage req, string subscriptionId, string resourceGroupName, string miniRpName, string action, ILogger log = null)
{
    HttpResponseMessage response = null;    
    // POST a ping action 
    if (action == "ping") 
    {      
        if ( req.Method.ToString() != "POST" ) 
        {
            response = req.CreateResponse(HttpStatusCode.MethodNotAllowed);
        }
        else
        {
            var host = req.Headers.Host ?? "anonymous" ;
            var content = $"{{ 'pingcontent' : {{ 'source' : '{host}' }} , 'message' : 'hello {host}'}}";
            response = req.CreateResponse(HttpStatusCode.OK);    
            response.Content = new StringContent(content, System.Text.Encoding.UTF8, "application/json");
        }
        return response;
    } 
    return response;
}