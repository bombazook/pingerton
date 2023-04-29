# frozen_string_literal: true

module Tools
  class LuaCache
    LUA_ROOT = File.join(App.root, 'app/persistence/lua').freeze
    LUA_SCRIPTS_PATH = File.join(LUA_ROOT, '**/*.lua').freeze

    def initialize(connection:)
      @connection = connection
      preload_scripts
    end

    def eval(key, *args, **options)
      sha = @cache[key]
      raise LuaScriptNotFoundError.new(key:) unless sha

      @connection.evalsha(sha, *args, **options)
    end

    private

    def preload_scripts
      @cache = Dir[LUA_SCRIPTS_PATH].to_h do |path|
        key = path.sub(Regexp.new("#{File.extname(path)}$"), '').sub(Regexp.new("^#{LUA_ROOT}/"), '')
        lua = File.read(path)
        sha = @connection.script(:load, lua)
        [key, sha]
      end
    end
  end
end
