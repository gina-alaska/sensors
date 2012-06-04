  class RawDatum
    include Mongoid::Document

    field :capture_date,         type: DateTime

    validates_uniqueness_of :capture_date

    belongs_to :platform
    index :capture_date
  end
