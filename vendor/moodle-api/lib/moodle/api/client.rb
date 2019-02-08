module Moodle
  module Api
    # The client is responsible for making requests
    # and delegating config setup to configuration
    class Client
      attr_reader :web_service_name, :filter_params
      attr_writer :token_service, :configuration

      def initialize(options = {})
        configure(options)
      end

      def make_request(web_service_name, filter_params = {})
        @web_service_name = web_service_name
        @filter_params = filter_params
        puts "Inside vendor/moodle-api/.../client.rb"
        puts configuration.web_service_api_url

        Request.new.post(configuration.web_service_api_url, request_params)
      end

      def request_params
        {
          params: filter_params.merge!(moodlewsrestformat: configuration.format,
                                       wsfunction: web_service_name,
                                       wstoken: configuration.token),
          headers: { 'Accept' => 'json' }
        }
      end

      def configure(options = {}, &block)
        configuration.configure(options, &block)
      end

      def reset_configuration
        configuration.reset
      end

      def configuration
        @configuration ||= Configuration.new
      end
    end
  end
end
