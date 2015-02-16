require 'rdf'
require 'rdf/ore'
require 'rdf/iana'

module RDF
  ##
  # Acts as a ORE style RDF ordered list.
  #
  # The implementation is backed by an `elements` array and builds an RDF::Graph
  # just-in-time.
  class ProxyList
    autoload :VERSION, 'rdf/proxy_list/version'

    include RDF::Enumerable
    include RDF::Value
    extend Forwardable

    def_delegators :elements, :empty?
    def_delegators :graph, :each_statement

    class << self
      def first_from_graph(aggregator, graph)
        matches = query_proxy_for(aggregator, graph, RDF::IANA['first'])
        raise InvalidProxyListGraph if matches.length > 1
        matches.first
      end

      def last_from_graph(aggregator, graph)
        matches = query_proxy_for(aggregator, graph, RDF::IANA.last)
        raise InvalidProxyListGraph if matches.length > 1
        matches.first
      end

      def query_next_node(graph, current)
        query = RDF::Query.new do
          pattern [:current_proxy, RDF::ORE.proxyFor, current]
          pattern [:current_proxy, RDF::IANA.next, :next_proxy]
          pattern [:next_proxy, RDF::ORE.proxyFor, :next_node]
        end

        matches = query.execute(graph).map(&:next_node)
        raise InvalidProxyListGraph if matches.length > 1
        matches.first
      end

      private

      ##
      # Queries a given predicate with a proxyable value returning the node the
      # proxy stands in for.
      def query_proxy_for(aggregator, graph, predicate)
        query = RDF::Query.new do
          pattern [aggregator, predicate, :proxy]
          pattern [:proxy, RDF::ORE.proxyFor, :value]
        end

        query.execute(graph).map(&:value)
      end
    end

    def initialize(aggregator, graph = nil)
      @aggregator = convert_to_aggregator(aggregator)
      @elements = elements_from_graph(graph)
    end

    # @!attribute [r] aggregator
    # @return [RDF::Resource] the subject term of this list.
    attr_reader :elements, :aggregator
    private :elements

    alias_method :to_term, :aggregator

    def <<(value)
      resource = convert_to_proxiable_element(value)
      elements << value
    end

    def concat(*args)
      elements.concat(*args)
      self
    end

    def each(&block)
      return to_enum unless block_given?
      elements.each { |node| yield(node) }
    end

    def graph
      graph = RDF::Graph.new
      proxy = nil

      elements.each do |element|
        previous_proxy = proxy
        proxy = RDF::Node.new

        graph << RDF::Statement(proxy, RDF::ORE.proxyIn, aggregator)
        graph << RDF::Statement(proxy, RDF::ORE.proxyFor, element)

        if previous_proxy.nil?
          graph << RDF::Statement(aggregator, RDF::IANA['first'], proxy)
        else
          graph << RDF::Statement(previous_proxy, RDF::IANA.next, proxy)
          graph << RDF::Statement(proxy, RDF::IANA.prev, previous_proxy)
        end
      end

      graph << RDF::Statement(aggregator, RDF::IANA.last, proxy) if proxy
      graph
    end

    private

    def convert_to_aggregator(value)
      case value
      when String
        RDF::URI(value)
      when RDF::URI, RDF::Node, RDF::Resource
        value
      else
        fail InvalidAggregatorObjectError, "Unable to convert #{value.inspect} to an aggregator"
      end
    end

    def convert_to_proxiable_element(value)
      case value
      when RDF::URI
        value
      else
        fail UnproxiableObjectError, "Unable to convert #{value} to a ProxyList element"
      end
    end

    ##
    # Creates an elements `Array` from a valid ORE Proxy ordered list.
    #
    # The implementation ignores all `RDF::IANA.prev` predicates, treating the graph as
    # a singly linked list.
    #
    # @param graph [RDF::Queryable] A graph containing an ORE proxy list.
    # @return [Array<RDF::Resource>] an Array of the resources in the proxy list
    #
    # @raise [InvalidProxyListGraph] if the graph's list is invalid
    def elements_from_graph(graph)
      return [] if graph.nil?

      is_empty = self.class.first_from_graph(aggregator, graph).nil?
      return is_empty ? [] : build_element_list(graph)
    end

    ##
    # @see #elements_from_graph
    def build_element_list(graph)
      list = [self.class.first_from_graph(aggregator, graph)]

      loop do
        next_value = self.class.query_next_node(graph, list.last) || break
        list << next_value
      end
      list
    end

    public

    class UnproxiableObjectError < RuntimeError
    end

    class InvalidAggregatorObjectError < RuntimeError
    end

    class InvalidProxyListGraph < RuntimeError
    end
  end
end
