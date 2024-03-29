class Code < ApplicationRecord
    has_many :services
    has_many :negotiated_rates


    def concise_description()
        if self.plain_language_description.empty? && self.description.present?
            return self.description
        elsif self.plain_language_description == "No Plain Language Description" || self.plain_language_description == "N/A"
            return self.description
        elsif self.plain_language_description != "No Plain Language Description" || self.plain_language_description != "N/A"
            return self.description.to_s + " " + self.plain_language_description.to_s
        else
            return ""
        end
    end
end