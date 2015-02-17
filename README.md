RDF Proxy List
==============

Implements a linked list with `ore:Proxy` nodes.


## Status

This gem is in early development. It implements ordered lists in the way
prescribed by the [Hydra Common Data Model](https://wiki.duraspace.org/display/hydra/Hydra%3A%3AWorks+Shared+Modeling).
This work is the result of meetings in Nov. 2014 and Feb. 2015 at the White
Stag building in Portland, OR.

## Sample Usage

### Create an Empty Proxy List
```ruby
 > require 'rdf/proxy_list'
 > my_aggregator = RDF::URI('http://example.org/my_agg')
 > pl = RDF::ProxyList.new(my_aggregator)
 => #<RDF::ProxyList:0x18829fc(#<RDF::ProxyList:0x000000031053f8>)> 
```

### Add some resources with `<<`

```ruby
 > pl << RDF::URI('http://example.org/foo')
 => [#<RDF::URI:0x187ddf8 URI:http://example.org/foo>] 
 > pl << RDF::URI('http://example.org/bar')
 => [#<RDF::URI:0x187ddf8 URI:http://example.org/foo>, #<RDF::URI:0x187a144 URI:http://example.org/bar>] 
 > pl << RDF::URI('http://example.org/qux')
 => [#<RDF::URI:0x187ddf8 URI:http://example.org/foo>, #<RDF::URI:0x187a144 URI:http://example.org/bar>, #<RDF::URI:0x1875e78 URI:http://example.org/qux>] 
```

### Iterate over the list

```ruby
 >   pl.each do |member|
 >       puts member.inspect
 >   end
#<RDF::URI:0x187ddf8 URI:http://example.org/foo>
#<RDF::URI:0x187a144 URI:http://example.org/bar>
#<RDF::URI:0x1875e78 URI:http://example.org/qux>
 => [#<RDF::URI:0x187ddf8 URI:http://example.org/foo>, #<RDF::URI:0x187a144 URI:http://example.org/bar>, #<RDF::URI:0x1875e78 URI:http://example.org/qux>]
```

### Serialize the list

```ruby
 >   require 'rdf/turtle'
 > namespaces = {
 >       '' => 'http://example.org/', 
 >       ore: 'http://www.openarchives.org/ore/1.0/datamodel#',
 >       iana: 'http://www.iana.org/assignments/relation/'
 >   }
 > puts pl.graph.dump(:turtle, prefixes: namespaces )

@prefix : <http://example.org/> .
@prefix iana: <http://www.iana.org/assignments/relation/> .
@prefix ore: <http://www.openarchives.org/ore/1.0/datamodel#> .

:my_agg iana:first _:g25208280;
   iana:last _:g25048500 .

_:g25048500 iana:prev _:g25051600;
   ore:proxyFor :qux;
   ore:proxyIn :my_agg .

_:g25051600 iana:next _:g25048500;
   iana:prev _:g25208280;
   ore:proxyFor :bar;
   ore:proxyIn :my_agg .

_:g25208280 iana:next _:g25051600;
   ore:proxyFor :foo;
   ore:proxyIn :my_agg .
```

## Contributing

### Hydra Developers

For Hydra developers, or anyone with a signed CLA, please clone the repo and
submit PRs via feature branches. If you don't have rights to projecthydra-labs
and do have a signed CLA, please send a note to hydra-tech@googlegroups.com.

1. Clone it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Non-Hydra Developers

Anyone is welcome to use this software and report issues.
In order to merge any work contributed, you'll need to sign a contributor license agreement.
