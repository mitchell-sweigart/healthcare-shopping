class Service < ApplicationRecord
    belongs_to :facility , optional: true
    belongs_to :code

    def insurance_rate(thing)
        rate = 0.0
        if thing == "Aetna Commercial"
            rate = self.aetna_commercial
        elsif thing == "Aetna ASA"
            rate = self.aetna_asa
        elsif thing == "Capital Blue Cross Commercial"
            rate = self.cbc_commercial
        elsif thing == "Cigna"
            rate = self.cigna
        elsif thing == "Geisinger Commercial"
            rate = self.geisinger_commercial
        elsif thing == "Highmark Blue Cross Commercial"
            rate = self.highmark_commercial
        elsif thing == "Highmark Blue Choice"
            rate = self.highmark_choice_blue
        elsif thing == "Multiplan"
            rate = self.multiplan
        elsif thing == "UHC Commercial"
            rate = self.uhc_commercial
        elsif thing == "UPMC Commercial"
            rate = self.upmc_commercial
        elsif thing == "Wellspan"
            rate = self.wellspan
        end
        return rate
    end
end