
namespace PlanConversionAgent.Definitions
{
    /// <summary>
    /// The async operation result.
    /// </summary>
    public class AsyncOperationResult
    {
        /// <summary>
        /// Gets or sets the status of the async operation.
        /// It must be "Succeeded", "Running" or "Failed" only.
        /// </summary>
        public string Status { get; set; }

        /// <summary>
        /// Gets or sets the extended error info.
        /// </summary>
        public Error Error { get; set; }

        /// <summary>
        /// Gets the asynchronous operation result.
        /// </summary>
        /// <param name="provisioningState">State of the provisioning.</param>
        /// <param name="errorCode">The error code.</param>
        /// <param name="message">The message.</param>
        public static AsyncOperationResult GetAsyncOperationResult(
            string provisioningState,
            string errorCode = null,
            string message = null)
        {
            return AsyncOperationResult.GetAsyncOperationResult(
                provisioningState: provisioningState,
                error: AsyncOperationResult.GetErrorInfo(errorCode: errorCode, message: message));
        }

        /// <summary>
        /// Gets the asynchronous operation result.
        /// </summary>
        /// <param name="provisioningState">State of the provisioning.</param>
        /// <param name="error">The extended error info.</param>
        public static AsyncOperationResult GetAsyncOperationResult(string provisioningState, Error error)
        {
            return new AsyncOperationResult
            {
                Status = provisioningState.ToString(),
                Error = error
            };
        }

        /// <summary>
        /// Gets the error info.
        /// </summary>
        /// <param name="errorCode">The error code.</param>
        /// <param name="message">The message.</param>
        private static Error GetErrorInfo(
            string errorCode = null,
            string message = null)
        {
            if (!string.IsNullOrEmpty(errorCode) && !string.IsNullOrEmpty(message))
            {
                return new Error
                {
                    Code = errorCode,
                    Message = message
                };
            }

            return null;
        }
    }
}
