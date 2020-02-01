namespace Functions.Configurations
{
    public class SpeechConfiguration
    {
        // Subscription Key of Speech Service
        public string SpeechSubscriptionKey { get; set; }
        // Region of the speech service, see https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/regions for more details.
        public string SpeechServiceRegion { get; set; }
        // Device ID
        public string DeviceName { get; set; }
    }
}