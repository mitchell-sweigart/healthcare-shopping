class TimelyAndEffectiveCareRatingsController < ApplicationController
    require "csv"

    def index
        @timely_and_effective_care_ratings = TimelyAndEffectiveCareRating.where("condition LIKE ?", "%#{params[:q]}%")
    end

    def new
        @timely_and_effective_care_rating = TimelyAndEffectiveCareRating.new
        @facilities = Facility.all
    end

    def create
        @timely_and_effective_care_rating = TimelyAndEffectiveCareRating.create(timely_and_effective_care_rating_params)
        if @timely_and_effective_care_rating.save
            redirect_to '/timely_and_effective_care_ratings'
        else
            redirect_to '/timely_and_effective_care_ratings/new'
        end
    end

    def edit
        @timely_and_effective_care_rating = TimelyAndEffectiveCareRating.find(params[:id])
    end

    def show
        @timely_and_effective_care_rating = TimelyAndEffectiveCareRating.find(params[:id])
    end

    def destroy
        @timely_and_effective_care_rating = TimelyAndEffectiveCareRating.find(params[:id])
        if @timely_and_effective_care_rating.destroy
        redirect_to timely_and_effective_care_ratings_path, notice: "Timely & Effective Care Rating has been deleted successfully"
        end
    end

    def update
        @timely_and_effective_care_rating = TimelyAndEffectiveCareRating.find(params[:id])
        if @timely_and_effective_care_rating.update(params.require(:timely_and_effective_care_rating).permit(
            :condition, 
            :measure_id, 
            :measure_name, 
            :score,
            :sample, 
            :facility_id
            ))
          flash.notice = "Rating successfully updated!"
          redirect_to '/timely_and_effective_care_ratings'
        else
          flash.notice = "Rating unsuccessfully update!"
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
                rating_hash[:facility_id] = row["facility_id"]
                Rating.find_or_create_by!(rating_hash)
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
            TimelyAndEffectiveCareRating.destroy(row["rating_id"])
        end
        redirect_to ratings_path, notice: "Ratings Deleted"
    end

    private
    
    def timely_and_effective_care_rating_params
        new_timely_and_effective_care_rating = params.require(:timely_and_effective_care_rating).permit(
            :condition, 
            :measure_id, 
            :measure_name, 
            :score,
            :sample, 
            :facility_id
            )
    end
end