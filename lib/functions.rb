module HelpfulFunctions
    require "csv"
    require "httparty"
    require "json"
    require "open-uri"

    def get_geolocation_data(facility)
        facility = Facility.find(facility.id)
        locations = facility.locations

        locations.each do |location|
            begin
                google_maps_api_key = "AIzaSyDSL85vkykDd8e2g7Z5mzd-zJvf779k0dM"
                street_1 = location.address_1
                city = location.city
                state = location.state
                zip_code = location.postal_code
                google_maps_api = "https://maps.googleapis.com/maps/api/geocode/json?address=#{street_1},+#{city},+#{state}&key=#{google_maps_api_key}"
                geo_data_raw = URI.open(google_maps_api).read
                geo_data_hash = JSON.parse(geo_data_raw)
                geo_data_hash["results"].each do |hash|
                    location.latitude = hash["geometry"]["location"]["lat"]
                    location.longitude = hash["geometry"]["location"]["lng"]
                    location.save
                end
            rescue
                puts "Error Getting Geo Data!"
            end
        end
    end

    def create_facility_via_api_call(npi)
        print(npi)
        facility_npi_url = "https://npiregistry.cms.hhs.gov/api/?number=#{npi}&enumeration_type=&taxonomy_description=&first_name=&use_first_name_alias=&last_name=&organization_name=&address_purpose=&city=&state=&postal_code=&country_code=&limit=&skip=&pretty=on&version=2.1"
        facility_npi_raw = URI.open(facility_npi_url).read
        facility_npi_hash = JSON.parse(facility_npi_raw)

        facility_hash = {}
        facility_hash[:name] = facility_npi_hash["results"][0]["basic"].fetch("organization_name", "")
        if facility_npi_hash["results"][0]['other_names'].present?
            facility_hash[:organization_dba_name] = facility_npi_hash["results"][0]["other_names"][0].fetch("organization_name", "")
        else
        end

        facility_hash[:npi] = npi

        Facility.exists?(npi: npi) ? Facility.update(facility_hash) : Facility.create(facility_hash)

        facility = Facility.find_by(npi: npi)

        facility_npi_hash["results"][0]['addresses'].each do |address|
            location_hash = {}
            if address['address_purpose'] == "LOCATION"
                location_hash[:address_1] = address["address_1"]
                location_hash[:address_2] = address.fetch("address_2", "")
                location_hash[:city] = address["city"]
                location_hash[:state] = address["state"]
                zip_string = address["postal_code"]
                location_hash[:postal_code] = zip_string[0,5]
                location_hash[:telephone_number] = address["telephone_number"]
                location_hash[:fax_number] = address.fetch("fax_number", "")
                location_hash[:facility_id] = facility.id
                Location.find_or_create_by(location_hash)
            else
                next
            end
        end

        get_geolocation_data(facility)

        facility_npi_hash["results"][0]['taxonomies'].each do |taxonomy|
            taxonomy_hash = {}
            taxonomy_hash[:code] = taxonomy["code"]
            taxonomy_hash[:taxonomy_group] = taxonomy["taxonomy_group"]
            taxonomy_hash[:desc] = taxonomy["desc"]
            taxonomy_hash[:state] = taxonomy["state"]
            taxonomy_hash[:license] = taxonomy["license"]
            taxonomy_hash[:primary] = taxonomy["primary"]
            taxonomy_hash[:facility_id] = facility.id
            Taxonomy.find_or_create_by(taxonomy_hash)
        end

        if facility_npi_hash["results"][0]['identifiers'].present?
            facility_npi_hash["results"][0]['identifiers'].each do |identifier|
                identifier_hash = {}
                identifier_hash[:code] = identifier["code"]
                identifier_hash[:desc] = identifier["desc"]
                identifier_hash[:issuer] = identifier["issuer"]
                identifier_hash[:identifier] = identifier["identifier"]
                identifier_hash[:state] = identifier["state"]
                identifier_hash[:facility_id] = facility.id
                Identifier.find_or_create_by(identifier_hash)
            end
        else
            print("Not present =)")
        end
    end

    def create_clinician_via_api_call(npi)
        begin
            clinician_api_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%206fdc4567-4ae7-5d31-8adc-adeb7a629787%5D%5BWHERE%20npi%20%3D%20%22#{npi}%22%5D%5BLIMIT%201%5D"
            clinician_api_raw = URI.open(clinician_api_url).read
            clinician_api_hash = JSON.parse(clinician_api_raw)

            clinician_hash = {}
            clinician_hash[:npi] = clinician_api_hash[0]["NPI"]
            clinician_hash[:ind_PAC_ID] = clinician_api_hash[0]["Ind_PAC_ID"]
            clinician_hash[:first_name] = clinician_api_hash[0]["frst_nm"]
            clinician_hash[:middle_name] = clinician_api_hash[0]["mid_nm"]
            clinician_hash[:last_name] = clinician_api_hash[0]["lst_nm"]
            clinician_hash[:suffix] = clinician_api_hash[0]["suff"]
            clinician_hash[:credential] = clinician_api_hash[0]["Cred"]
            clinician_hash[:medical_school] = clinician_api_hash[0]["Med_sch"]
            clinician_hash[:graduation_year] = clinician_api_hash[0]["Grd_yr"]
            clinician_hash[:primary_speciality] = clinician_api_hash[0]["pri_spec"]
            clinician_hash[:secondary_speciality_1] = clinician_api_hash[0]["sec_spec_1"]
            clinician_hash[:secondary_speciality_2] = clinician_api_hash[0]["sec_spec_2"]
            clinician_hash[:secondary_speciality_3] = clinician_api_hash[0]["sec_spec_3"]
            clinician_hash[:secondary_speciality_4] = clinician_api_hash[0]["sec_spec_4"]

            Clinician.exists?(npi: npi) ? Clinician.update(clinician_hash) : Clinician.create(clinician_hash)
        rescue
            puts "Error Getting Clinician Data for NPI: #{npi}!"
        end
    end
end