# ElasticArSync
This repository contains easy set up modules for RDB and elasticsearch index with Active Record.
This is based on `gem elasticsearch-rails`.
## Usage
### Preparation
Install `gem sidekiq` and `gem redis-rails` to use Asynchronous processing for your app.
Install `gem elasticsearch-rails`, `gem elasticsearch-model` and `gem elasticsearch` for your app.


Include module `ElasticArSync::Elastic::Syncable` on your Model class which is inherited ActiveRecord.

example below

```ruby
class XXXXX < ActiveRecord
  include ElasticArSync::Elastic::Syncable
  index_config
end
```

then your Model class is included modules which is for sync model's table with elasticsearch index.

when you create new record elasticsearch index save new document in sync.
update and delete is same as create.

this module contains class method `index_setup` to setup index.

### usable methods
if your Model class included `ElasticArSync::Elastic::Syncable`, it can use class methods below.

- index_setup (class method)
→ to setup index to elsticsearch

- create_index (class method)
→ to create new index to elasticsearch

- delete_index({index_name})  (class method)
→ to delete index. needed argument index name which you delete

- import_all_record(index_name) (class method)
→ to sync whole record with elasticsearch

- switch_alias(new_index_name) (class method)
→ to switch using index, you needed create more than two index

- mapping_list_keys (class method)
→ to get mapping list array of your index

- get_aliases (class method)
→ to get aliase list array which you created

### Customize
if you change process of after commit, you can override instance methods below.
default is provided by `ElasticArSync::Elastic::Worker::IndexWorker`

- document_sync_create
→ for callback of create

- document_sync_update
→ for callback of update

- document_sync_delete
→ for callback of destroy

if you define original mapping of index like type, attribute, etc, 
you can use `index_config` after `include ElasticArSync::Elastic::Syncable`.

example below

you can override argus `dynamic`, `number_of_shards`, `attr_mappings`.
especially default mapping is whole attributes of your Model class, so you can customize mapping attributes by overriding attr_mappings.
```ruby
index_config(dynamic: 'false', number_of_shards: 1, attr_mappings: { id: 'integer', name: 'text', birth: 'date' })
```

if you define your original mapping additionally, you can define like below.

tips: just reference here.

https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model
```ruby
  settings index: { number_of_shards: number_of_shards } do
    mappings do
      indexes key, type: value
    end
  end
```


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'elastic_ar_sync'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install elastic_ar_sync
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
