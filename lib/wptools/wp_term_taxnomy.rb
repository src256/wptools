require 'active_record'

module Wptools
  class WpTermTaxnomy < ActiveRecord::Base
    self.table_name = 'wp_term_taxonomy'
    has_many :wp_terms, foreign_key: :term_id
    has_many :wp_term_relationships, foreign_key: :term_taxonomy_id
    has_many :wp_posts, through: :wp_term_relationships

    scope :tags, -> { where(taxonomy: 'post_tag') }
    scope :categories, -> { where(taxonomy: 'category') }

    def list
      wp_terms.map { |wp_term| { wp_term.slug => wp_term.name } }.flatten
    end
  end
end