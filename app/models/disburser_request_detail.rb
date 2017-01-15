class DisburserRequestDetail < ApplicationRecord
  belongs_to :disburser_request, required: false
  belongs_to :specimen_type
  validates_presence_of :quantity, :specimen_type_id
end