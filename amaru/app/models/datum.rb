class Datum
  include Mongoid::Document
  after_save :update_group_fields

  field :capture_date,         type: Time
  field :_id, type Time, default: ->{ capture_date }

  belongs_to :platform
  belongs_to :group
  belongs_to :command

  validates_uniqueness_of :capture_date

  index({ capture_date: 1 }, { unique: true })

  scope :captured_between,  ->(starts_at, ends_at) {
    unless starts_at.nil? and ends_at.nil?
      data = self
      unless starts_at.nil?
        data = data.where(:capture_date.gte => starts_at)
      end
      unless ends_at.nil?
        data = data.where(:capture_date.lte => ends_at)
      end

      data
    else 
      where(:capture_date.lte => Time.zone.now)
    end
  }

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
    return true
  end
end
