class RatingsController < ApplicationController
    require "csv"

    def index
        @ratings = Rating.where("measure_title LIKE ?", "%#{params[:q]}%")
    end

    def new
        @rating = Rating.new
        @facilities = Facility.all
    end

    def create
        @rating = Rating.create(rating_params)
        if @rating.save
            redirect_to '/ratings'
        else
            redirect_to '/rating/new'
        end
    end

    def edit
        @rating = Rating.find(params[:id])
    end

    def show
        @rating = Rating.find(params[:id])
    end

    def destroy
        Rating.destroy(params[:id])
        redirect_to '/ratings'
    end

    def update
        @rating = Rating.find(params[:id])
        if @rating.update(params.require(:rating).permit(
            :measure_cd, 
            :measure_title, 
            :star_value, 
            :facility_id
            ))
          flash.notice = "Rating successfully updated!"
          redirect_to '/ratings'
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
            Rating.destroy(row["rating_id"])
        end
        redirect_to ratings_path, notice: "Ratings Deleted"
    end

    private
    
    def rating_params
        new_rating = params.require(:rating).permit(
            :measure_cd, 
            :measure_title, 
            :star_value, 
            :facility_id
            )
    end
end
