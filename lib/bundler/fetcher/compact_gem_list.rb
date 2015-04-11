module Bundler
  class Fetcher
    class CompactGemList
      require_relative 'compact_gem_list/cache.rb'
      require_relative 'compact_gem_list/updater.rb'

      attr_reader :fetcher, :directory

      def initialize(fetcher, directory)
        @fetcher = fetcher
        @directory = Pathname(directory)
        FileUtils.mkdir_p(@directory)
        @updater = Updater.new(@fetcher)
        @cache   = Cache.new(@directory)
      end

      def names
        @updater.update([[@cache.names_path, url('names')]])
        @cache.names
      end

      def versions
        @updater.update([[@cache.versions_path, url('versions')]])
        @cache.versions
      end

      def dependencies(names)
        @updater.update(names.map do |name|
          [@cache.dependencies_path(name), url("info/#{name}")]
        end)
        names.map do |name|
          @cache.dependencies(name).map { |d| d.unshift(name) }
        end.flatten(1)
      end

      def spec(name, version, platform = nil)
        @updater.update([[@cache.dependencies_path(name), url("info/#{name}")]])
        @cache.specific_dependency(name, version, platform)
      end

      private

      def url(path)
        path
      end
    end
  end
end
