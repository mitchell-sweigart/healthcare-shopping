class Code < ApplicationRecord
    has_many :services
    has_many :negotiated_rates


    def concise_description()
        description = ""
        if self.plain_language_description == "No Plain Language Description" || self.plain_language_description == "N/A"
            description = self.description
        elsif self.plain_language_description != "No Plain Language Description" || self.plain_language_description != "N/A"
            description = self.description + " " + self.plain_language_description
        else
            description = ""
        end
        return description
    end
end