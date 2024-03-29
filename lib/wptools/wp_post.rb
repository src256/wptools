# -*- coding: utf-8 -*-

require 'active_record'

module Wptools

  # +-----------------------+-----------------+------+-----+---------------------+----------------+
  # | Field                 | Type            | Null | Key | Default             | Extra          |
  #   +-----------------------+-----------------+------+-----+---------------------+----------------+
  # | ID                    | bigint unsigned | NO   | PRI | NULL                | auto_increment |
  # | post_author           | bigint unsigned | NO   | MUL | 0                   |                |
  # | post_date             | datetime        | NO   |     | 0000-00-00 00:00:00 |                |
  # | post_date_gmt         | datetime        | NO   |     | 0000-00-00 00:00:00 |                |
  # | post_content          | longtext        | NO   | MUL | NULL                |                |
  # | post_title            | mediumtext      | NO   | MUL | NULL                |                |
  # | post_excerpt          | mediumtext      | NO   |     | NULL                |                |
  # | post_status           | varchar(20)     | NO   |     | publish             |                |
  # | comment_status        | varchar(20)     | NO   |     | open                |                |
  # | ping_status           | varchar(20)     | NO   |     | open                |                |
  # | post_password         | varchar(255)    | NO   |     |                     |                |
  # | post_name             | varchar(200)    | NO   | MUL |                     |                |
  # | to_ping               | mediumtext      | NO   |     | NULL                |                |
  # | pinged                | mediumtext      | NO   |     | NULL                |                |
  # | post_modified         | datetime        | NO   |     | 0000-00-00 00:00:00 |                |
  # | post_modified_gmt     | datetime        | NO   |     | 0000-00-00 00:00:00 |                |
  # | post_content_filtered | longtext        | NO   |     | NULL                |                |
  # | post_parent           | bigint unsigned | NO   | MUL | 0                   |                |
  # | guid                  | varchar(255)    | NO   |     |                     |                |
  # | menu_order            | int             | NO   |     | 0                   |                |
  # | post_type             | varchar(20)     | NO   | MUL | post                |                |
  # | post_mime_type        | varchar(100)    | NO   |     |                     |                |
  # | comment_count         | bigint          | NO   |     | 0                   |                |
  # +-----------------------+-----------------+------+-----+---------------------+----------------+

  ##### wp_posts: 投稿などを保存
  # id: 投稿ID
  # post_title: タイトル
  # post_content: 本文
  # post_status: 公開情報
  # post_date: 公開日時(Timeクラス。2020-03-19 11:00:08 UTCと表示されるが実際は日本の時刻?)
  # post_name: slug(テーブル全体でユニーク https://wordpress.stackexchange.com/questions/305371/how-to-add-two-same-slug-under-two-category)
  class WpPost < ActiveRecord::Base
    #    has_many :wp_comments, foreign_key: :comment_post_ID
    has_many :wp_term_relationships, foreign_key: :object_id
    has_many :wp_term_taxonomies, through: :wp_term_relationships

    scope :posts, -> { where(post_type: 'post') }
    scope :published, -> { where(post_status: 'publish')}

    STATUS_PUBLISHED = 'publish'
    STATUS_FUTURE = 'future'
    STATUS_DRAFT = 'draft'
    STATUS_PENDING = 'pending'
    STATUS_PRIVATE = 'private'
    STATUS_TRASH = 'trash'
    STATUS_AUTO_DRAFT = 'auto-draft'
    STATUS_INHERIT = 'inherit'

    def self.published_posts
      where(post_type: 'post', post_status: STATUS_PUBLISHED)
    end

    def tags
      wp_term_taxonomies.tags.map { |wp_term_taxonomy| wp_term_taxonomy.list }.flatten
    end

    def categories
      wp_term_taxonomies.categories.map { |wp_term_taxonomy| wp_term_taxonomy.list }.flatten
    end

    def post_date_str
      post_date.strftime("%Y/%m/%d %H:%M:%S")
    end

    def dispose
      # 状態をtrashに変更
      self.post_status = STATUS_TRASH
    end
  end
end

