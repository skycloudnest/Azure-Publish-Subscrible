using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace CommonFunction
{
    public class ServicebusTrigerFunction(ILogger<ServicebusTrigerFunction> logger)
    {
        private readonly ILogger<ServicebusTrigerFunction> _logger = logger;

        [Function(nameof(ServicebusTrigerFunction))]
        public async Task Run(
            [ServiceBusTrigger(topicName: "%TopicName%", subscriptionName: "%SubscriptionName%", Connection = "ServiceBusConnection")]
            ServiceBusReceivedMessage message,
            ServiceBusMessageActions messageActions)
        {
            _logger.LogInformation("Message ID: {id}", message.MessageId);
            _logger.LogInformation("Message Body: {body}", message.Body);
            _logger.LogInformation("Message Content-Type: {contentType}", message.ContentType);
            _logger.LogInformation("Message Lock-Token: {LockToken}", message.LockToken);

            // Complete the message
            await messageActions.CompleteMessageAsync(message);
        }
    }
}
