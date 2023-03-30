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

    def reward(benchmark)
        if self.negotiated_rate < benchmark && benchmark <= 500
            array = [150]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        elsif self.negotiated_rate < benchmark && benchmark <= 1000
            array = [300]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        elsif self.negotiated_rate < benchmark && benchmark <= 1500
            array = [450]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        elsif self.negotiated_rate < benchmark && benchmark <= 2000
            array = [600]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        elsif self.negotiated_rate < benchmark && benchmark <= 3000
            array = [900]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        elsif self.negotiated_rate < benchmark && benchmark <= 4000
            array = [1200]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        elsif self.negotiated_rate < benchmark && benchmark <= 5000
            array = [1500]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        elsif self.negotiated_rate < benchmark && benchmark > 5000
            array = [1800]
            array.push((benchmark - self.negotiated_rate)* 0.5)
            return array.min()
        else self.negotiated_rate >= benchmark
            return 0
        end
    end
end