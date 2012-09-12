class Organization
  include Mongoid::Document
  before_create :generate_access_token
  
  field :name,          type: String
  field :description,   type: String
  field :admin,         type: String
  field :access_token,  type: String
  
  has_many :current_users, :class_name => 'User', :inverse_of => :current_org
  has_and_belongs_to_many :users
  has_many :groups
  has_many :platforms

  validates_uniqueness_of :name

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.where(access_token: access_token).exists?
  end
end