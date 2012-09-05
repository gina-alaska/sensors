  class ProcessedDatum < Datum
    after_save :update_group_fields

    belongs_to :group

    def update_group_fields
      unless self.group.nil?
        fields = self.attributes.keys - self.fields.collect{|k,f| k}
        group_cache = self.group
        fields.each do |f|
          s = group_cache.sensors.where(source_field: f).first
          next unless s.nil?
          group_cache.sensors.create({ source_field: f, label: f })
        end
      end
    end
  end
