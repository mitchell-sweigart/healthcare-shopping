class Clinician < ApplicationRecord
    has_many :utilizations
    belongs_to :organization, optional: true
    has_and_belongs_to_many :facilities
    has_and_belongs_to_many :organizations
    has_many :negotiated_rates

    validates_uniqueness_of :npi

    def proper_name()
        if self.credential.present?
            return self.suffix + " " + self.first_name + " " +  self.middle_name + " " +  self.last_name + ", " +  self.credential + "."
        else
            return self.suffix + " " + self.first_name + " " +  self.middle_name + " " +  self.last_name + " " +  self.credential
        end
    end

    def specialties()
        if self.secondary_speciality_1.present?
            return "Primary Speciality: " + self.primary_speciality + " Seconary Specialty: " + self.secondary_speciality_1 + " " + self.secondary_speciality_2 + " " + self.secondary_speciality_3 + " " + self.secondary_speciality_4
        else
            return "Primary Speciality: " + self.primary_speciality + " " + self.secondary_speciality_1 + " " + self.secondary_speciality_2 + " " + self.secondary_speciality_3 + " " + self.secondary_speciality_4
        end
    end
end
