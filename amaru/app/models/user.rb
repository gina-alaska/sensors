class User
  include Mongoid::Document
  
  field :provider,       type: String
  field :uid,            type: String
  field :name,           type: String
  field :email,          type: String,  default: ''
  field :admin,          type: Boolean, default: false
  field :active,         type: Boolean, default: true
  field :access_token,   type: String
  
  attr_protected :provider, :uid, :name, :email, :admin
  
  has_and_belongs_to_many :organizations
  has_and_belongs_to_many :groups
  belongs_to :current_org, :class_name => 'Organization', :inverse_of => :current_users
  
  validates_uniqueness_of :name
  validates_uniqueness_of :email

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end      
    end
  end
end