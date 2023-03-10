class ServicesController < ApplicationController
    require "csv"

    def index
        @insurance_carrier = params[:query_4]
        sort_order = params[:query_5]
        if sort_order == "1"
            @services = Service.joins(:code).where(["code LIKE :code AND description like :description AND plain_language_description like :plain_language_description", { :code => "%#{params[:query]}%", :description => "%#{params[:query_2]}%", :plain_language_description => "%#{params[:query_3]}%"}]).order(:self_pay_cash_price)
        else 
            @services = Service.joins(:code).where(["code LIKE :code AND description like :description AND plain_language_description like :plain_language_description", { :code => "%#{params[:query]}%", :description => "%#{params[:query_2]}%", :plain_language_description => "%#{params[:query_3]}%"}]).order(self_pay_cash_price: :desc)
        end

        array = []

        @services.each do |service|
            if service.insurance_rate(@insurance_carrier) > 0
                array.append(service.insurance_rate(@insurance_carrier))
            else
                next
            end
        end

        def median(array)
            return nil if array.empty?
            sorted = array.sort
            len = sorted.length
            (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
        end

        @mean = array.sum(0.0) / array.size
        @sum = array.sum(0.0) { |element| (element - @mean) ** 2 }
        @variance = @sum / (array.size - 1)
        @standard_deviation = Math.sqrt(@variance)
        quarter_standard_deviation = @standard_deviation / 4
        services_median = median(array)
        @benchmark = services_median ##- quarter_standard_deviation

    end

    def new
        @service = Service.new
        @facilities = Facility.all
    end

    def create
        @service = Service.create(service_params)
        if @service.save
            redirect_to '/services'
        else
            redirect_to '/service/new'
        end
    end

    def edit
        @service = Service.find(params[:id])
    end

    def show
        @service = Service.find(params[:id])
    end

    def destroy
        Service.destroy(params[:id])
        redirect_to '/services'
    end

    def update
        @service = Service.find(params[:id])
        if @service.update(params.require(:service).permit(
            :gross_charge, 
            :self_pay_cash_price, 
            :aetna_commercial, 
            :aetna_asa, 
            :cbc_commercial, 
            :cigna,
            :geisinger_commercial,
            :highmark_choice_blue,
            :highmark_commercial,
            :multiplan,
            :uhc_commercial,
            :upmc_commercial,
            :wellspan,
            :facility_id,
            :code_id
            ))
          flash.notice = "Service successfully updated!"
          redirect_to '/services'
        else
          flash.notice = "Service unsuccessfully update!"
        end
    end

    def import
        file = params[:file]
        return redirect_to services_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            service_hash = {}
            service_hash[:gross_charge] = row["gross_charge"].to_f
            service_hash[:self_pay_cash_price] = row["self_pay_cash_price"].to_f
            service_hash[:aetna_commercial] = row["aetna_commercial"].to_f
            service_hash[:aetna_asa] = row["aetna_asa"].to_f
            service_hash[:cbc_commercial] = row["cbc_commercial"].to_f
            service_hash[:cigna] = row["cigna"].to_f
            service_hash[:geisinger_commercial] = row["geisinger_commercial"].to_f
            service_hash[:highmark_choice_blue] = row["highmark_choice_blue"].to_f
            service_hash[:highmark_commercial] = row["highmark_commercial"].to_f
            service_hash[:multiplan] = row["multiplan"].to_f
            service_hash[:uhc_commercial] = row["uhc_commercial"].to_f
            service_hash[:upmc_commercial] = row["upmc_commercial"].to_f
            service_hash[:wellspan] = row["wellspan"].to_f
            service_hash[:facility_id] = row["facility_id"]
            service_hash[:code_id] = row["code_id"]
            Service.create(service_hash)
        end
        redirect_to services_path, notice: "Services Imported!"
    end

    def bulk_delete
        file = params[:file]
        return redirect_to services_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            Service.destroy(row["service_id"])
        end
        redirect_to services_path, notice: "Services Deleted"
    end

    private
    
    def service_params
        new_service = params.require(:service).permit(
            :gross_charge, 
            :self_pay_cash_price, 
            :aetna_commercial, 
            :aetna_asa, 
            :cbc_commercial, 
            :cigna,
            :geisinger_commercial,
            :highmark_choice_blue,
            :highmark_commercial,
            :multiplan,
            :uhc_commercial,
            :upmc_commercial,
            :wellspan,
            :facility_id,
            :code_id
            )
    end

end
