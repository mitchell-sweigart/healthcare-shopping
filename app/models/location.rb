class Location < ApplicationRecord
    belongs_to :facility

    def address()
        if self.address_2 != ""
            return self.address_1.titleize + " " + self.address_2.titleize + " " + self.city.titleize +  " " + self.state +  " " + self.postal_code.to_s
        else
            return self.address_1.titleize + " " + self.city.titleize +  " " + self.state +  " " + self.postal_code.to_s
        end
    end
end