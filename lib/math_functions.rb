module MathFunctions
    def self.median(array)
        return nil if array.empty?
        sorted = array.sort
        len = sorted.length
        (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end
end