class Transaction < ApplicationRecord
  belongs_to :event
  belongs_to :referenceable, polymorphic: true
end
