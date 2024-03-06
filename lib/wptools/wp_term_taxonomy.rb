require 'active_record'

module Wptools
  # +------------------+---------------------+------+-----+---------+----------------+
  # | Field            | Type                | Null | Key | Default | Extra          |
  # +------------------+---------------------+------+-----+---------+----------------+
  # | term_taxonomy_id | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
  # | term_id          | bigint(20) unsigned | NO   | MUL | 0       |                |
  # | taxonomy         | varchar(32)         | NO   | MUL |         |                |
  # | description      | longtext            | NO   |     | NULL    |                |
  # | parent           | bigint(20) unsigned | NO   |     | 0       |                |
  # | count            | bigint(20)          | NO   |     | 0       |                |
  # +------------------+---------------------+------+-----+---------+----------------+
  #
  # サンプルデータ
  # +------------------+---------+---------------+-------------+--------+-------+
  # | term_taxonomy_id | term_id | taxonomy      | description | parent | count |
  # +------------------+---------+---------------+-------------+--------+-------+
  # |                1 |       1 | category      |             |      0 |   451 |
  # |                2 |       2 | link_category |             |      0 |     7 |
  # |                3 |       3 | category      |             |      0 |  4184 |
  # |               37 |      34 | post_tag      |             |      0 |     2 |
  # +------------------+---------+---------------+-------------+--------+-------+

  # wp_termに格納されている情報がタグなのかカテゴリーなのか。あと親情報とか使用数とか

  class WpTermTaxonomy < ActiveRecord::Base
    self.table_name = 'wp_term_taxonomy'
    belongs_to :wp_term, foreign_key: :term_id
    has_many :wp_term_relationships, foreign_key: :term_taxonomy_id
    has_many :wp_posts, through: :wp_term_relationships

    scope :tags, -> { where(taxonomy: 'post_tag') }
    scope :categories, -> { where(taxonomy: 'category') }

    def list
      wp_terms.map { |wp_term| { wp_term.slug => wp_term.name } }.flatten
    end
  end
end