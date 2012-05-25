  class Sensors::ProcessedDatum
    include Mongoid::Document

    field :capture_date,         type: DateTime

    validates_uniqueness_of :capture_date

    belongs_to :platform,       :class_name => "Sensors::Platform"
    index :capture_date
  end
