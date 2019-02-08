require 'rest-client'
require 'json'

module Moodle
  module Api
    # Handles making the request to the Moodle API and interpreting the
    # results. The Moodle API is not consistent in the way it returns
    # responses so the type of response is determined, successful responses
    # are returned, failures are parsed and raised in a generic fashion.
    class Request
      attr_reader :response

      def post(path,  options = {})
        begin
          puts "Inside vendor/moodle-api/.../request.rb"
          puts options[:headers]
          puts options[:params]

          resp = RestClient.post(path, options[:params], options[:headers])

          return JSON.parse(resp.body)

        rescue RestClient::ExceptionWithResponse => e
           raise e.response
        end
      end

      private

      def resolve_response
        response_body unless request_raised_exception?
      end

      def request_raised_exception?
        if external_services_api_exception?
          fail MoodleError, response_body['message']
        elsif token_service_api_exception?
          fail MoodleError, response_body['error']
        end
      end

      def exception_raised?
        external_services_api_exception? && token_service_api_exception?
      end

      def external_services_api_exception?
        response_body.is_a?(Hash) && response_body['exception']
      end

      def token_service_api_exception?
        response_body.is_a?(Hash) && response_body['error']
      end

      # API calls that return null are considered successful
      def response_body
        JSON.parse(response.body)
      rescue JSON::ParserError
        response.body
      end
    end
  end
end
