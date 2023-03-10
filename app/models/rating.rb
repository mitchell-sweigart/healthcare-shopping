class Rating < ApplicationRecord
    belongs_to :facility , optional: true
    belongs_to :organization , optional: true
end
