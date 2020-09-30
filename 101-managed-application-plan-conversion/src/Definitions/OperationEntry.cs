
namespace PlanConversionAgent.Definitions
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "CosmosDB is case sensitive.")]
    public class OperationEntry
    {
        /// <summary>
        /// Gets or sets the operation identifier.
        /// </summary>
        public string id { get; set; }

        /// <summary>
        /// Gets or sets the application identifier.
        /// </summary>
        public string applicationId { get; set; }

        /// <summary>
        /// Gets or sets the deployment tracking uri.
        /// </summary>
        public string deploymentTrackingUri { get; set; }
    }
}
