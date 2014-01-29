class Membership
  include Mongoid::Document

  field :admin, type: Boolean, default: true

  belongs_to :user
  belongs_to :organization
end