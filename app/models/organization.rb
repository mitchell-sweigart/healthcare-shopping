class Organization < ApplicationRecord
    has_many :clinicians
    has_many :ratings
end