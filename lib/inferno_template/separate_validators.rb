module InfernoTemplate
    class PatientGroup < Inferno::TestGroup
      title 'Patient Demo Tests'
      description 'Verify that the server makes Patient resources available'
      id :separate_validators
      igs = ['hl7.fhir.us.core#4.0.0', 'hl7.fhir.uv.ips#1.0.0', 'hl7.fhir.r4.core#4.0.1']

      validator do
        url ENV.fetch('VALIDATOR_URL')
        exclude_message { |message| message.type == 'info' }
      end
      
      test do
        title "Loading Requisite IG's"
        description %(
          Requests to the validator will load required IG's into separated validator instances.
        )
        run do
          post('defaultIg', body: igs)
        end
      end
  
      test do
        title "Server returns requested Patient resource from the Patient read interaction"
        description %(
          Verify that Patient resources can be read from the server.
        )
  
        input :patient_id
        # Named requests can be used by other tests
        makes_request :patient
      
        run do
          fhir_read(:patient, patient_id, name: :patient, client: :fhir_client)
  
          assert_response_status(200)
          assert_resource_type(:patient)
          assert resource.id == patient_id,
                 "Requested resource with id #{patient_id}, received resource with id #{resource.id}"
        end
      end
      
      test do
        title 'Patient resource is valid (Base FHIR)'
        description %(
          Verify that the Patient resource returned from the server is a valid FHIR resource.
        )
        # This test will use the response from the :patient request in the
        # previous test
        uses_request :patient
  
        run do
          assert_resource_type(:patient)
          assert_valid_resource()
          assert_response_status(200)
        end
      end
  
  
      test do
        title 'Patient resource is valid (US Core)'
        description %(
          Verify that the Patient resource returned from the server is a valid FHIR resource that conforms to the US Core Patient Profile.
        )
        # This test will use the response from the :patient request in the
        # previous test
        uses_request :patient
        #resource: :patient,
        run do
          assert_resource_type(:patient)
          assert_valid_resource(profile_url: "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient")
          assert_response_status(200)
        end
      end
  
      test do
        title 'Patient resource is valid (IPS)'
        description %(
          Verify that the Patient resource returned from the server is a valid FHIR resource that conforms to the IPS Patient Profile.
        )
        # This test will use the response from the :patient request in the
        # previous test
        uses_request :patient
  
        run do
          assert_resource_type(:patient)
          assert_valid_resource(resource: :patient, profile_url: "http://hl7.org/fhir/uv/ips/StructureDefinition/Patient-uv-ips", ig_url: ips)
          assert_response_status(200)
        end
      end
    end
  end
  
  
  
  
  