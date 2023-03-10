class HealthPlanNetworksController < ApplicationController
    require "csv"

    def index
        @health_plan_networks = HealthPlanNetwork.all
    end

    def new
        @health_plan_network = HealthPlanNetwork.new

    end

    def create
        @health_plan_network = HealthPlanNetwork.create(health_plan_network_params)
        if @health_plan_network.save
            redirect_to '/health_plan_networks'
        else
            redirect_to '/health_plan_network/new'
        end
    end

    def edit
        @health_plan_network = HealthPlanNetwork.find(params[:id])
    end

    def show
        @health_plan_network = HealthPlanNetwork.find(params[:id])
    end

    def destroy
        HealthPlanNetwork.destroy(params[:id])
        redirect_to '/health_plan_netowrks'
    end

    def update
        @health_plan_network = HealthPlanNetwork.find(params[:id])
        if @health_plan_network.update(params.require(:health_plan_network).permit(
            :name, 

            ))
          flash.notice = "Health Plan Network successfully updated!"
          redirect_to '/health_plan_networks'
        else
          flash.notice = "Health Plan Network unsuccessfully update!"
        end
    end

    def import
        file = params[:file]
        return redirect_to ratings_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            rating_hash = {}
            if row["star_value"].to_i > 0
                rating_hash[:measure_cd] = row["measure_cd"]
                rating_hash[:measure_title] = row["measure_title"]
                rating_hash[:star_value] = row["star_value"]
                rating_hash[:provider_id] = row["provider_id"]
                HealthPlanNetwork.find_or_create_by!(rating_hash)
            else
                next
            end
        end
        redirect_to ratings_path, notice: "Ratings Imported!"
    end

    def bulk_delete
        file = params[:file]
        return redirect_to ratings_path, notice: "Only CSV Please" unless file.content_type == "text/csv"
        file_open = File.open(file)
        csv = CSV.parse(file_open, headers: true, col_sep: ',')
        csv.each do |row|
            HealthPlanNetwork.destroy(row["rating_id"])
        end
        redirect_to ratings_path, notice: "Health Plan Networks Deleted"
    end

    private
    
    def health_plan_network_params
        new_rating = params.require(:health_plan_network).permit(
            :name
            )
    end
end
