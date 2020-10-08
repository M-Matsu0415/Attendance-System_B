class Base < ApplicationRecord
  validates :name, presence: true, length: { maximum: 10 }
  validates :number, presence: true, length: { maximum: 5 }
end
