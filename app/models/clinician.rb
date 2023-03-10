class Clinician < ApplicationRecord
    has_many :utilizations
    belongs_to :organization, optional: true
    has_and_belongs_to_many :facilities
    has_many :negotiated_rates
end
