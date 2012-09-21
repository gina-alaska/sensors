class Datum
  include Mongoid::Document

  field :capture_date,         type: Time

  belongs_to :platform
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
      where(:capture_date.lte => Time.now)
    end
  }
end
