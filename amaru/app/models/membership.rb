class Membership
  include Mongoid::Document

  field :admin, type: Boolean, default: false

  belongs_to :user
  belongs_to :organization
end