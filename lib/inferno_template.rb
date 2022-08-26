require_relative 'inferno_template/separate_validators'
require_relative 'inferno_template/one_validator'

module InfernoTemplate
  class Suite < Inferno::TestSuite
    id :test_suite_template
    title 'Inferno + HL7 Validator Demo Suite'
    description 'A basic test suite for Inferno'

    # This input will be available to all tests in this suite
    input :fhir_url
    #input :http_url
    #ENV.fetch('VALIDATOR_URL')

    # All FHIR requests in this suite will use this FHIR client
    fhir_client :fhir_client do
      url :fhir_url
    end

    http_client do
      #url "localhost:8082"
      url ENV.fetch('VALIDATOR_URL')
    end

    # Tests and TestGroups can be defined inline
    """
    group do
      id :capability_statement
      title 'Capability Statement'
      description 'Verify that the server has a CapabilityStatement'

      test do
        id :capability_statement_read
        title 'Read CapabilityStatement'
        description 'Read CapabilityStatement from /metadata endpoint'

        run do
          fhir_get_capability_statement

          assert_response_status(200)
          assert_resource_type(:capability_statement)
        end
      end
    end
    """
    # Tests and TestGroups can be written in separate files and then included
    # using their id
    group from: :separate_validators
    group from: :one_validator
  end
end
