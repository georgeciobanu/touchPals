class Report < ActiveRecord::Base
  attr_accessible :reportee_id, :reporter_id
  belongs_to :reporter, :class_name => 'User', :foreign_key => :reporter_id
  belongs_to :reportee, :class_name => 'User', :foreign_key => :reportee_id
end
