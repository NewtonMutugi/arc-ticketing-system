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
end
