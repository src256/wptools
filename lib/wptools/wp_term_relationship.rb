require 'active_record'

module Wptools
  # +------------------+---------------------+------+-----+---------+-------+
  # | Field            | Type                | Null | Key | Default | Extra |
  # +------------------+---------------------+------+-----+---------+-------+
  # | object_id        | bigint(20) unsigned | NO   | PRI | 0       |       |
  # | term_taxonomy_id | bigint(20) unsigned | NO   | PRI | 0       |       |
  # | term_order       | int(11)             | NO   |     | 0       |       |
  # +------------------+---------------------+------+-----+---------+-------+
  #  object_idとterm_taxonomy_idの組み合わせが主キー
  #
  class WpTermRelationship < ActiveRecord::Base
    self.primary_key = 'term_taxonomy_id'
    belongs_to :wp_post, foreign_key: :object_id
    belongs_to :wp_term_taxonomy, foreign_key: :term_taxonomy_id
  end

end