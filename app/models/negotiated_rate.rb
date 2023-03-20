class NegotiatedRate < ApplicationRecord
    belongs_to :facility, optional: true
    belongs_to :clinician, optional: true
    belongs_to :code, optional: true

    def affective_npi()
        if self.billing_class == "professional"
            return self.tin
        else
            return self.npi
        end
    end
end