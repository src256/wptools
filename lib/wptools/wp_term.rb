module Wptools
  # +------------+---------------------+------+-----+---------+----------------+
  # | Field      | Type                | Null | Key | Default | Extra          |
  # +------------+---------------------+------+-----+---------+----------------+
  # | term_id    | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
  # | name       | varchar(200)        | NO   | MUL |         |                |
  # | slug       | varchar(200)        | NO   | UNI |         |                |
  # | term_group | bigint(10)          | NO   |     | 0       |                |
  # +------------+---------------------+------+-----+---------+----------------+
  #
  # タグやカテゴリーの情報が保存されている
  #
  class WpTerm < ActiveRecord::Base
    self.primary_key = 'term_id'
    has_one :wp_term_taxonomy, foreign_key: :term_id
    has_many :wp_term_relationships, through: :wp_term_taxonomy
    has_many :wp_posts, through: :wp_term_relationships
  end
end