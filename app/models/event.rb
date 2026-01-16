class Event < ApplicationRecord
  has_many :tickets, dependent: :destroy
end
