using Newtonsoft.Json;

namespace PlanConversionAgent.Definitions
{
    /// <summary>
    /// The marketplace plan.
    /// </summary>
    public class Plan
    {
        /// <summary>
        /// Gets or sets the publisher.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public string Publisher { get; set; }

        /// <summary>
        /// Gets or sets the product (offer name).
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public string Product { get; set; }

        /// <summary>
        /// Gets or sets the SKU name.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the plan version.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public string Version { get; set; }
    }
}
