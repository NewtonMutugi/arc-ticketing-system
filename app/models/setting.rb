class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.mpesa_mode
    find_by(key: "mpesa_mode")&.value || "automated"
  end

  def self.mpesa_mode=(mode)
    setting = find_or_initialize_by(key: "mpesa_mode")
    setting.value = mode
    setting.save!
  end
  def self.mpesa_business_number
    find_by(key: "mpesa_business_number")&.value || "123456"
  end

  def self.mpesa_business_number=(number)
    setting = find_or_initialize_by(key: "mpesa_business_number")
    setting.value = number
    setting.save!
  end

  def self.session_timeout
    find_by(key: "session_timeout")&.value || "120"
  end

  def self.session_timeout=(timeout)
    setting = find_or_initialize_by(key: "session_timeout")
    setting.value = timeout.to_s
    setting.save!
  end
end
