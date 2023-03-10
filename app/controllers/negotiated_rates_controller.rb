class NegotiatedRatesController < ApplicationController
    require "csv"

    def index
        @insurance_carrier = params[:query_4]
        sort_order = params[:query_5]
        @negotiated_rates = NegotiatedRate.where("billing_code LIKE ?", "%#{params[:query]}%")

        @city = request.location.city
    end

    def new
        @negotiated_rate = NegotiatedRate.new
        @facilities = Facility.all
        @clinicians = Clinician.all
    end

    def create
        @negotiated_rate = NegotiatedRate.create(negotiated_rate_params)
        if @negotiated_rate.save
            redirect_to '/negotiated_rates'
        else
            redirect_to '/negotiated_rate/new'
        end
    end

    def edit
        @negotiated_rate = NegotiatedRate.find(params[:id])
    end

    def show
        @negotiated_rate = NegotiatedRate.find(params[:id])
    end

    def destroy
        NegotiatedRate.destroy(params[:id])
        redirect_to '/negotiated_rates'
    end

    def update
        @negotiated_rate = NegotiatedRate.find(params[:id])
        if @negotiated_rate.update(params.require(:negotiated_rate).permit(
            :billing_code, 
            :billing_code_type, 
            :negotiation_arrangement, 
            :negotiated_type, 
            :negotiated_rate, 
            :experation_date,
            :billing_class,
            :service_code,
            :billing_code_modifier,
            :tin,
            :tin_type,
            :npi,
            :facility_id,
            :clinician_id
            ))
            flash.notice = "Negotiated Rate successfully updated!"
            redirect_to '/negotiated_rates'
        else
            flash.notice = "Negotiated Rate unsuccessfully update!"
        end
    end

    def import

        file = params[:file]
        return redirect_to negotiated_rates_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
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

            facility = Facility.find_by(npi: row["npi"])
            clinician = Clinician.find_by(npi: row["npi"])

            if facility != nil
                negotiated_rate_hash[:facility_id] = facility.id
            elsif clinician != nil
                negotiated_rate_hash[:clinician_id] = clinician.id
            else
                next
            end   

            NegotiatedRate.create(negotiated_rate_hash)
        end
        redirect_to negotiated_rates_path, notice: "Negotiated Rates Imported!"
    end

    def bulk_delete
        file = params[:file]
        return redirect_to services_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            NegotiatedRate.destroy(row["negotiated_rate_id"])
        end
        redirect_to negotiated_rates_path, notice: "Negotiated Rates Deleted"
    end

    private
    
    def negotiated_rate_params
        new_negotiated_rate = params.require(:negotiated_rate).permit(
            :billing_code, 
            :billing_code_type, 
            :negotiation_arrangement, 
            :negotiated_type, 
            :negotiated_rate, 
            :experation_date,
            :billing_class,
            :service_code,
            :billing_code_modifier,
            :tin,
            :tin_type,
            :npi,
            :facility_id,
            :clinician_id
            )
    end  
end