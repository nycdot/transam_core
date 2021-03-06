class Message < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults
  after_create      :send_email

  # Associations
  belongs_to :organization
  belongs_to :user
  belongs_to :to_user, :class_name => 'User', :foreign_key => "to_user_id"
  belongs_to :priority_type
  has_many   :responses, :class_name => "Message", :foreign_key => "thread_message_id"

  # Has been tagged by the user
  has_many    :message_tags
  has_many    :users, :through => :message_tags

  # Validations on core attributes
  validates :organization_id,   :presence => true
  validates :user,              :presence => true
  validates :to_user,           :presence => true
  validates :priority_type_id,  :presence => true
  validates :subject,           :presence => true
  validates :body,              :presence => true

  default_scope { where(active: true).order('created_at DESC') }

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :organization_id,
    :user_id,
    :to_user_id,
    :thread_message_id,
    :priority_type_id,
    :subject,
    :body
  ]

  def self.allowable_params
    FORM_PARAMS
  end

  # Returns true if the user has tagged this order
  def tagged? user
    users.include? user
  end

  # Tags this message for the user
  def tag user
    unless tagged? user
      users << user
    end
  end

  # Recursively determine how many total responses there are to this thread
  def response_count
    sum = 0
    responses.each do |r|
      sum += 1
      sum += r.response_count
    end
    return sum
  end

  # Set resonable defaults for a new message
  def set_defaults
    self.active = self.active.nil? ? true : self.active
  end

  # If the to_user has elected to receive emails, send them upon message creation
  def send_email
    if to_user.notify_via_email
      Delayed::Job.enqueue SendMessageAsEmailJob.new(object_key), :priority => 0
    end
  end

end
