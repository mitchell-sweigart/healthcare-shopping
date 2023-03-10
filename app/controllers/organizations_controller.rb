class OrganizationsController < ApplicationController
    require "csv"
    require "httparty"
    require "json"
    require "open-uri"

    def index
        @organizations = Organization.where("name LIKE ?", "%#{params[:q]}%")
    end

    def new
        @organization = Organization.new
    end

    def create
        @organization = Organization.create(organization_params)
        if @organization.save
            redirect_to '/organizations'
        else
            redirect_to '/organization/new'
        end
    end

    def edit
        @organization = Organization.find(params[:id])
    end

    def show
        @organization = Organization.find(params[:id])
        @clinicians = Organization.find(params[:id]).clinicians

        pac_id = @organization.org_PAC_ID
        url = "https://data.cms.gov/provider-data/api/1/datastore/sql?query=%5BSELECT%20%2A%20FROM%20518920aa-a3e6-57b8-9599-a88f5d5f438e%5D%5BWHERE%20org_PAC_ID%20%3D%20%22#{pac_id}%22%5D&show_db_columns=true"

        ratings_raw = URI.open(url).read
        ratings_hash = JSON.parse(ratings_raw)

        ratings_hash.each do |rating|
            if rating["star_value"].to_i > 0
                rating_hash = {}
                rating_hash[:measure_cd] = rating["measure_cd"]
                rating_hash[:measure_title] = rating["measure_title"]
                rating_hash[:star_value] = rating["star_value"].to_i
                rating_hash[:organization_id] = @organization.id
                Rating.find_or_create_by!(rating_hash)
            else
                next
            end
        end

        @ratings = Organization.find(params[:id]).ratings

    end

    def destroy
        @organization = Organization.find(params[:id])
        if @organization.destroy
        redirect_to organizations_path, notice: "Organization has been deleted successfully"
        end
    end

    def update
        @organization = Organization.find(params[:id])
        if @organization.update(params.require(:organization).permit(:facility_id, :facility_type, :name, :npi, :org_PAC_ID, :address_line_one, :address_line_two, :address_city, :address_state, :address_zip_code))
            flash.notice = "Organization successfully updated!"
            redirect_to '/organizations'
        else
            flash.notice = "Organization unsuccessfully update!"
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
    
    def organization_params
        new_organization = params.require(:organization).permit(
            :name, 
            :org_PAC_ID, 
            :num_org_members, 
            :address_line_one, 
            :address_line_two, 
            :address_city, 
            :address_state, 
            :address_zip, 
            :phone_number)
    end

end