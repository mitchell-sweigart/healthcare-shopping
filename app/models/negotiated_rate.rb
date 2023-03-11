class NegotiatedRate < ApplicationRecord
    belongs_to :facility, optional: true
    belongs_to :clinician, optional: true
    belongs_to :code, optional: true
end