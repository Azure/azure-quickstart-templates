using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using System.Configuration;
using System.Data.SqlClient;

namespace FunctionApp
{
    public static class OrderPaymentProcessing
    {
        [FunctionName("OrderPaymentProcessing")]
        public static void Run([QueueTrigger("ordertransactions", Connection = "storageConnection")]string orderId, TraceWriter log)
        {
            log.Info($"C# Queue trigger function processed: {orderId}");

            var str = ConfigurationManager.ConnectionStrings["CatalogConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(str))
            {
                conn.Open();
                var text = "update dbo.Orders set [Status] = 'Paid' where Id = " + orderId;

                using (SqlCommand cmd = new SqlCommand(text, conn))
                {
                    // Execute the command and log the # rows affected.
                    var rows = cmd.ExecuteNonQuery();
                    log.Info($"{rows} rows were updated");
                }
            }
        }
    }
}
