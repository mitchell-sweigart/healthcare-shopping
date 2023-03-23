class Organization < ApplicationRecord
    has_and_belongs_to_many :clinicians
    has_many :ratings
end