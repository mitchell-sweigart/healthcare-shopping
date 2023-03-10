class CliniciansController < ApplicationController
    require "csv"
    require "httparty"
    require "json"
    require "open-uri"

    def index
        @clinicians = Clinician.where("first_name LIKE ?", "%#{params[:q]}%")
    end

    def new
        @clinician = Clinician.new
    end

    def create
        @clinician = Clinician.create(clinician_params)
        if @clinician.save
            redirect_to '/clinicians'
        else
            redirect_to '/clinicians/new'
        end
    end

    def edit
        @clinician = Clinician.find(params[:id])
    end

    def show
        @clinician = Clinician.find(params[:id])
        @utilizations = Clinician.find(params[:id]).utilizations

        clinician_npi = @clinician.npi
        utlizations_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%207079c24c-9717-5224-9bf7-c6f45ab18eb6%5D%5BWHERE%20npi%20%3D%20%22#{clinician_npi}%22%5D"
        clinician_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%20ed54fac3-f8ec-5713-9a0e-740b4cbd7ba4%5D%5BWHERE%20NPI%20%3D%20%22#{clinician_npi}%22%5D%5BLIMIT%201%5D"
        facility_affiliations_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%20a9970163-ef6b-5a2e-b3f6-f18b0514e093%5D%5BWHERE%20npi%20%3D%20%22#{clinician_npi}%22%5D"

        clinician_raw = URI.open(clinician_url).read
        clinician_hash = JSON.parse(clinician_raw)

        clinician_hash.each do |clinician|
            organization_hash = {}
            organization_hash[:name] = clinician["org_nm"]
            organization_hash[:org_PAC_ID] = clinician["org_pac_id"]
            organization_hash[:num_org_members] = clinician["num_org_mem"]
            organization_hash[:address_line_one] = clinician["adr_ln_1"]
            organization_hash[:address_line_two] = clinician["adr_ln_2"]
            organization_hash[:address_city] = clinician["city"]
            organization_hash[:address_state] = clinician["st"]
            organization_hash[:address_zip] = clinician["zip"]
            organization_hash[:phone_number] = clinician["phn_numbr"]
            Organization.find_or_create_by!(organization_hash)
        end

        clinician_organization = Organization.find_by(org_PAC_ID: clinician_hash[0]["org_pac_id"], address_line_one: clinician_hash[0]["adr_ln_1"])

        clinician_hash.each do |clinician|
            clinician_hash = {}
            clinician_hash[:npi] = clinician["NPI"]
            clinician_hash[:ind_PAC_ID] = clinician["Ind_PAC_ID"]
            clinician_hash[:first_name] = clinician["frst_nm"]
            clinician_hash[:middle_name] = clinician["mid_nm"]
            clinician_hash[:last_name] = clinician["lst_nm"]
            clinician_hash[:suffix] = clinician["suff"]
            clinician_hash[:credential] = clinician["Cred"]
            clinician_hash[:medical_school] = clinician["Med_sch"]
            clinician_hash[:graduation_year] = clinician["Grd_yr"]
            clinician_hash[:primary_speciality] = clinician["pri_spec"]
            clinician_hash[:secondary_speciality_1] = clinician["sec_spec_1"]
            clinician_hash[:secondary_speciality_2] = clinician["sec_spec_2"]
            clinician_hash[:secondary_speciality_3] = clinician["sec_spec_3"]
            clinician_hash[:secondary_speciality_4] = clinician["sec_spec_4"]
            clinician_hash[:organization_id] = clinician_organization.id

            Clinician.update(@clinician.id, clinician_hash)
        end

        utlizations_raw = URI.open(utlizations_url).read
        utilizations_hash = JSON.parse(utlizations_raw)

        utilizations_hash.each do |utilization|
            utilization_hash = {}
            utilization_hash[:hcpcs_code] = utilization["hcpcs_code"]
            utilization_hash[:hcpcs_description] = utilization["hcpcs_description"]
            utilization_hash[:service_count] = utilization["line_srvc_cnt"].to_i
            utilization_hash[:beneficiary_count] = utilization["bene_cnt"].to_i
            utilization_hash[:clinician_id] = @clinician.id
            Utilization.find_or_create_by!(utilization_hash)
        end

        facilities_raw = URI.open(facility_affiliations_url).read
        facilities_hash = JSON.parse(facilities_raw)

        facilities_hash.each do |facility|
            if Facility.find_by(facility_id: facility["facility_afl_ccn"])
                next
            else
            facility_hash = {}
            facility_hash[:facility_id] = facility["facility_afl_ccn"]
            facility_hash[:facility_type] = facility["facility_type"]
            Facility.find_or_create_by!(facility_hash)
            end
        end

        facilities_array = []

        facilities_hash.each do |facility|
            facility_real = Facility.find_by(facility_id: facility["facility_afl_ccn"])
            facilities_array.push(facility_real.id)
        end

        clinicial_real = Clinician.find(@clinician.id)
        clinicial_real.facility_ids = facilities_array
        clinicial_real.save

        @clinician = Clinician.find(params[:id])
        @organization = Clinician.find(params[:id]).organization
        @facilities = Clinician.find(params[:id]).facility_ids

    end


    def destroy
        @clinician = Clinician.find(params[:id])
        if @clinician.destroy
        redirect_to clinicians_path, notice: "Clinician has been deleted successfully"
        end
    end

    def update
        @clinician = Clinician.find(params[:id])
        if @clinician.update(params.require(:clinician).permit(
            :suffix, 
            :first_name, 
            :middle_name, 
            :last_name, 
            :credential, 
            :medical_school, 
            :graduation_year, 
            :primary_speciality, 
            :secondary_speciality_1, 
            :secondary_speciality_2, 
            :secondary_speciality_3, 
            :secondary_speciality_4, 
            :npi, 
            :ind_PAC_ID,
            :organization_id))

            flash.notice = "Clinician successfully updated!"
            redirect_to '/clinicians'
        else
            flash.notice = "Clinician unsuccessfully update!"
        end
    end

    def import
        file = params[:file]
        return redirect_to providers_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            provider_hash = {}
            provider_hash[:name] = row["name"]
            provider_hash[:address_line_one] = row["address_line_one"]
            provider_hash[:address_line_two] = row["address_line_two"]
            provider_hash[:address_city] = row["address_city"]
            provider_hash[:address_state] = row["address_state"]
            provider_hash[:address_zip_code] = row["address_zip_code"]
            provider_hash[:npi] = row["npi"]
            provider_hash[:org_PAC_ID] = row["org_PAC_ID"]
            Provider.find_or_create_by!(provider_hash)
        end
        redirect_to providers_path, notice: "Providers Imported!"
    end

    def bulk_import
        file = params[:file]
        return redirect_to providers_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            clinician_npi = row['npi']
            clinician_url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%20e9c376df-9692-5773-8002-9a8082d134c6%5D%5BWHERE%20npi%20%3D%20%22#{clinician_npi}%22%5D%5BLIMIT%202%5D"
                             

            clinician_raw = URI.open(clinician_url).read
            clinician_hash = JSON.parse(clinician_raw)

            clinician_hash.each do |clinician|
                new_clinician_hash = {}
                new_clinician_hash[:npi] = clinician["NPI"]
                new_clinician_hash[:ind_PAC_ID] = clinician["Ind_PAC_ID"]
                new_clinician_hash[:first_name] = clinician["frst_nm"]
                new_clinician_hash[:middle_name] = clinician["mid_nm"]
                new_clinician_hash[:last_name] = clinician["lst_nm"]
                new_clinician_hash[:suffix] = clinician["suff"]
                new_clinician_hash[:credential] = clinician["Cred"]
                new_clinician_hash[:medical_school] = clinician["Med_sch"]
                new_clinician_hash[:graduation_year] = clinician["Grd_yr"]
                new_clinician_hash[:primary_speciality] = clinician["pri_spec"]
                new_clinician_hash[:secondary_speciality_1] = clinician["sec_spec_1"]
                new_clinician_hash[:secondary_speciality_2] = clinician["sec_spec_2"]
                new_clinician_hash[:secondary_speciality_3] = clinician["sec_spec_3"]
                new_clinician_hash[:secondary_speciality_4] = clinician["sec_spec_4"]
    
                Clinician.find_or_create_by!(new_clinician_hash)
            end
        end
    end

    def bulk_delete
        file = params[:file]
        return redirect_to services_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            Provider.destroy(row["provider_id"])
        end
        redirect_to providers_path, notice: "Providers Deleted"
    end

    private
    
    def clinician_params
        new_clinician = params.require(:clinician).permit(
            :suffix, 
            :first_name, 
            :middle_name, 
            :last_name, 
            :credential, 
            :medical_school, 
            :graduation_year, 
            :primary_speciality, 
            :secondary_speciality_1, 
            :secondary_speciality_2, 
            :secondary_speciality_3, 
            :secondary_speciality_4, 
            :npi, 
            :ind_PAC_ID,
            :organization_id)
    end
end