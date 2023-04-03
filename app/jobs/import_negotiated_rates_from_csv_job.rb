class ImportNegotiatedRatesFromCsvJob
  require "./lib/functions.rb"
  extend HelpfulFunctions
  
  @queue = :main_queue

  def self.perform(params)
    Resque.logger.info("Hello!")
    file = params['file']
    tempfile = Tempfile.new('file')
    tempfile.binmode
    tempfile.write(Base64.decode64(file['tempfile']))

    # Now that the file is decoded you need to build a new
    # ActionDispatch::Http::UploadedFile with the decoded tempfile and the other
    # attritubes you passed in.

    file = ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: file['original_filename'], type: file['content_type'], head: file['headers'])

    # This object is now the same as the one in your controller in params[:file]

    file_open = File.open(file)
    csv = CSV.parse(file_open, headers: true, col_sep: ',')

    csv.each do |row|
      negotiated_rate_hash = {}
      negotiated_rate_hash[:billing_code] = row["billing_code"]
      negotiated_rate_hash[:billing_code_type] = row["billing_code_type"]
      negotiated_rate_hash[:negotiation_arrangement] = row["negotiation_arrangement"]
      negotiated_rate_hash[:negotiated_type] = row["negotiated_type"]
      negotiated_rate_hash[:negotiated_rate] = row["negotiated_rate"]
      negotiated_rate_hash[:experation_date] = row["experation_date"]
      negotiated_rate_hash[:billing_class] = row["billing_class"]
      negotiated_rate_hash[:service_code] = row["service_code"]
      negotiated_rate_hash[:billing_code_modifier] = row["billing_code_modifier"]
      negotiated_rate_hash[:tin] = row["tin"]
      negotiated_rate_hash[:tin_type] = row["tin_type"]
      negotiated_rate_hash[:npi] = row["npi"]
      negotiated_rate_hash[:health_plan_id] = row["health_plan_id"].to_i

      code = Code.find_by(code: row["billing_code"])
      negotiated_rate_hash[:code_id] = code.id

      facility = {}
      clinician = {}

      if row["billing_class"] == "institutional" && row["tin_type"] == "ein"

          if Facility.exists?(npi: row["npi"])
              facility = Facility.find_by(npi: row["npi"])
          else
              ImportNegotiatedRatesFromCsvJob.create_facility_via_api_call(row["npi"])
              facility = Facility.find_by(npi: row["npi"])
          end

      elsif row["billing_class"] == "professional" && row["tin_type"] == "npi"

          if Facility.exists?(npi: row["tin"])
              facility = Facility.find_by(npi: row["tin"])
          else
              ImportNegotiatedRatesFromCsvJob.create_facility_via_api_call(row["tin"])
              facility = Facility.find_by(npi: row["tin"])
          end

          if Clinician.exists?(npi: row["npi"])
              clinician = Clinician.find_by(npi: row["npi"])
          else
              ImportNegotiatedRatesFromCsvJob.create_clinician_via_api_call(row["npi"])
              clinician = Clinician.find_by(npi: row["npi"])
          end
      else
          break
      end

      if facility.present? == false #if the API is down and the upload triggers a new facility to be created, create_facility_via_api_call will return w/o throwing an error or creatng the facility. Because of that we need to catch that edge case and skip over it
      elsif clinician.present? == false #not all NPIs are in the CMS API that we're hitting above and Institutional negotiated rates don't have a clincian association
            negotiated_rate_hash[:facility_id] = facility.id
            NegotiatedRate.find_or_create_by(negotiated_rate_hash)
      else
          negotiated_rate_hash[:facility_id] = facility.id
          negotiated_rate_hash[:clinician_id] = clinician.id
          NegotiatedRate.find_or_create_by(negotiated_rate_hash)
      end 
    end
  end
end
