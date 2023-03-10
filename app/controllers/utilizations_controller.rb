class UtilizationsController < ApplicationController
    require "csv"
    require "httparty"
    require "json"
    require "open-uri"

    def index
        @utilizations = Utilization.where("hcpcs_code LIKE ?", "%#{params[:q]}%")
    end

    def new
        @utilization = Utilization.new
    end

    def create
        @utilization = Utilization.create(utilization_params)
        if @utilization.save
            redirect_to '/utilizations'
        else
            redirect_to '/utilizations/new'
        end
    end

    def edit
        @utilization = Utilization.find(params[:id])
    end

    def show
        @utilization = Utilization.find(params[:id])
    end

    def destroy
        @utilization = Utilization.find(params[:id])
        if @utilization.destroy
        redirect_to utilizations_path, notice: "Utilization has been deleted successfully"
        end
    end

    def update
        @utilization = Utilization.find(params[:id])
        if @utilization.update(params.require(:utilization).permit(:hcpcs_code, :hcpcs_description, :service_count, :beneficiary_count, :clinician_id))
            flash.notice = "Utilization successfully updated!"
            redirect_to '/utilizations'
        else
            flash.notice = "Utilization unsuccessfully update!"
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
            Utilization.find_or_create_by!(provider_hash)
        end
        redirect_to providers_path, notice: "Providers Imported!"
    end

    def bulk_delete
        file = params[:file]
        return redirect_to services_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            Utilization.destroy(row["provider_id"])
        end
        redirect_to providers_path, notice: "Providers Deleted"
    end

    private
    
    def utilization_params
        new_utilization = params.require(:utilization).permit(:hcpcs_code, :hcpcs_description, :service_count, :beneficiary_count, :clinician_id)
    end
end