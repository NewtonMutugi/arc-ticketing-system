class Event < ApplicationRecord
  has_many :ticekts, dependent: destroy
end
