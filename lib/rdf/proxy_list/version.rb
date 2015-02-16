module RDF
  class ProxyList
    module VERSION
      VERSION_FILE = File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "..", "VERSION")
      MAJOR, MINOR, TINY, EXTRA = File.read(VERSION_FILE).chop.split(".")

      STRING = [MAJOR, MINOR, TINY, EXTRA].compact.join('.')

      def self.to_s
        STRING
      end

      def self.to_str
        to_s
      end

      def self.to_a
        [MAJOR, MINOR, TINY, EXTRA].compact
      end
    end
  end
end
