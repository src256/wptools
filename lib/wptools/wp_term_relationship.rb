require 'active_record'

module Wptools
  class WpTermRelationship < ActiveRecord::Base
    belongs_to :wp_post, foreign_key: :object_id
    belongs_to :wp_term_taxonomy, foreign_key: :term_taxonomy_id
  end

end