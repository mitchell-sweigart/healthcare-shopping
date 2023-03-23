class NegotiatedRatesController < ApplicationController
    require "csv"
    require "httparty"
    require "json"
    require "open-uri"
    require "./lib/functions.rb"
    extend HelpfulFunctions

    def index
        code = params[:query]
        health_plan_id = params[:query_2]
        distance_filter = params[:query_3]
        sort_order = params[:query_5]
        #prohibited_billing_code_modifiers = ["['52']", "['53']", "['73']", "['74']", "['78']"]
        @negotiated_rates = NegotiatedRate.where(["billing_code LIKE :code AND health_plan_id LIKE :health_plan_id", {:code => params[:query], :health_plan_id => health_plan_id}]).where(billing_code_modifier: nil).or(NegotiatedRate.where(["billing_code LIKE :code AND health_plan_id LIKE :health_plan_id", {:code => params[:query], :health_plan_id => health_plan_id}]).where.not(billing_code_modifier: ["['52']","['53']","['73']","['74']","['78']","['78','79']","['52', 'PT']","['59']","['GC']"]))
        @negotiated_rates.each do |negotiated_rates|
            if negotiated_rates.billing_class == "professional"
                negotiated_rates[:effective_npi] = negotiated_rates.tin
            elsif negotiated_rates.billing_class == "institutional"
                negotiated_rates[:effective_npi] = negotiated_rates.npi
            else
                next
            end
        end
        @unique_neogtiated_rates = @negotiated_rates.uniq { |negotiated_rate| [negotiated_rate.effective_npi] }

        nrwd = []
        @array = []

        def median(array)
            return nil if array.empty?
            sorted = array.sort
            len = sorted.length
            (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
        end

        latitude = request.location.latitude
        longitude = request.location.longitude
        @unique_neogtiated_rates.each do |unique_negotiated_rate|
            rate_array = []
            @negotiated_rates.each do |negotiated_rate|
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

        if Rails.env.production?

            @unique_neogtiated_rates.each do |negotiated_rate|
                if negotiated_rate.facility.locations.first.latitude != nil
                    facility_lat = negotiated_rate.facility.locations.first.latitude
                    facility_lon = negotiated_rate.facility.locations.first.longitude
                    google_maps_direction_api = "https://maps.googleapis.com/maps/api/directions/json?origin=#{latitude},#{longitude}&destination=#{facility_lat},#{facility_lon}&key=AIzaSyDSL85vkykDd8e2g7Z5mzd-zJvf779k0dM"
                    direction_data_raw = URI.open(google_maps_direction_api).read
                    direction_data_hash = JSON.parse(direction_data_raw)
                    distance_to_travel = direction_data_hash["routes"][0]["legs"][0]["distance"]["text"]
                    distance_to_travel_num = distance_to_travel.sub("mi","").to_f
                    #conditionally push depending on distance
                    if distance_filter == "1" && distance_to_travel_num <= 45
                        @array.push(negotiated_rate[:negotiated_rate])
                        nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                    elsif distance_filter == "2" && distance_to_travel_num <= 60
                        @array.push(negotiated_rate[:negotiated_rate])
                        nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                    elsif distance_filter == "3"
                        @array.push(negotiated_rate[:negotiated_rate])
                        nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                    elsif distance_filter == "4" && distance_to_travel_num <= 35
                        @array.push(negotiated_rate[:negotiated_rate])
                        nrwd.push({negotiated_rate: negotiated_rate, distance: distance_to_travel})
                    else
                        next
                    end
                else
                    @array.push(negotiated_rate[:negotiated_rate])
                    nrwd.push({negotiated_rate: negotiated_rate, distance: nil})
                end
            end

            arry_without_outliers = []

            mean = @array.sum(0.0) / @array.size
            sum = @array.sum(0.0) { |element| (element - mean) ** 2 }
            variance = sum / (@array.size - 1)
            standard_deviation = Math.sqrt(variance)

            @array.each do |rate|
                if rate < (mean + (3 * standard_deviation))
                    arry_without_outliers.push(rate) 
                else
                    next
                end
            end
    
            mean = arry_without_outliers.sum(0.0) / arry_without_outliers.size
            sum = arry_without_outliers.sum(0.0) { |element| (element - mean) ** 2 }
            variance = sum / (arry_without_outliers.size - 1)
            standard_deviation = Math.sqrt(variance)
            quarter_standard_deviation = standard_deviation / 4
            @services_median = median(arry_without_outliers)

            if arry_without_outliers.length() > 0
                benchmark = @services_median - quarter_standard_deviation
            else 
                benchmark = 0
            end

            nrwd.each do |nr|
                nr[:reward] = benchmark - nr[:negotiated_rate].negotiated_rate > 0 ? benchmark - nr[:negotiated_rate].negotiated_rate : 0.00
            end

        else

            @unique_neogtiated_rates.each do |negotiated_rate|
                @array.push(negotiated_rate[:negotiated_rate])
            end

            @mean = @array.sum(0.0) / @array.size
            sum = @array.sum(0.0) { |element| (element - @mean) ** 2 }
            variance = sum / (@array.size - 1)
            @standard_deviation = Math.sqrt(variance)

            @arry_without_outliers = []

            @array.each do |rate|
                if rate < (@mean + (3 * @standard_deviation))
                    @arry_without_outliers.push(rate) 
                else
                    next
                end
            end

            @mean = @arry_without_outliers.sum(0.0) / @arry_without_outliers.size
            sum = @arry_without_outliers.sum(0.0) { |element| (element - @mean) ** 2 }
            variance = sum / (@arry_without_outliers.size - 1)
            @standard_deviation = Math.sqrt(variance)
            @quarter_standard_deviation = @standard_deviation / 4
            @one_eighth_standard_deviation = @standard_deviation / 8
            @services_median = median(@arry_without_outliers)

            if @arry_without_outliers.length() > 0
                @benchmark = @services_median - @one_eighth_standard_deviation
            else 
                @benchmark = 0
            end

            @unique_neogtiated_rates.each do |negotiated_rate|
                nrwd.push({negotiated_rate: negotiated_rate, distance: nil, reward: @benchmark - negotiated_rate.negotiated_rate > 0 ? @benchmark - negotiated_rate.negotiated_rate : 0.00})
            end
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
                    NegotiatedRatesController.create_facility_via_api_call(row["npi"])
                    facility = Facility.find_by(npi: row["npi"])
                end

            elsif row["billing_class"] == "professional" && row["tin_type"] == "npi"

                if Facility.exists?(npi: row["tin"])
                    facility = Facility.find_by(npi: row["tin"])
                else
                    NegotiatedRatesController.create_facility_via_api_call(row["tin"])
                    facility = Facility.find_by(npi: row["tin"])
                end

                if Clinician.exists?(npi: row["npi"])
                    clinician = Clinician.find_by(npi: row["npi"])
                else
                    NegotiatedRatesController.create_clinician_via_api_call(row["npi"])
                    clinician = Clinician.find_by(npi: row["npi"])
                end
            else
                break
            end

            if clinician.present? == false #not all NPIs are in the CMS API that we're hitting above and Institutional negotiated rates don't have a clincian association
                negotiated_rate_hash[:facility_id] = facility.id
                NegotiatedRate.find_or_create_by(negotiated_rate_hash)
            else
                negotiated_rate_hash[:facility_id] = facility.id
                negotiated_rate_hash[:clinician_id] = clinician.id
                NegotiatedRate.find_or_create_by(negotiated_rate_hash)
            end
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