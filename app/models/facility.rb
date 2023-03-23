class Facility < ApplicationRecord
    has_many :services
    has_many :timely_and_effective_care_ratings
    has_many :ratings
    has_and_belongs_to_many :clinicians
    has_many :negotiated_rates
    validates_uniqueness_of :npi

    has_many :identifiers
    has_many :locations
    has_many :taxonomies

    def consumer_name()
        if self.organization_dba_name.present?
            return self.organization_dba_name
        else
            return self.name
        end
    end
end
