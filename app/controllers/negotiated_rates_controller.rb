class NegotiatedRatesController < ApplicationController
    require "csv"

    def index
        code = params[:query]
        health_plan_id = params[:query_2]
        distance_filter = params[:query_3]
        sort_order = params[:query_5]
        #prohibited_billing_code_modifiers = ["['52']", "['53']", "['73']", "['74']"]
        @negotiated_rates = NegotiatedRate.where(["billing_code LIKE :code AND health_plan_id LIKE :health_plan_id", {:code => params[:query], :health_plan_id => health_plan_id}]).where(billing_code_modifier: nil).or(NegotiatedRate.where(["billing_code LIKE :code AND health_plan_id LIKE :health_plan_id", {:code => params[:query], :health_plan_id => health_plan_id}]).where.not(billing_code_modifier: ["['52']","['53']","['73']","['74']","['52', 'PT']","['59']"]))

        nrwd = []
        array = []

        def median(array)
            return nil if array.empty?
            sorted = array.sort
            len = sorted.length
            (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
        end

        if Rails.env.production?
            latitude = request.location.latitude
            longitude = request.location.longitude
            @negotiated_rates.each do |negotiated_rate|
                if negotiated_rate.facility.latitude != nil
                    facility_lat = negotiated_rate.facility.latitude
                    facility_lon = negotiated_rate.facility.longitude
                    google_maps_direction_api = "https://maps.googleapis.com/maps/api/directions/json?origin=#{latitude},#{longitude}&destination=#{facility_lat},#{facility_lon}&key=AIzaSyDSL85vkykDd8e2g7Z5mzd-zJvf779k0dM"
                    direction_data_raw = URI.open(google_maps_direction_api).read
                    direction_data_hash = JSON.parse(direction_data_raw)
                    distance_to_travel = direction_data_hash["routes"][0]["legs"][0]["distance"]["text"]
                    distance_to_travel_num = distance_to_travel.sub("mi","").to_f
                    #conditionally push depending on distance
                    if sort_order == "1" && distance_to_travel_num <= 45
                        array.push(negotiated_rate[:negotiated_rate])
                        nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                    elsif sort_order == "2" && distance_to_travel_num <= 60
                        array.push(negotiated_rate[:negotiated_rate])
                        nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                    elsif sort_order == "3"
                        array.push(negotiated_rate[:negotiated_rate])
                        nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                    else
                        next
                    end
                else
                    array.push(negotiated_rate[:negotiated_rate])
                    nrwd.push({negotiated_rate: negotiated_rate, distance: nil})
                end
            end
    
            mean = array.sum(0.0) / array.size
            sum = array.sum(0.0) { |element| (element - mean) ** 2 }
            variance = sum / (array.size - 1)
            standard_deviation = Math.sqrt(variance)
            quarter_standard_deviation = standard_deviation / 4
            @services_median = median(array)

            if array.length() > 0
                benchmark = @services_median - quarter_standard_deviation
            else 
                benchmark = 0
            end

            nrwd.each do |nr|
                nr[:reward] = benchmark - nr.negotiated_rate.negotiated_rate > 0 ? benchmark - nr.negotiated_rate.negotiated_rate : 0.00
            end

        else
            @negotiated_rates.each do |negotiated_rate|
                nrwd.push({negotiated_rate: negotiated_rate, distance: nil, reward: 0.00})
            end
        end

        if sort_order == "1"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:negotiated_rate].negotiated_rate}
        elsif sort_order == "2"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:negotiated_rate].negotiated_rate}.reverse!
        elsif sort_order == "3"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:negotiated_rate].facility.overall_rating}
        elsif sort_order == "4"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:negotiated_rate].facility.overall_rating}.reverse!
        elsif sort_order == "5"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:reward]}
        elsif sort_order == "6"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:reward]}
        elsif sort_order == "7"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:distance].sub("mi","").to_f}.reverse!
        elsif sort_order == "8"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:distance].sub("mi","").to_f}
        end  
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
            :clinician_id,
            :code_id,
            :health_plan_id
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
            negotiated_rate_hash[:health_plan_id] = row["health_plan_id"].to_i

            code = Code.find_by(code: row["billing_code"])

            negotiated_rate_hash[:code_id] = code.id

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
            :clinician_id,
            :code_id,
            :health_plan_id
            )
    end  
end