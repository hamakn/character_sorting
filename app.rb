require "sinatra"
require "haml"
require "json"
require "yaml"
require "bitly"
require_relative "lib/monster_list"
require_relative "lib/helpers"

class App < Sinatra::Base
  set :sprockets, Sprockets::Environment.new

  configure do
    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix = '/assets'
      config.digest = true
    end

    sprockets.append_path 'assets/javascripts'
    sprockets.append_path 'assets/stylesheets'
  end

  helpers Sprockets::Helpers
  helpers Helpers

  before '/*.json' do
    content_type 'application/json'
  end

  get "/" do
    haml :index
  end

  get "/result" do
    haml :result
  end

  get "/api/lists.json" do
    seed = initialize_seed(params["s"])
    monster_list = initialize_list(params["c"], params["l"])

    {
      items: monster_list.next_match.map do |list|
        [
          { name: list.first.name, images: list.first.images },
          { name: list.last.name, images: list.last.images },
        ]
      end,
      seed: seed,
      count: {
        inputs: monster_list.inputs_count,
        enough: monster_list.enough_count,
      },
      result_url: result_url(params["c"], params["s"], monster_list)
    }.to_json
  end

  get "/api/result.json" do
    # XXX: ちゃんとエラーハンドリングする
    begin
      seed, command, app_version, yaml_version = decode_result_param(params["a"])
      initialize_seed(seed)
      monster_list = initialize_list(command, command.length, yaml_version)

      # td log
      td_hash = {
        seed: seed.to_i,
        command: command,
        app_version: app_version.to_f,
        yaml_version: yaml_version.to_f,
      }
      puts_treasure_data_log("dbname", "tablename", td_hash)

      {
        items: monster_list.sort.map do |item|
        {
          name: item[:monster].name,
          images: item[:monster].images,
          score: item[:monster].score,
        }
        end,
        result_url: "#{app_root}/result?a=#{params['a']}"
      }.to_json
    rescue
      {
        redirect_url: app_root
      }.to_json
    end
  end

  get "/api/shorten_url.json" do
    # 自分のサイト以外のURLは短縮しない
    return {}.to_json unless params["u"] =~ /^#{app_root}/

    # TODO: ENVにする
    uname = "username"
    token = "token"
    Bitly.use_api_version_3
    bitly = Bitly.new(uname, token)
    begin
      result = bitly.shorten(params["u"])
      {
        long_url: result.long_url,
        short_url: result.short_url
      }.to_json
    rescue
      {}.to_json
    end
  end
end
