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

public class UserResource
{
    public string name {get; set;}
    public string type {get; set;}
    public string id {get; set;}
    public User properties {get; set;}
}


public class User
{
    public string FullName {get; set;}
    public string Location {get; set;}
}

private static string separator = ":::";

public static HttpResponseMessage Run(HttpRequestMessage req, string subscriptionId, string resourceGroupName, string miniRpName, string action, string instorageBlob, out string outstorageBlob, string name = null, ILogger log = null)
{
    HttpResponseMessage response = null;    
    outstorageBlob = instorageBlob;

    // functions seem to just set this value to {name} if not provider. Setting to null for processing
    if(name == "{name}")
    {
        name = null;        
    }

    // Resource mgmt for "Users" resource
    if(action == "users")
    {
        var callmethod = req.Method.ToString();
        var userInfo = getUserDictionaryFromFile(instorageBlob, log);
        if(String.IsNullOrEmpty(name) && callmethod != "GET")
        {
            response = req.CreateResponse(HttpStatusCode.MethodNotAllowed);
            return response;
        }
        var id = req.RequestUri.AbsolutePath.Replace("/api","").ToLower();
        switch (callmethod)
        {
            case "PUT":
            //add the user
            string bodyString = req.Content.ReadAsStringAsync().Result;
            var userJson = JToken.Parse(bodyString);
            var inputObject = userJson.ToObject<UserResource>();
            inputObject.id = id;
            inputObject.name = name;
            inputObject.type = "Microsoft.CustomProviders/resourceproviders/users";

            if(userInfo.TryGetValue(id, out UserResource tempUser))
            {
                userInfo[id] = inputObject;
                response = req.CreateResponse(HttpStatusCode.OK);
                response.Content = new StringContent(JToken.FromObject(inputObject).ToString(), System.Text.Encoding.UTF8, "application/json");
            }
            else
            {
                userInfo.Add(id, inputObject);
                response = req.CreateResponse(HttpStatusCode.Created);
                response.Content = new StringContent(JToken.FromObject(inputObject).ToString(), System.Text.Encoding.UTF8, "application/json");
            }
            
            break;
            case "GET":
            // get the user
            if(String.IsNullOrEmpty(name))
            {
                // return all the users
                response = req.CreateResponse(HttpStatusCode.OK);
                response.Content = new StringContent(JToken.FromObject(userInfo).ToString(), System.Text.Encoding.UTF8, "application/json");
            }
            else
                if(userInfo.TryGetValue(id, out UserResource getUser))
                {
                    response = req.CreateResponse(HttpStatusCode.OK);          
                    response.Content = new StringContent(JToken.FromObject(getUser).ToString(), System.Text.Encoding.UTF8, "application/json");
                }
                else
                {
                    response = req.CreateResponse(HttpStatusCode.NotFound);
                }
            break;
            case "DELETE":
            //Delete the user            
            if(userInfo.TryGetValue(id, out UserResource deleteUser))
            {
                userInfo.Remove(id);
                response = req.CreateResponse(HttpStatusCode.OK);
                response.Content = new StringContent(JToken.FromObject(deleteUser).ToString(), System.Text.Encoding.UTF8, "application/json");
            }
            else
            {
                response = req.CreateResponse(HttpStatusCode.NotFound);
            }
            
            break;
            default:
            response = req.CreateResponse(HttpStatusCode.MethodNotAllowed);
            break;
        }
        outstorageBlob = saveuserDictionary(userInfo, log);        
    }    
    return response;
}

private static Dictionary<string, UserResource> getUserDictionaryFromFile(string storageBlob, ILogger log)
{
    Dictionary<string, UserResource> dictionary = new Dictionary<string, UserResource>();    

    if(String.IsNullOrEmpty(storageBlob)) return dictionary; 
    
    var users = storageBlob.Split(separator);    
    foreach(string user in users)
    {           
        var data = user.Split(",");        
        if(data.Length == 5)
        {
            dictionary.Add(data[2], new UserResource { name = data[0], type = data[1], id = data[2], properties = new User {FullName = data[3], Location = data[4]}});
        }
    }
    return dictionary;
}

private static string saveuserDictionary(Dictionary<string, UserResource> userdictionary, ILogger log)
{    
    string storageBlob = "";    
    foreach(KeyValuePair<string, UserResource> userid in userdictionary)
    {                
        var data = GetSaveFormat(userid.Value);
        storageBlob += data + separator;
    }
    return storageBlob;
}

private static string GetSaveFormat(UserResource userresource)
{
    return $"{userresource.name},{userresource.type},{userresource.id},{userresource.properties.FullName},{userresource.properties.Location}";
}