using Newtonsoft.Json;
using System;

namespace PlanConversionAgent.Definitions
{
    /// <summary>
    /// The notification definition.
    /// </summary>
    public class PlanUpdateNotificationDefinition
    {
        /// <summary>
        /// Gets or sets the content version.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public string ContentVersion { get; set; }

        /// <summary>
        /// Gets or sets the application resource identifier.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public string ApplicationId { get; set; }

        /// <summary>
        /// Gets or sets the timestamp of the notification event.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public DateTime EventTime { get; set; }

        /// <summary>
        /// Gets or sets the current plan.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public Plan CurrentPlan { get; set; }

        /// <summary>
        /// Gets or sets the new plan.
        /// </summary>
        [JsonProperty(Required = Required.Always)]
        public Plan NewPlan { get; set; }
    }
}
