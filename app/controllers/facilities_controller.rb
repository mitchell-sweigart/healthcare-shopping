class FacilitiesController < ApplicationController
    require "csv"
    require "httparty"
    require "json"
    require "open-uri"

    def index
        @facilities = Facility.where(["name LIKE :name", { :name => "%#{params[:q]}%" }]).order(:name)
    end

    def new
        @facility = Facility.new
    end

    def create
        @facility = Facility.create(facility_params)
        if @facility.save
            redirect_to '/facilities'
        else
            redirect_to '/facility/new'
        end
    end

    def edit
        @facility = Facility.find(params[:id])
    end

    def show

        @facility = Facility.find(params[:id])
        @timely_and_effective_care_ratings = Facility.find(params[:id]).timely_and_effective_care_ratings
        @services = Facility.find(params[:id]).services
        @ratings = Facility.find(params[:id]).ratings
        facilityID = @facility.facility_id

        begin
            google_maps_api_key = "AIzaSyDSL85vkykDd8e2g7Z5mzd-zJvf779k0dM"
            street_1 = @facility.address_line_one
            city = @facility.address_city
            state = @facility.address_state
            zip_code = @facility.address_zip_code
            google_maps_api = "https://maps.googleapis.com/maps/api/geocode/json?address=#{street_1},+#{city},+#{state}&key=#{google_maps_api_key}"
            geo_data_raw = URI.open(google_maps_api).read
            geo_data_hash = JSON.parse(geo_data_raw)
            geo_data_hash["results"].each do |hash|
                @facility.latitude = hash["geometry"]["location"]["lat"]
                @facility.longitude = hash["geometry"]["location"]["lng"]
                @facility.save
            end
        rescue
            puts "Error Getting Geo Data!"
        end

        begin
            time_and_effective_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%207526d6d9-59a1-554a-b091-696e3da3aa84%5D%5BWHERE%20facility_id%20%3D%20%22#{facilityID}%22%5D&show_db_columns=true"
            time_and_effective_care_ratings_raw = URI.open(time_and_effective_url).read
            time_and_effective_care_ratings_hash = JSON.parse(time_and_effective_care_ratings_raw)

            time_and_effective_care_ratings_hash.each do |time_and_effective_care_rating|
                rating_hash = {}
                rating_hash[:condition] = time_and_effective_care_rating["condition"]
                rating_hash[:measure_id] = time_and_effective_care_rating["measure_id"]
                rating_hash[:measure_name] = time_and_effective_care_rating["measure_name"]
                rating_hash[:score] = time_and_effective_care_rating["score"]
                rating_hash[:sample] = time_and_effective_care_rating["sample"]
                rating_hash[:facility_id] = @facility.id
                TimelyAndEffectiveCareRating.find_or_create_by!(rating_hash)
            end
        rescue
            puts "Facility does not have a facility ID"
        end

        begin
            facility_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%20c9888e32-7acc-59ad-9915-fbdb8128d611%5D%5BWHERE%20facility_id%20%3D%20%22#{facilityID}%22%5D"
            facility_raw = URI.open(facility_url).read
            facility_hash = JSON.parse(facility_raw)

            facility_hash.each do |facility|
                update_facility_hash = {}
                update_facility_hash[:facility_id] = facility["Facility ID"]
                update_facility_hash[:name] = facility["Facility Name"]
                update_facility_hash[:address_line_one] = facility["Address"]
                update_facility_hash[:address_city] = facility["City"]
                update_facility_hash[:address_state] = facility["State"]
                update_facility_hash[:address_zip_code] = facility["ZIP Code"]
                update_facility_hash[:overall_rating] = facility["Hospital overall rating"]
                Facility.update(@facility.id, update_facility_hash)
            end
        rescue
            puts "Facility does not have a Hospital Record"
        end

        begin
            npi = @facility.npi
            asc_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%20340ffea2-1ba3-5528-bb90-5bfe0b50e5ec%5D%5BWHERE%20npi%20%3D%20%22#{npi}%22%5D"

            asc_raw = URI.open(asc_url).read
            asc_hash = JSON.parse(asc_raw)
            asc = asc_hash.last()

            update_asc_hash = {}
            update_asc_hash[:facility_id] = asc["Facility ID"]
            update_asc_hash[:name] = asc["Facility Name"]
            update_asc_hash[:address_city] = asc["City"]
            update_asc_hash[:address_state] = asc["State"]
            update_asc_hash[:address_zip_code] = asc["ZIP Code"]
            update_asc_hash[:overall_rating] = asc["ASC-9 Rate"]
            Facility.update(@facility.id, update_asc_hash)
        rescue
            puts "Facility does not have Ambulatory Surgical Center Quality Measures"
        end

        begin
            dialysis_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%20263d29a4-b636-5842-a2b4-ea668e525602%5D%5BWHERE%20provider_number%20%3D%20%22#{facilityID}%22%5D"

            dialysis_raw = URI.open(dialysis_url).read
            dialysis_hash = JSON.parse(dialysis_raw)
            dialysis = dialysis_hash.last()

            update_dialysis_hash = {}
            update_dialysis_hash[:facility_id] = dialysis["Provider Number"]
            update_dialysis_hash[:name] = dialysis["Facility Name"]
            update_dialysis_hash[:address_line_one] = dialysis["Address Line 1"]
            update_dialysis_hash[:address_line_two] = dialysis["Address Line 2"]
            update_dialysis_hash[:address_city] = dialysis["City"]
            update_dialysis_hash[:address_state] = dialysis["State"]
            update_dialysis_hash[:address_zip_code] = dialysis["Zip"]
            update_dialysis_hash[:overall_rating] = dialysis["Five Star"]
            Facility.update(@facility.id, update_dialysis_hash)
        rescue
            puts "Facility does not have Dialysis Information Available"
        end

        @facility = Facility.find(params[:id])

    end

    def destroy
        @facility = Facility.find(params[:id])
        if @facility.destroy
        redirect_to facilities_path, notice: "Facility has been deleted successfully"
        end
    end

    def update
        @facility = Facility.find(params[:id])
        if @facility.update(params.require(:facility).permit(
            :facility_id, 
            :facility_type,
            :name, 
            :npi, 
            :org_PAC_ID, 
            :address_line_one, 
            :address_line_two, 
            :address_city, 
            :address_state, 
            :address_zip_code,
            :overall_rating,
            :latitude,
            :longitude,
            clinician_ids: []
            ))

            flash.notice = "Facility successfully updated!"
            redirect_to '/facilities'
        else
            flash.notice = "facility unsuccessfully update!"
        end
    end

    def import
        file = params[:file]
        return redirect_to facilities_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            facility_hash = {}
            facility_hash[:name] = row["name"]
            facility_hash[:address_line_one] = row["address_line_one"]
            facility_hash[:address_line_two] = row["address_line_two"]
            facility_hash[:address_city] = row["address_city"]
            facility_hash[:address_state] = row["address_state"]
            facility_hash[:address_zip_code] = row["address_zip_code"]
            facility_hash[:npi] = row["npi"]
            facility_hash[:org_PAC_ID] = row["org_PAC_ID"]
            Facility.find_or_create_by!(facility_hash)
        end
        redirect_to facilities_path, notice: "facilities Imported!"
    end

    def bulk_import
        file = params[:file]
        return redirect_to facilities_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')

        csv.each do |row|
            npi = row["npi"]
            facility_npi_url = "https://npiregistry.cms.hhs.gov/api/?number=#{npi}&enumeration_type=&taxonomy_description=&first_name=&use_first_name_alias=&last_name=&organization_name=&address_purpose=&city=&state=&postal_code=&country_code=&limit=&skip=&pretty=on&version=2.1"
            facility_npi_raw = URI.open(facility_npi_url).read
            facility_npi_hash = JSON.parse(facility_npi_raw)

            facility_npi_hash["results"].each do |facility|
                facility_hash = {}
                facility_hash[:name] = facility["basic"]["organization_name"]
                facility_hash[:address_line_one] = facility['addresses'][0]["address_1"]
                facility_hash[:address_city] = facility['addresses'][0]["city"]
                facility_hash[:address_state] = facility['addresses'][0]["state"]
                facility_hash[:address_zip_code] = facility['addresses'][0]["postal_code"]
                facility_hash[:npi] = facility["number"]
                Facility.find_or_create_by!(facility_hash)
            end
        end
        redirect_to facilities_path, notice: "Facilities Imported!"
    end

    def bulk_delete
        file = params[:file]
        return redirect_to services_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            Facility.destroy(row["facility_id"])
        end
        redirect_to providers_path, notice: "Facilities Deleted"
    end

    private
    
    def facility_params
        new_facility = params.require(:facility).permit(
            :facility_id, 
            :facility_type, 
            :name, 
            :address_line_one, 
            :address_line_two, 
            :address_city, 
            :address_state, 
            :address_zip_code, 
            :npi, 
            :org_PAC_ID,
            :overall_rating,
            :latitude,
            :longitude,
            clinician_ids: []
            )
    end
    
end