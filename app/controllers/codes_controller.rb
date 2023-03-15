class CodesController < ApplicationController
    require "csv"

    def index
        @codes = Code.all
        respond_to do |format|
            format.html
            format.csv
        end
    end

    def new
        @code = Code.new
        @providers = Provider.all
    end

    def create
        @code = Code.create(code_params)
        if @code.save
            redirect_to '/codes'
        else
            redirect_to '/code/new'
        end
    end

    def edit
        @code = Code.find(params[:id])
    end

    def show
        @code = Code.find(params[:id])
    end

    def destroy
        Code.destroy(params[:id])
        redirect_to '/codes'
    end

    def update
        @code = Code.find(params[:id])
        if @code.update(params.require(:code).permit(
            :code, 
            :description, 
            :plain_language_description, 
            :benchmark_cost
            ))
          flash.notice = "Code successfully updated!"
          redirect_to '/codes'
        else
          flash.notice = "Code unsuccessfully update!"
        end
    end

    def import
        file = params[:file]
        return redirect_to codes_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            code_hash = {}
            code_hash[:code] = row["code"]
            code_hash[:description] = row["description"]
            code_hash[:plain_language_description] = row["plain_language_description"]
            code_hash[:benchmark_cost] = row["benchmark_cost"]
            Code.find_or_create_by!(code_hash)
        end
        redirect_to codes_path, notice: "Codes Imported!"
    end

    def bulk_update
        file = params[:file]
        return redirect_to codes_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            code = Code.find(row["code_id"])
            code_hash = {}
            code_hash[:code] = row["code"]
            code_hash[:description] = row["description"]
            code_hash[:plain_language_description] = row["plain_language_description"]
            code_hash[:benchmark_cost] = row["benchmark_cost"]
            code.update(code_hash)
        end
        redirect_to codes_path, notice: "Codes Imported!"
    end

    def bulk_delete
        file = params[:file]
        return redirect_to codes_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            Code.destroy(row["code_id"])
        end
        redirect_to codes_path, notice: "Codes Deleted"
    end

    private
    
    def code_params
        new_code = params.require(:code).permit(
            :code, 
            :description, 
            :plain_language_description, 
            :benchmark_cost
            )
    end

end