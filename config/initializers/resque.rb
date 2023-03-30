Resque.logger.formatter = Resque::VeryVerboseFormatter.new
Resque.logger = MonoLogger.new(File.open("#{Rails.root}/log/resque.log", "w+"))
Resque.logger.formatter = Resque::QuietFormatter.new

if Rails.environment.development?
    Reque.redis = Redis.new(host: 'localhost', post: '6379')
else
    uri = URI.parse(ENV['REDIS_URL'])
    REDIS = Redis.new(host: url.host, port: url.port, password: uri.password)
    Reque.redis = REDIS
end