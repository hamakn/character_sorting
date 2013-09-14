require "base64"
require "zlib"
require "openssl"
require "digest"
require "json"

module Helpers
  APP_VERSION = "1.0"
  YAML_VERSION = "1.3"

  def app_root
    "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
  end

  # 乱数の初期化
  def initialize_seed(seed)
    if seed == "undefined"
      seed = rand(10000)
    else
      seed = seed.to_i
    end
    srand(seed)

    return seed
  end

  def initialize_list(command, length, version = YAML_VERSION)
    conf = load_yaml(version)
    monsters = conf.map { |i| Monster.new(:attributes => i) }
    monster_list = MonsterList.new(monsters)
    monster_list.shuffle!

    # これまでの操作結果をlistに反映する
    if command && length
      inputs = decode_input(command, length)
      monster_list.input_match_results(inputs)
    end

    return monster_list
  end

  def load_yaml(version)
    conf = YAML.load(File.read("./conf/cup_ramen_1.0.yml"))
  end

  # 入力inputを解釈する
  # ex. (command = "123", length = 4) => [0, 1, 2, 3]]
  # 10進数として解釈し、逆順にする
  def decode_input(command, length)
    inputs = command.to_i
    length.to_i.times.each_with_object([]) do |_, result|
      result << (inputs % 10)
      inputs = inputs / 10
    end.reverse
  end

  # 結果ページヘのURLを生成する
  # 手順としては、圧縮(zlib)して、暗号化(openssl)して、URL化(safeurl_base64)
  def result_url(command, seed, list)
    # 入力が不十分であれば、結果URLは返さない
    return nil if list.inputs_count < list.enough_count

    app_version = APP_VERSION
    yaml_version = YAML_VERSION
    str = [seed, command, app_version, yaml_version].join("-")

    # 圧縮
    compressed_str = Zlib::Deflate.deflate(str)

    # 暗号化
    # パスワードとsoltは後でなんとかする
    cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
    cipher.encrypt
    cipher.pkcs5_keyivgen(Digest::SHA1.hexdigest("this is password"), "soltsolt")
    encrypted_str = cipher.update(compressed_str) + cipher.final

    # base64化
    urlsafe_str = Base64.urlsafe_encode64(encrypted_str)

    # treasure data log
    td_hash = {
      seed: seed.to_i,
      command: command,
      app_version: app_version.to_f,
      yaml_version: yaml_version.to_f,
    }
    puts_treasure_data_log("dbname", "tablename", td_hash)

    # 最終結果
    return "#{app_root}/result?a=#{urlsafe_str}"
  end

  # treasure data向けのlogを生成する
  def puts_treasure_data_log(dbname, tablename, hash)
    hash = hash.merge({ time: Time.now.to_i })
    td_str = "@[#{dbname}.#{tablename}] " + hash.to_json
    puts td_str
  end

  def decode_result_param(param)
    return nil unless param

    begin
      # base64解除
      encrypted_str = Base64.urlsafe_decode64(param)

      # 復号化
      cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
      cipher.decrypt
      cipher.pkcs5_keyivgen(Digest::SHA1.hexdigest("this is password"), "soltsolt")
      compressed_str = cipher.update(encrypted_str) + cipher.final

      # 解凍
      str = Zlib::Inflate.inflate(compressed_str)

      return str.split("-")
    rescue
      return nil
    end
  end
end
