class NegotiatedRatesController < ApplicationController
    require "csv"
    require "httparty"
    require "json"
    require "open-uri"
    require "./lib/functions.rb"
    extend HelpfulFunctions
    require "./lib/math_functions"
    extend MathFunctions

    def index
        code = params[:query]
        health_plan_id = params[:query_2]
        distance_filter = params[:query_3]
        sort_order = params[:query_5]
        negotiated_rates = NegotiatedRate.where(["billing_code LIKE :code AND health_plan_id LIKE :health_plan_id", {:code => params[:query], :health_plan_id => health_plan_id}]).where(billing_code_modifier: nil).or(NegotiatedRate.where(["billing_code LIKE :code AND health_plan_id LIKE :health_plan_id", {:code => params[:query], :health_plan_id => health_plan_id}]).where.not(billing_code_modifier: ["['52']","['53']","['73']","['74']","['78']","['78','79']","['52', 'PT']","['59']","['GC']","['82', 'AS']","['AS']","['80']","['82']"]))
        negotiated_rates.each do |negotiated_rates|
            if negotiated_rates.billing_class == "professional"
                negotiated_rates[:effective_npi] = negotiated_rates.tin
            elsif negotiated_rates.billing_class == "institutional"
                negotiated_rates[:effective_npi] = negotiated_rates.npi
            else
                next
            end
        end

        @unique_neogtiated_rates = negotiated_rates.uniq { |negotiated_rate| [negotiated_rate.effective_npi] }

        nrwd = []

        @unique_neogtiated_rates.each do |unique_negotiated_rate|
            rate_array = []
            negotiated_rates.each do |negotiated_rate|
                if unique_negotiated_rate.npi == negotiated_rate.npi
                    rate_array.append(negotiated_rate.negotiated_rate)
                else
                    next
                end
            end
            mean_rate = rate_array.sum(0.0) / rate_array.size
            unique_negotiated_rate[:negotiated_rate] = mean_rate
            unique_negotiated_rate[:billing_code_modifier] = nil
        end

        latitude = Rails.env.production? ? request.location.latitude : 40.039398
        longitude = Rails.env.production? ? request.location.longitude : -76.307083

        @unique_neogtiated_rates.each do |negotiated_rate|
            if negotiated_rate.facility.locations.first.latitude != nil
                facility_lat = negotiated_rate.facility.locations.first.latitude
                facility_lon = negotiated_rate.facility.locations.first.longitude
                api_key = ENV["google_maps_api_key"]
                google_maps_direction_api = "https://maps.googleapis.com/maps/api/directions/json?origin=#{latitude},#{longitude}&destination=#{facility_lat},#{facility_lon}&key=#{api_key}"
                direction_data_raw = URI.open(google_maps_direction_api).read
                direction_data_hash = JSON.parse(direction_data_raw)
                distance_to_travel = direction_data_hash["routes"][0]["legs"][0]["distance"]["text"]
                distance_to_travel_num = distance_to_travel.sub("mi","").to_f
                puts distance_to_travel_num
                #conditionally push depending on distance
                if distance_filter == "1" && distance_to_travel_num <= 35
                    nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                elsif distance_filter == "2" && distance_to_travel_num <= 45
                    nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                elsif distance_filter == "3" && distance_to_travel_num <= 60
                    nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                elsif distance_filter == "4"
                    nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                else
                    next
                end
            else
                puts "Negotiated Rate Facility - #{negotiated_rate.facility.name} - doesn't have lat/long coordinates. Facility ID: #{negotiated_rate.facility.id}"
            end
        end

        @size_nrwd = nrwd.size
        @mean_nrwd = nrwd.sum(0.0) { |nr| nr[:negotiated_rate].negotiated_rate } / (@size_nrwd > 0 ? @size_nrwd : 1)
        @sum_nrwd = nrwd.sum(0.0) { |nr| (nr[:negotiated_rate].negotiated_rate - @mean_nrwd) ** 2 }
        variance_nrwd = @sum_nrwd / ((@size_nrwd > 0 ? @size_nrwd : 1) - 1)
        @standard_deviation_nrwd = Math.sqrt(variance_nrwd)

        arry_without_outliers = []

        nrwd.each do |nr|
            rate = nr[:negotiated_rate].negotiated_rate
            if rate < (@mean_nrwd + (3 * @standard_deviation_nrwd))
                arry_without_outliers.push(rate) 
            else
                next
            end
        end

        @mean = arry_without_outliers.sum(0.0) / arry_without_outliers.size
        sum = arry_without_outliers.sum(0.0) { |element| (element - @mean) ** 2 }
        variance = sum / (arry_without_outliers.size - 1)
        @standard_deviation = Math.sqrt(variance)
        @quarter_standard_deviation = @standard_deviation / 4
        @services_median = MathFunctions.median(arry_without_outliers)
        @high_number = arry_without_outliers.sort.last

        if arry_without_outliers.length() > 0
            @benchmark = @services_median - @quarter_standard_deviation
        else 
            @benchmark = 0
        end

        nrwd.each do |nr|
            nr[:reward] = nr[:negotiated_rate].reward(@benchmark)
        end

        if sort_order == "1"
            return @negotiated_rates_with_distance = nrwd.sort_by {|h| h[:negotiated_rate][:negotiated_rate]}
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
        file.tempfile.binmode
        file.tempfile = Base64.encode64(file.tempfile.read)

        Resque.enqueue(ImportNegotiatedRatesFromCsvJob, params)  
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