require 'queuery_client/data_file_bundle'
require 'queuery_client/url_data_file'
require 'uri'
require 'logger'

module QueueryClient
  class UrlDataFileBundle < DataFileBundle
    def initialize(urls, s3_prefix:, logger: Logger.new($stderr))
      raise ArgumentError, 'no URL given' if urls.empty?
      @data_files = urls.map {|url| UrlDataFile.new(URI.parse(url)) }
      @s3_prefix = s3_prefix
      @logger = logger
    end

    attr_reader :data_files
    attr_reader :s3_prefix

    def url
      uri = data_files.first.url.dup
      uri.query = nil
      uri.path = File.dirname(uri.path)
      uri.to_s
    end

    def direct(bucket_opts = {}, bundle_opts = {})
      s3_uri = URI.parse(s3_prefix)
      bucket = s3_uri.host
      prefix = s3_uri.path[1..-1] # trim heading slash
      S3DataFileBundle.new(bucket, prefix)
    end
  end
end
