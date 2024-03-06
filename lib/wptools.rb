# coding: utf-8
require "wptools/version"
require "wptools/wp_post"
require "wptools/wp_term_relationship"
require "wptools/wp_term_taxonomy"
require "wptools/wp_term"
require 'yaml'
require 'optparse'
require 'csv'
require 'erb'

module Wptools
  class Error < StandardError; end
  # Your code goes here...

  class Config
    def initialize(config)
      @config = config
      @dbname = config_value('local', 'dbname', true)
      @dbuser = config_value('local', 'dbuser', true)
      @dbpasswd = config_value('local', 'dbpasswd', true)
    end
    attr_reader :dbname, :dbuser, :dbpasswd
    private
    def config_value(section, key, require)
      value = @config[section][key]
      if require && (value.nil? || value.empty?)
        raise RuntimeError, "#{section}:#{key}: is empty"
      end
      value
    end
  end

  class DB
    def self.prepare(spec)
      ActiveRecord::Base.establish_connection spec            
    end
  end

  class Command
    def self.load_yaml(filename)
      content = File.read(filename)
      content = ERB.new(content).result
      YAML.load(content)
    end

    def self.run(argv)
      STDOUT.sync = true
      opts = {}
      opt = OptionParser.new(argv)      
      opt.banner = "Usage: #{opt.program_name} [-h|--help] config.yml"
      opt.separator('')
      opt.separator "#{opt.program_name} Available Options"
      opt.on_head('-h', '--help', 'Show this message') do |v|
        puts opt.help
        exit
      end
      opt.on('-v', '--verbose', 'Verbose message') {|v| opts[:v] = v}
      opt.on('-n', '--dry-run', 'Message only') {|v| opts[:n] = v}
      commands = ['list', 'buzz', 'none']
      opt.on('-c COMMAND', '--command=COMMAND', commands, commands.join('|')) {|v| opts[:c] = v}
      opt.on('-l NUM', '--limit NUM', 'Limit number') {|v| opts[:l] = v.to_i}
      opt.on('-d DATAFILE', '--data DATAFILE', 'CSV Datafile') {|v| opts[:d] = v }
      opt.parse!(argv)
      if argv.empty?
        puts opt.help
        exit        
      end
      config_file = argv[0] || "~/.wptoolsrc"
      config = Config.new(load_yaml(config_file))
      command = Command.new(opts, config)
      command.run      
    end

    def initialize(opts, config)
      @opts = opts
      @config = config
      spec = {adapter: 'mysql2', host: 'localhost', username: @config.dbuser, password: @config.dbpasswd, database: @config.dbname}
      DB.prepare(spec)
    end

    def run
      if @opts[:c] == 'list'
        list(@opts[:l])
      elsif @opts[:c] == 'buzz'
        buzz(@opts[:d])
      elsif @opts[:c] == 'none'
      end
    end

    def list(num)
      WpPost.published_posts.order(post_date: "DESC").limit(num).each do | post|
        print "#{post.id} #{post.post_type} #{post.post_date_str} #{post.post_title} #{post.post_name}\n"
      end      
    end

    def buzz(filename)
      from_date, to_date, pvs = read_analytics(filename)
      post_pvs = []
      WpPost.published.where("post_date >= ? AND post_date <= ?", from_date, to_date).order(post_date: "DESC").each do |post|
        pv = pvs[post.post_name] || 0
        post_pvs << [post, pv]
      end

      yd = from_date.strftime("%Y/%m")
      limit = 10
      post_pvs.sort{|a, b| b[1] <=> a[1]}.each_with_index do |post_pvs, index|
        break if index >= limit
        post, pv = post_pvs
        print "#{yd},#{index+1},\"#{post.post_title}\",#{pv}\n"
      end
    end

    def read_analytics(filename)
      p filename
      # Google Analysticsから出力したページ毎のPVデータを読み込む
      from_date = nil
      to_date = nil
      if filename =~ /(\d\d\d\d)(\d\d)(\d\d)-(\d\d\d\d)(\d\d)(\d\d)\.csv$/
        from_date = Time.local($1.to_i, $2.to_i, $3.to_i)
        to_date = Time.local($4.to_i, $5.to_i, $6.to_i)
      end
      if from_date.nil? || to_date.nil?
        raise "Unknown file name #{filename}"
      end
      # slugごとにpv数を保存
      pvs = {}
      CSV.foreach(filename) do |raw|
        if raw.size == 8
          pagename = raw[0]
          pv = raw[1].gsub(/,/, '').to_i
          if pagename =~ /\/([^\/]+)\/$/
            pvs[$1] = pv
          end
        end
      end
      return from_date, to_date, pvs
    end
  end
end
