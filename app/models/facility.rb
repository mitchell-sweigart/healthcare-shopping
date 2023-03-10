class Facility < ApplicationRecord
    has_many :services
    has_many :timely_and_effective_care_ratings
    has_many :ratings
    has_and_belongs_to_many :clinicians
    has_many :negotiated_rates

    def address()
        return self.address_line_one + " " + self.address_city +  " " + self.address_state +  " " + self.address_zip_code
    end
end
